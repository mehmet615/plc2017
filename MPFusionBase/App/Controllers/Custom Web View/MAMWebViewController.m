//
//  MAMWebViewController.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/13/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMWebViewController.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "UIView+AutoLayoutHelper.h"
#import "UIButton+MTPNavigationBar.h"
#import "AFNetworkReachabilityManager.h"
#import "UIImageView+MTPNavigationBar.h"
#import "AFNetworkReachabilityManager.h"
#import "MTPAppSettingsKeys.h"
#import "MBProgressHUD.h"
#import "User+Helpers.h"
#import "UIColor+AppColors.h"
#import "SIAlertView.h"
#import "UIWebView+MTPHelpers.h"

#import "UIViewController+NavigationItemSetup.h"
#import "NSObject+EventDefaultsHelpers.h"

#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"

#import <QuickLook/QuickLook.h>

@interface MAMWebViewController ()
@property (nonatomic, assign) CGRect mainTitleBounds;
@property (nonatomic, strong) UIView *separatorLine;
@property (assign, nonatomic) BOOL addedButton;
@end

@implementation MAMWebViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.addedButton = NO;

    self.webViewContainer.backgroundColor = [UIColor clearColor];
    
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.delegate = self;
    self.webView.opaque = NO;
    self.webView.scalesPageToFit = true;
    self.webView.alpha = 1;
    
    // Do any additional setup after loading the view from its nib.
    
    [self loadCustomURL:[NSURL URLWithString:self.customURL] forceReload:NO];
    
    [self setupNavigationItem:[[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];
    
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
    
    [self setupConstraints];
    
    [self setupBackgroundTexture];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initial Setup
- (void)setupBackgroundTexture
{
    [self.themeOptionsManager loadRemoteTexture:[self.themeOptionsManager.themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageBackgroundTexture]
                                        forView:self.view];
}

#pragma mark - Protocol Conformance

#pragma mark - IBActions
- (void)returnPrevious:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)refreshWebView:(id)sender
{
    [self loadCustomURL:[NSURL URLWithString:self.customURL] forceReload:YES];
}

#pragma mark - Helper Methods
- (void)toggleMenu:(id)sender
{
    if (self.menuToggleDelegate && [self.menuToggleDelegate respondsToSelector:@selector(topViewControllerShouldToggleMenu:)])
    {
        [self.menuToggleDelegate topViewControllerShouldToggleMenu:nil];
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
    NSMutableURLRequest *request;
    
    if ([self.webView requiresAutoLogin])
    {        
        NSURL *urlWithUserID = customURL;
        if (urlWithUserID.query.length > 0)
        {
            NSString *lastCharacter = [NSString stringWithFormat:@"%c",[urlWithUserID.absoluteString characterAtIndex:(urlWithUserID.absoluteString.length - 1)]];
            urlWithUserID = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@userID=%@",
                                                  urlWithUserID.absoluteString,
                                                  [lastCharacter isEqualToString:@"&"] ? @"" : @"&",
                                                  self.currentUser.user_id]];
        }
        else
        {
            NSString *lastCharacter = [NSString stringWithFormat:@"%c",[urlWithUserID.absoluteString characterAtIndex:(urlWithUserID.absoluteString.length - 1)]];
            urlWithUserID = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@userID=%@&native=1",
                                                  urlWithUserID.absoluteString,
                                                  [lastCharacter isEqualToString:@"?"] ? @"" : @"?",
                                                  self.currentUser.user_id]];
        }
        
        request = [NSMutableURLRequest requestWithURL:urlWithUserID cachePolicy:cachePolicy timeoutInterval:20.0f];
    }
    else
    {
        NSString *requestString = [NSString stringWithFormat:@"%@%@",customURL.absoluteString,(customURL.query.length ? @"&native=1" : @"?native=1")];
        request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestString] cachePolicy:cachePolicy timeoutInterval:20.f];
    }
    
    // load url request
    [self.webView loadRequest:request];
    
    DLog(@"\nrequest URL %@", request.URL);
}

#pragma mark - Delegate Methods
#pragma mark UIWebView Delegateo
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [NSString stringWithFormat:@"%@",[[self.userDefaults objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL]];
    NSString *requestUrlString = request.URL.absoluteString;
    
    switch (navigationType)
    {
        case UIWebViewNavigationTypeLinkClicked:
        {
            if ([request.URL.host rangeOfString:@"documentViewer" options:NSCaseInsensitiveSearch].length)
            {
                [[UIApplication sharedApplication] openURL:request.URL];
                return false;
            }
            else if ([requestUrlString rangeOfString:urlString options:NSCaseInsensitiveSearch].location == NSNotFound)
            {
                [[UIApplication sharedApplication] openURL:request.URL];
                return false;
            }
            break;
        }
        default:
            break;
    }
    
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // this suppresses the error that occurs when the user navigates to another
    // screen and when it cancels opening "../#/mds-pollzone/" after login
    if (error.code != -999 && error.code != 102) {
        //        [MTConstants showSIAlertWithTitle:@"Network Error" message:@"Couldn't load the website! Press reload to try again"];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    NSArray *viewsForConstraintSetup = @[self.webViewHeader,self.headerBackground,self.mainTitleLabel,self.webviewDescriptionTextView,self.webViewContainer];
    [self.view removeSuperviewConstraintsForViews:viewsForConstraintSetup];
    
    [self.webViewHeader.superview addConstraints:[self.webViewHeader pinLeadingTrailing]];
    [self.webViewHeader.superview addConstraints:@[[self.webViewHeader pinToTopLayoutGuide:self],
                                                   [self.webViewHeader height:0]]];
    
    [self.headerBackground.superview addConstraints:[self.headerBackground pinToSuperviewBounds]];
    
    [self.webViewContainer.superview addConstraints:[self.webViewContainer pinLeadingTrailing]];
    [self.webViewContainer.superview addConstraints:@[[self.webViewContainer pinToBottomSuperview],
                                                      [self.webViewContainer pinSide:NSLayoutAttributeTop
                                                                              toView:self.webViewHeader
                                                                      secondViewSide:NSLayoutAttributeBottom]]];
    

    
    [self.mainTitleLabel.superview addConstraints:@[[self.mainTitleLabel pinToTopSuperview],
                                                    [self.mainTitleLabel equalHeight:0.50f],
                                                    [self.mainTitleLabel alignCenterHorizontalSuperview]]];
    
    [self.webviewDescriptionTextView.superview addConstraints:[self.webviewDescriptionTextView pinLeadingTrailing:20.f]];
    [self.webviewDescriptionTextView.superview addConstraints:@[[self.webviewDescriptionTextView pinToBottomSuperview],
                                                                [self.webviewDescriptionTextView pinSide:NSLayoutAttributeTop
                                                                                                  toView:self.mainTitleLabel
                                                                                          secondViewSide:NSLayoutAttributeBottom]]];
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

















@end
