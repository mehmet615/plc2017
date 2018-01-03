//
//  MAMBaseViewController.m
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 9/27/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMBaseViewController.h"
#import "MAMMainMenuViewController.h"
#import "MTPRightNavigationViewController.h"
#import "MAMStoryboardIdentifiers.h"
#import "User+Helpers.h"
#import "MDMyConnectionManager.h"
#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"
#import "MTPAppSettingsKeys.h"
#import "MTPSideMenuTogglable.h"
#import "UIViewController+NavigationItemSetup.h"
#import "NSString+MTPWebViewURL.h"
#import "MTPPanelVisibilityCoordinator.h"

#import "MTPNearbyCardPresenter.h"
#import "MTPMatchCoordinator.h"
#import "MTPNearbyCoordinator.h"
#import "MTPAPIDataInitializer.h"

#import "MTPApplicationDefaultsConstants.h"

#import <WebKit/WebKit.h>

@interface MAMBaseViewController () <UIWebViewDelegate, MTPSideMenuDelegate, MTPPanelVisibilityDelegate>
@property (strong, nonatomic) NSLayoutConstraint *rightMenuWidth;
@property (strong, nonatomic) MTPPanelVisibilityCoordinator *panelVisibilityCoordinator;
@property (strong, nonatomic) NSTimer *matchesTimer;
@end

@implementation MAMBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // view controller setup
    self.matchCoordinator = [MTPMatchCoordinator new];
    
    [self setupSideMenu];
    
    self.contentContainer = [self contentContainer:self.view];
    [self addContentViewController:self.contentViewController parentView:self.contentContainer];
    
    [self setupProfileEditor];
    
    [self setupNavigationItem:[[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];
    
    self.panelVisibilityCoordinator = [MTPPanelVisibilityCoordinator new];
    [self.panelVisibilityCoordinator addPan:self.view constraint:self.contentContainerLeading visibleWidth:menuWidth];
    self.panelVisibilityCoordinator.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMenus:) name:MTP_NavigationMenuDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTheme:) name:@"MTP_ThemeOptionsDidUpdateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserDetails:) name:MTP_LoginNotification object:nil];
    
    self.nearbyCardPresenter = [MTPNearbyCardPresenter new];
    [self.nearbyCardPresenter setup:self.view navigationRouter:self.navigationRouter];
    
    if (MTP_FIVE_STAR_MATCHES_ENABLED)
    {
        [self.matchCoordinator matches:self.navigationRouter.currentUser.user_id completion:^(NSArray *matches, NSError *error)
         {
             [self startMatchTimer];
         }];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startMatchTimer
{
    NSTimer *matchesTimer = [NSTimer timerWithTimeInterval:25 target:self selector:@selector(checkMatches:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:matchesTimer forMode:NSDefaultRunLoopMode];
    [matchesTimer fire];
    self.matchesTimer = matchesTimer;
}

- (void)setupProfileEditor
{
    self.editProfilePresenter = [MTPEditProfilePresenter new];
    [self.editProfilePresenter presentEditProfileInView:self.view];
    self.editProfilePresenter.editProfileDelegate = self;
    self.editProfilePresenter.userID = self.navigationRouter.currentUser.user_id;
}

- (void)updateMenus:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainMenuController.menuTableView reloadData];
    });
}

- (void)reloadTheme:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainMenuController reloadAppearance];
    });
}

- (void)updateUserDetails:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSNumber *userID = [[notification userInfo] objectForKey:kUserID];
        if (userID)
        {
            [self.rightMenu reloadWithUserID:userID];
        }
    });
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.contentViewController;
}

- (void)addMainMenu:(MAMMainMenuViewController *)mainMenu
{
    self.mainMenuController = mainMenu;

    [self setupMainMenu:self.mainMenuController inViewController:self];
}

- (UIView *)contentContainer:(UIView *)parentView
{
    UIView *contentContainer = [UIView new];
    contentContainer.translatesAutoresizingMaskIntoConstraints = false;
    
    contentContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    contentContainer.layer.shadowOpacity = 1.f;
    contentContainer.layer.shadowOffset = CGSizeMake(-1, 0);
    contentContainer.layer.shadowRadius = 2.5f;
    
    [parentView addSubview:contentContainer];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:contentContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentContainer]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentContainer)]];
    self.contentContainerLeading = [NSLayoutConstraint constraintWithItem:contentContainer attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [parentView addConstraint:self.contentContainerLeading];
    
    return contentContainer;
}

- (void)setupMainMenu:(MAMMainMenuViewController *)mainMenuController inViewController:(UIViewController *)parentViewController
{
    [parentViewController addChildViewController:mainMenuController];
    
    mainMenuController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [parentViewController.view addSubview:mainMenuController.view];
    
    [parentViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainMenu]|" options:0 metrics:nil views:@{@"mainMenu": mainMenuController.view}]];
    [parentViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainMenu]" options:0 metrics:nil views:@{@"mainMenu": mainMenuController.view}]];
    [parentViewController.view addConstraint:[NSLayoutConstraint constraintWithItem:mainMenuController.view attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:parentViewController.view attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0]];
    [parentViewController.view sendSubviewToBack:mainMenuController.view];
}

- (void)setupSideMenu
{
    UIView *parentView = self.view;
    
    MTPRightNavigationViewController *rightMenu = self.rightMenu;
    rightMenu.processPool = self.navigationRouter.processPool;
    self.rightMenu.delegate = self;
    [self addChildViewController:rightMenu];
    
    UIView *rightMenuView = rightMenu.view;
    rightMenuView.translatesAutoresizingMaskIntoConstraints = NO;
    [parentView addSubview:rightMenuView];
    
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightMenuView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightMenuView)]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightMenuView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightMenuView)]];
    
    self.rightMenuWidth = [NSLayoutConstraint constraintWithItem:rightMenuView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0];
    [parentView addConstraint:self.rightMenuWidth];
    
    [rightMenu configureWithThemeOptions:self.navigationRouter.themeOptionsManager];
    [rightMenu configureWithUserDetails:self.navigationRouter.currentUser];
    [rightMenu loadBackgroundTexture:self.navigationRouter.themeOptionsManager];
}

- (void)addContentViewController:(UIViewController *)contentViewController parentView:(UIView *)parentView
{
    [self addChildViewController:contentViewController];
    
    UIView *contentView = contentViewController.view;
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [parentView addSubview:contentView];
    
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentView]|" options:0 metrics:nil views:@{@"contentView": contentView}]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[contentView]|" options:0 metrics:nil views:@{@"contentView": contentView}]];
}

- (IBAction)openQRCode:(id)sender
{
    MTPMenuItem *qrCodeItem = [MTPMenuItem new];
    qrCodeItem.contentType = MTPContentTypeQRReader;
    if (qrCodeItem)
    {
        [self.navigationRouter loadViewController:qrCodeItem animated:YES];
    }
    else
    {
        DLog(@"\nqr code dictionary not found");
    }
}

- (void)checkMatches:(id)sender
{
    [self.matchCoordinator checkMatchesEnabled:^(BOOL enabled) {
        if (enabled)
        {
            NSArray *attendees = [self.navigationRouter.dataInitializer.nearbyCoordinator nearbyUsers:self.navigationRouter.currentUser.user_id];
            
            MTPMatchCoordinator *matchCoordinator = self.matchCoordinator;
            
            for (User *attendee in attendees)
            {
                if ([matchCoordinator isMatch:attendee.user_id])
                {
                    if ([matchCoordinator showedMatchAlert:attendee.user_id] == NO)
                    {
                        if ([self.nearbyCardPresenter showingMatchAlert] == NO)
                        {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.nearbyCardPresenter showMatchAlert:attendee matchProfile:[matchCoordinator matchProile:attendee.user_id]];
                                [matchCoordinator addMatchAlertID:attendee.user_id];
                            });
                            break;
                        }
                    }
                }
            }
        }
    }];
}

CGFloat menuWidth = 0.8f;

- (void)topViewControllerShouldToggleMenu:(id)sender
{
    NSLayoutConstraint *leadingEdgeStartingPoint = self.contentContainerLeading;
    
    CGFloat newOrigin;
    if ([sender isKindOfClass:[NSNumber class]])
    {
        newOrigin = 0;
    }
    else
    {
        newOrigin = leadingEdgeStartingPoint.constant < 1 ? CGRectGetWidth(self.view.frame) * menuWidth : 0;
    }
    
    [[UIApplication sharedApplication] setStatusBarHidden:(newOrigin == 0 ? NO : YES)];
    
    [self.view insertSubview:self.mainMenuController.view aboveSubview:self.rightMenu.view];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animateContentView:newOrigin];
        
        [[self childViewControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isKindOfClass:[MAMMainMenuViewController class]])
             {
                 [(MAMMainMenuViewController *)obj setVisiblityState: leadingEdgeStartingPoint.constant  == 0 ? MTPMainMenuVisibilityStateHidden : MTPMainMenuVisibilityStateVisible];
                 [(MAMMainMenuViewController *)obj configureHeaderView];
                 *stop = true;
             }
         }];
        
        [self.view setNeedsUpdateConstraints];
    });
}

- (void)animateContentView:(CGFloat)newOrigin
{
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.2f animations:^{
        self.contentContainerLeading.constant = newOrigin;
        [self.view layoutIfNeeded];
    }];
}


- (void)panelCoordinator:(MTPPanelVisibilityCoordinator *)panelCoordinator didFinishAnimation:(NSLayoutConstraint *)locationLeadingConstraint
{
    [[UIApplication sharedApplication] setStatusBarHidden:(locationLeadingConstraint.constant == 0 ? NO : YES)];
    
    [[self childViewControllers] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj isKindOfClass:[MAMMainMenuViewController class]])
         {
             [(MAMMainMenuViewController *)obj setVisiblityState:locationLeadingConstraint.constant  > 0 ? MTPMainMenuVisibilityStateVisible : MTPMainMenuVisibilityStateHidden];
             *stop = true;
         }
     }];
}

- (void)toggleEditProfileVisibility
{
    self.editProfilePresenter.userID = self.navigationRouter.currentUser.user_id;
    [self.editProfilePresenter toggleEditProfile];
}

- (void)profilePresenter:(MTPEditProfilePresenter *)profilePresenter didToggleVisiblity:(BOOL)visible
{
    if (!visible)
    {
        [self.mainMenuController configureHeaderView];
        [self.rightMenu configureWithUserDetails:self.navigationRouter.currentUser];
    }
}

- (void)sideMenu:(MTPRightNavigationViewController *)sideMenu didEditProfile:(id)sender
{
    MTPMenuItem *editProfile = [MTPMenuItem new];
    editProfile.contentType = MTPContentTypeWebView;
    editProfile.webviewURL = [NSString editProfile];
    
    [self.navigationRouter loadViewController:editProfile animated:YES];
}

- (void)toggleSideMenu:(id)sender
{
    CGFloat newOrigin = self.contentContainerLeading.constant == 0 ? CGRectGetWidth(self.view.frame) * -menuWidth : 0;
    
    [[UIApplication sharedApplication] setStatusBarHidden:(newOrigin == 0 ? NO : YES)];
    
    [self.view insertSubview:self.rightMenu.view aboveSubview:self.mainMenuController.view];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animateContentView:newOrigin];
    });
    
    
    NSNumber *userID = self.navigationRouter.currentUser.user_id;
    if (userID)
    {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString pulseProfile:userID]]];
        
        [self.rightMenu.userProfileWebView loadRequest:request];
        
        [self.rightMenu reloadWithUserID:userID];
    }
}

- (MTPRightNavigationViewController *)rightMenu
{
    if (_rightMenu == nil)
    {
        _rightMenu = [[MTPRightNavigationViewController alloc] initWithNibName:@"MTPRightNavigationViewController" bundle:nil];
    }
    
    return _rightMenu;
}


- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


@end






















