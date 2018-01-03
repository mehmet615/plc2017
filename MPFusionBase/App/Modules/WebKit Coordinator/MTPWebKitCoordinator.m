//
//  MTPWebKitCoordinator.m
//  SEEK2017
//
//  Created by Michael Thongvanh on 12/2/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPWebKitCoordinator.h"
#import "MTPDLogDefine.h"
#import "MBProgressHUD.h"
#import "MTPAppSettingsKeys.h"
#import "AFNetworkReachabilityManager.h"
#import "WKWebView+MTPHelpers.h"
#import <WebKit/WebKit.h>

@interface MTPWebKitCoordinator () <WKNavigationDelegate>
@property (strong, nonatomic) NSString *appURLScheme;
@property (strong, nonatomic) NSURL *customURL;
@end

@implementation MTPWebKitCoordinator

- (instancetype)init:(NSNumber *)userID processPool:(WKProcessPool *)processPool
{
    if (self = [super init])
    {
        _appURLScheme = [self setupURLScheme];
        _userID = userID;
        _processPool = processPool;
    }
    
    return self;
}

- (void)setupWebView:(UIView *)containerView margin:(NSNumber *)margin
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.processPool = self.processPool;
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.navigationDelegate = self;
    [containerView addSubview:webView];
    
    NSDictionary *metrics = @{@"margin": @0};
    if (margin)
    {
        metrics = @{@"margin": margin};
    }
    
    [webView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]-margin-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(webView)]];
    [webView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[webView]-margin-|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(webView)]];
    
    webView.hidden = NO;
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque = NO;
    webView.alpha = 1;
    
    self.webView = webView;
    self.containerView = containerView;
}

- (NSString *)setupURLScheme
{
    __block NSString *appURLScheme = nil;
    
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    [urlTypes enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull urlType, NSUInteger idx, BOOL * _Nonnull found)
     {
         NSString *role = urlType[@"CFBundleTypeRole"];
         if ([role isEqual:@"Editor"])
         {
             NSArray *schemes = urlType[@"CFBundleURLSchemes"];
             [schemes enumerateObjectsUsingBlock:^(NSString * _Nonnull scheme, NSUInteger idx, BOOL * _Nonnull stop) {
                 if (scheme.length > 1)
                 {
                     if ([scheme rangeOfString:@"mp" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 2)].length)
                     {
                         appURLScheme = scheme;
                         *stop = YES;
                         *found = YES;
                     }
                     else
                     {
                         DLog(@"\nnot a meetingplay scheme %@",scheme);
                     }
                 }
                 else
                 {
                     DLog(@"\ninvalid scheme %@",scheme);
                 }
             }];
         }
     }];
    
    return appURLScheme;
}

- (void)loadCustomURL:(NSURL *)customURL forceReload:(BOOL)forceReload
{
    self.customURL = customURL;
    
    NSURLRequestCachePolicy cachePolicy;
    if (forceReload)
    {
        cachePolicy = NSURLRequestReloadIgnoringCacheData;
    }
    else
    {
        cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    
    if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable)
    {
        cachePolicy = NSURLRequestReturnCacheDataElseLoad;
    }
    
    // setup request
    __block NSMutableURLRequest *request;
    
    __weak typeof(&*self)weakSelf = self;
    [self.webView mtp_requiresAutoLoginCompletion:^(BOOL requiresAutoLogin) {
        if (requiresAutoLogin)
        {
            NSURL *urlWithUserID = customURL;
            if (urlWithUserID.query.length > 0)
            {
                NSString *lastCharacter = [NSString stringWithFormat:@"%c",[urlWithUserID.absoluteString characterAtIndex:(urlWithUserID.absoluteString.length - 1)]];
                urlWithUserID = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@userID=%@&native=1",
                                                      urlWithUserID.absoluteString,
                                                      [lastCharacter isEqualToString:@"&"] ? @"" : @"&",
                                                      weakSelf.userID]];
            }
            else
            {
                NSString *lastCharacter = [NSString stringWithFormat:@"%c",[urlWithUserID.absoluteString characterAtIndex:(urlWithUserID.absoluteString.length - 1)]];
                urlWithUserID = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@userID=%@&native=1",
                                                      urlWithUserID.absoluteString,
                                                      [lastCharacter isEqualToString:@"?"] ? @"" : @"?",
                                                      weakSelf.userID]];
            }
            
            request = [NSMutableURLRequest requestWithURL:urlWithUserID cachePolicy:cachePolicy timeoutInterval:20.0f];
        }
        else
        {
            NSString *requestString = [NSString stringWithFormat:@"%@%@",customURL.absoluteString,(customURL.query.length ? @"&native=1" : @"?native=1")];
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString] cachePolicy:cachePolicy timeoutInterval:20.f];
        }
        
        // load url request
        [weakSelf.webView loadRequest:request];
        
        DLog(@"\nrequest URL %@", request.URL);
    }];
}

#pragma mark - Delegate Methods
#pragma mark WKWebView Delegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated || navigationAction.navigationType == WKNavigationTypeOther)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@",[[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL]];
        
        BOOL externalLink = [navigationAction.request.URL.absoluteString rangeOfString:urlString options:NSCaseInsensitiveSearch].location == NSNotFound;
        BOOL appURLSchemeLink = [[navigationAction.request.URL scheme] compare:self.appURLScheme options:NSCaseInsensitiveSearch] == NSOrderedSame;
        
        if (externalLink || appURLSchemeLink)
        {
            actionPolicy = WKNavigationActionPolicyCancel;
            
            if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL])
            {
                [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
            }
        }
    }
    decisionHandler(actionPolicy);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self toggleProgressHUDVisiblity:true];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self toggleProgressHUDVisiblity:false];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    [self toggleProgressHUDVisiblity:false];
}

- (void)toggleProgressHUDVisiblity:(BOOL)visible
{
    UIView *hudContainerView = self.containerView;
    if (hudContainerView)
    {
        if (visible)
        {
            [MBProgressHUD showHUDAddedTo:hudContainerView animated:true];
        }
        else
        {
            [MBProgressHUD hideHUDForView:hudContainerView animated:true];
        }
    }
    else
    {
        DLog(@"%s\n[%s]: Line %i] %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
             @"no feedback container found");
    }
}

@end
