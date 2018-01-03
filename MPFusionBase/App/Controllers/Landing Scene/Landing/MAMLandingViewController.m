//
//  MAMLandingViewController.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/10/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMLandingViewController.h"
#import "MAMMainMenuViewController.h"
#import "UIView+AutoLayoutHelper.h"
#import "MBProgressHUD.h"
#import "MTPAppSettingsKeys.h"

@interface MAMLandingViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *editProfileTopView;
@property (weak, nonatomic) IBOutlet UIWebView *editProfileWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *editProfileTopSpace;
@property (weak, nonatomic) IBOutlet UIButton *hideEditProfileButton;
@end

@implementation MAMLandingViewController

CGFloat const menuWidth = 0.8f;

#pragma mark - View Life Cycle
- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.editProfileTopSpace.constant = CGRectGetHeight(self.view.frame);
    self.editProfileWebView.opaque = false;
    self.editProfileWebView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundTexture"]];
    self.editProfileTopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationBarBackground"]];
    self.editProfileTopView.layer.cornerRadius = 10.f;
    self.editProfileTopView.layer.borderColor = [UIColor blackColor].CGColor;
    self.editProfileTopView.layer.borderWidth = 1.f;
    self.editProfileTopView.layer.masksToBounds = true;
    
    [self.hideEditProfileButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:40.f]];
    [self.hideEditProfileButton setTitle:@"\uf107" forState:UIControlStateNormal];
    
    self.editProfileWebView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Initial Setup
- (void)setupContainerConstraints
{
//    NSArray *views = @[self.menuContainerView,self.contentContainerView];
//    [views enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [obj setTranslatesAutoresizingMaskIntoConstraints:false];
//    }];
//    [self.view removeSuperviewConstraintsForViews:views];
//    
//    NSLayoutConstraint *menuLeading = [self.menuContainerView pinLeading];
//    NSLayoutConstraint *menuTop = [self.menuContainerView pinToTopSuperview];
//    NSLayoutConstraint *menuBottom = [self.menuContainerView pinToBottomSuperview];
//    NSLayoutConstraint *menuWidthConstraint = [self.menuContainerView equalWidth:menuWidth];
//    
//    [self.view addConstraints:@[menuLeading,menuTop,menuBottom,menuWidthConstraint]];
//    
//    [self.view addConstraints:[self.contentContainerView pinToSuperviewBounds]];
}
#pragma mark - Protocol Conformance

- (void)addViewControllerToStack:(UIViewController *)newChildViewController
{
    [self addChildViewController:newChildViewController];
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.contentContainerView addSubview:newChildViewController.view];
        [MBProgressHUD hideAllHUDsForView:self.view animated:false];
    });
}

- (void)topViewControllerShouldToggleMenu:(id)sender
{
    NSLayoutConstraint *leadingEdgeStartingPoint = [self constraintForItem:self.contentContainerView
                                                           layoutAttribute:NSLayoutAttributeLeft|NSLayoutAttributeLeading];
    NSLayoutConstraint *trailingEdgeStartingPoint = [self constraintForItem:self.contentContainerView
                                                            layoutAttribute:NSLayoutAttributeRight|NSLayoutAttributeTrailing];
    CGFloat newOrigin;
    if ([sender isKindOfClass:[NSNumber class]])
    {
        newOrigin = 0;
    }
    else
    {
        newOrigin = leadingEdgeStartingPoint.constant < 1 ? CGRectGetWidth(self.view.frame) * menuWidth : 0;
    }
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.2f animations:^{
        leadingEdgeStartingPoint.constant = newOrigin;
        trailingEdgeStartingPoint.constant = -newOrigin;
        [self.view layoutIfNeeded];
    }];
    
    [[self childViewControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
    {
        if ([obj isKindOfClass:[MAMMainMenuViewController class]])
        {
            [(MAMMainMenuViewController *)obj setVisiblityState: leadingEdgeStartingPoint.constant  == 0 ? MTPMainMenuVisibilityStateHidden : MTPMainMenuVisibilityStateVisible];
            [(MAMMainMenuViewController *)obj configureHeaderView];
            *stop = true;
        }
    }];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.editProfileWebView animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideAllHUDsForView:self.editProfileWebView animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // this suppresses the error that occurs when the user navigates to another
    // screen and when it cancels opening "../#/mds-pollzone/" after login
    if (error.code != -999 && error.code != 102) {
        //        [MTConstants showSIAlertWithTitle:@"Network Error" message:@"Couldn't load the website! Press reload to try again"];
    }
    [MBProgressHUD hideAllHUDsForView:self.editProfileWebView animated:YES];
}

#pragma mark - Helper Methods
- (IBAction)toggleEditProfileVisibility
{
    if ([self.parentViewController isKindOfClass:[MAMRootNavigationViewController class]])
    {

    }
}

- (void)refreshEditProfileWebView:(NSNumber *)userID
{
    if (!userID)
    {
        return;
    }
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:[NSString stringWithFormat:@"%@/edit-profile/?userID=%@",
                                                   [[self.userDefaults objectForKey:MTP_NetworkOptions]
                                                    objectForKey:MTP_EventBaseHTTPURL],userID]]
                                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                         timeoutInterval:30.f];
    [self.editProfileWebView loadRequest:request];
}

- (NSLayoutConstraint *)constraintForItem:(UIView *)firstItem
                          layoutAttribute:(NSLayoutAttribute)layoutAttribute
{
    if (!firstItem)
    {
        return nil;
    }
    
    for (NSLayoutConstraint *possibleMatchingConstraint in self.view.constraints)
    {
        if (possibleMatchingConstraint.firstItem == firstItem ||
            possibleMatchingConstraint.secondItem == firstItem)
        {
            if (possibleMatchingConstraint.firstAttribute == layoutAttribute)
            {
                return possibleMatchingConstraint;
            }
        }
    }
    
    return nil;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
