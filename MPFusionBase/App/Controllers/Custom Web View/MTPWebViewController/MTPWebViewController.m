//
//  MTPWebViewController.m
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 10/27/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPWebViewController.h"
#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"
#import "MTPAppSettingsKeys.h"

#import "MBProgressHUD.h"
#import "SIAlertView.h"
#import "AFNetworkReachabilityManager.h"
#import <QuickLook/QuickLook.h>

#import "MTPDLogDefine.h"
#import "UIViewController+NavigationItemSetup.h"
#import "WKWebView+MTPHelpers.h"
#import "UIViewController+NavigationItemSetup.h"
#import "User+Helpers.h"
#import "UIColor+AppColors.h"
#import "UIButton+MTPNavigationBar.h"

@interface MTPWebViewController () <WKNavigationDelegate>
@property (assign, nonatomic) BOOL addedButton;
@property (strong, nonatomic) NSArray *previewItems;
@property (strong, nonatomic) NSString *appURLScheme;
@end

@implementation MTPWebViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    
    self.addedButton = NO;
    [self setupWebView];
    
    [self loadCustomURL:[NSURL URLWithString:self.customURL] forceReload:NO];
    
    [self setupNavigationItem:[[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];
    
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
    
    [self setupBackgroundTexture];
    
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
                        _appURLScheme = scheme;
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
}

- (void)setupWebView
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.processPool = self.processPool;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.navigationDelegate = self;
    [self.webViewContainer addSubview:webView];
    [webView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    [webView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    
    self.webView.hidden = YES;
    
    self.webView = webView;
    
    self.webViewContainer.backgroundColor = [UIColor clearColor];
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.opaque = NO;
    self.webView.alpha = 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.addedButton == NO)
    {
        self.addedButton = YES;
        
        NSMutableArray *rightBarItems = [NSMutableArray arrayWithArray:[self.navigationItem rightBarButtonItems]];
        [rightBarItems addObject:[UIButton refreshMenuButton:nil target:self selector:@selector(refreshWebView:)]];
        [[self navigationItem] setRightBarButtonItems:rightBarItems];
    }
}

- (void)loadCustomURL:(NSURL *)customURL forceReload:(BOOL)forceReload
{
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
                                                      weakSelf.currentUser.user_id]];
            }
            else
            {
                NSString *lastCharacter = [NSString stringWithFormat:@"%c",[urlWithUserID.absoluteString characterAtIndex:(urlWithUserID.absoluteString.length - 1)]];
                urlWithUserID = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@userID=%@&native=1",
                                                      urlWithUserID.absoluteString,
                                                      [lastCharacter isEqualToString:@"?"] ? @"" : @"?",
                                                      weakSelf.currentUser.user_id]];
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
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated)
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
    UIView *hudContainerView = self.webViewContainer;
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
        NSLog(@"%s\n[%s]: Line %i] %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
              @"no feedback container found");
    }
}

#pragma mark - Helper Methods
- (void)toggleMenu:(id)sender
{
    if (self.menuToggleDelegate && [self.menuToggleDelegate respondsToSelector:@selector(topViewControllerShouldToggleMenu:)])
    {
        [self.menuToggleDelegate topViewControllerShouldToggleMenu:nil];
    }
}

#pragma mark - Initial Setup
- (void)setupBackgroundTexture
{
    [self.themeOptionsManager loadRemoteTexture:[self.themeOptionsManager.themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageBackgroundTexture]
                                        forView:self.view];
}

#pragma mark - IBActions
- (void)returnPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshWebView:(id)sender
{
    [self loadCustomURL:[NSURL URLWithString:self.customURL] forceReload:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
