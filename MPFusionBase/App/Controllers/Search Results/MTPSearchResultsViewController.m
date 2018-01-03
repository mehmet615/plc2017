//
//  MTPSearchResultsViewController.m
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/22/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "MTPSearchResultsViewController.h"
#import "MTPThemeOptionsManager.h"

#import "UIButton+MTPNavigationBar.h"
#import "UIViewController+NavigationItemSetup.h"
#import "NSString+MTPWebViewURL.h"
#import "MBProgressHUD.h"
#import "MTPAppSettingsKeys.h"

@interface MTPSearchResultsViewController () <UIWebViewDelegate>
@property (strong, nonatomic) UIWebView *searchWebView;
@end

@implementation MTPSearchResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.searchWebView = [self configureWebView:self.view];
    
    NSMutableURLRequest *searchRequest = [self requestForQuery:self.searchQuery];
    [self.searchWebView loadRequest:searchRequest];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self setupNavigationItem:[[self.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];

    [self configureWithThemeOptions:self.themeOptionsManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableArray *rightBarItems = [NSMutableArray arrayWithArray:[self.navigationItem rightBarButtonItems]];
    [rightBarItems addObject:[UIButton refreshMenuButton:nil target:self selector:@selector(refreshWebView:)]];
    [[self navigationItem] setRightBarButtonItems:rightBarItems];
    
    [self setupLeftBarButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureWithThemeOptions:(MTPThemeOptionsManager *)themeOptionsManager
{
    [themeOptionsManager loadRemoteTexture:[themeOptionsManager backgroundTexture] forView:self.view];
}

- (UIWebView *)configureWebView:(UIView *)parentView
{
    UIWebView *searchResultsWebView = [UIWebView new];
    
    searchResultsWebView.backgroundColor = [UIColor clearColor];
    searchResultsWebView.opaque = NO;
    searchResultsWebView.delegate = self;
    
    searchResultsWebView.translatesAutoresizingMaskIntoConstraints = NO;
    [parentView addSubview:searchResultsWebView];
    
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[searchResultsWebView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchResultsWebView)]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[searchResultsWebView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(searchResultsWebView)]];
    
    return searchResultsWebView;
}

- (NSMutableURLRequest *)requestForQuery:(NSString *)searchQuery
{
    if (searchQuery.length == 0)
    {
        return nil;
    }
    
    NSURL *searchResults = [NSURL URLWithString:[NSString stringWithFormat:@"%@userID=%@",[NSString searchResults],self.userID]];
    
    NSMutableURLRequest *searchRequest = [NSMutableURLRequest requestWithURL:searchResults];
    [searchRequest setHTTPMethod:@"POST"];
    [searchRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [searchRequest setHTTPBody:[self searchRequestData:searchQuery]];
    
    return searchRequest;
}

- (NSData *)searchRequestData:(NSString *)searchQuery
{
    return [[NSString stringWithFormat:@"searchTerm=%@",searchQuery] dataUsingEncoding:NSUTF8StringEncoding];
}

- (IBAction)refreshWebView:(id)sender
{
    [self.searchWebView reload];
}

#pragma mark - Protocol Conformance
#pragma mark Web View Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self toggleProgressHUDVisiblity:true];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self toggleProgressHUDVisiblity:false];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self toggleProgressHUDVisiblity:false];
}

- (void)toggleProgressHUDVisiblity:(BOOL)visible
{
    UIView *hudContainerView = self.searchWebView;
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


- (void)setupLeftBarButton
{
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
}

- (void)toggleMenu:(id)sender
{
    if (self.menuToggler && [self.menuToggler respondsToSelector:@selector(topViewControllerShouldToggleMenu:)])
    {
        [self.menuToggler topViewControllerShouldToggleMenu:nil];
    }
}
@end
