//
//  MTPBaseSplitViewController.m
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 11/24/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPBaseSplitViewController.h"
#import "MAMMainMenuViewController.h"
#import "MAMLoginViewController.h"
#import "MAMQuickLinksViewController.h"

#import "MAMBaseViewController.h"
#import "MTPBaseNavigationController.h"
#import "MTPAPIDataInitializer.h"
#import "User+Helpers.h"

#import "MTPNavigationRouter.h"
#import "MTPEditProfilePresenter.h"
#import "MTPDocumentViewerCoordinator.h"
#import "UIButton+MTPNavigationBar.h"

#import "CHAFontAwesome.h"
#import "MTPMenuItem.h"
#import "MAMStoryboardIdentifiers.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "UIViewController+NavigationItemSetup.h"
#import "MTPThemeOptionsManager.h"

#import "MTPRightNavigationViewController.h"
#import "MTPSideMenuLoader.h"

#import "MTPNavigationItemCustomizable.h"
#import "MTPAppSettingsKeys.h"
#import "UINavigationBar+MTPHelper.h"
#import "MBProgressHUD.h"
#import "UIColor+AppColors.h"

@interface MTPBaseSplitViewController () <MTPMainMenuDelegate, UISplitViewControllerDelegate, MTPEditProfileDisplayable, MTPEditProfileDelegate, MTPSideMenuDelegate>
@property (nonatomic, strong) MAMMainMenuViewController *mainMenuViewController;
@property (nonatomic, strong) MTPBaseNavigationController *contentNavigationController;
@property (nonatomic, strong) MTPEditProfilePresenter *editProfilePresenter;

@property (strong, nonatomic) MAMBaseViewController *baseViewController;

@property (strong, nonatomic) MTPSideMenuLoader *sideMenuLoader;
@property (strong, nonatomic) MTPDocumentViewerCoordinator *documentViewer;
@end

@implementation MTPBaseSplitViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.delegate = self;

    [self setupProfileEditor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMenus:) name:MTP_NavigationMenuDidUpdate object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTheme:) name:@"MTP_ThemeOptionsDidUpdateNotification" object:nil];
}

- (MTPSideMenuLoader *)sideMenuLoader
{
    if (_sideMenuLoader == nil)
    {
        _sideMenuLoader = [MTPSideMenuLoader new];
    }
    return _sideMenuLoader;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateMenus:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.mainMenuViewController.menuTableView reloadData];
        
        if ([self.contentNavigationController.topViewController isKindOfClass:[MAMQuickLinksViewController class]])
        {
            MAMQuickLinksViewController *quickLinksController = (MAMQuickLinksViewController *)self.contentNavigationController.topViewController;
            [quickLinksController updateQuickLinks:notification];
        }
    });
}

- (void)reloadTheme:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.mainMenuViewController configureHeaderView];
        
        [self.mainMenuViewController.menuTableView reloadData];
        
        [self.navigationRouter loadInitialViewController:nil];
    });
}

- (void)setupProfileEditor
{
    self.editProfilePresenter = [MTPEditProfilePresenter new];
    [self.editProfilePresenter presentEditProfileInView:self.view];
    self.editProfilePresenter.editProfileDelegate = self;
    self.editProfilePresenter.userID = self.navigationRouter.currentUser.user_id;
}

- (void)original_loadMainViewControllers
{
    self.mainMenuViewController = [self createMainMenu];
    
    self.contentNavigationController = [self createContentNavigationController];
    
    self.viewControllers = @[self.mainMenuViewController,self.contentNavigationController];
}

- (void)loadMainViewControllers
{
    self.mainMenuViewController = [self createMainMenu];
    
    self.contentNavigationController = [self createContentNavigationController];
    self.baseViewController = [self createBaseViewController];
    
    self.viewControllers = @[self.mainMenuViewController,self.baseViewController];
}

- (MAMMainMenuViewController *)createMainMenu
{
    MAMMainMenuViewController *mainMenu = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MAMMainMenuViewController"];
    mainMenu.navigationRouter = self.navigationRouter;
    mainMenu.connectionManager = self.navigationRouter.dataInitializer.myConnectionManager;
    mainMenu.mainMenuDelegate = self;
    mainMenu.editProfilePresentationTarget = self;
    
    [mainMenu configureHeaderView];
    
    return mainMenu;
}

- (MTPBaseNavigationController *)createContentNavigationController
{
    MAMQuickLinksViewController *quickLinks = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:MAMQuickLinksViewControllerIdentifier];
    quickLinks.navigationRouter = self.navigationRouter;
    
    MTPBaseNavigationController *baseNavigationController = [[MTPBaseNavigationController alloc] initWithRootViewController:quickLinks];

    return baseNavigationController;
}

#pragma mark - Protocol Conformance
#pragma mark MTPNavigationRouter
- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self loadViewController:viewController animated:animated];
}

- (void)loadViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == nil)
    {
        return;
    }
    
    NSDictionary *themeOptions = [self.navigationRouter.themeOptionsManager loadThemeOptions];
    UIColor *navigationBarColor = [UIColor mtp_colorFromString:[themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color1]];
    if (navigationBarColor)
    {
        [[self.contentNavigationController navigationBar] setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
        [[self.contentNavigationController navigationBar] setBarTintColor:navigationBarColor];
        [[self.contentNavigationController navigationBar] setShadowImage:[UIImage new]];
        
    }
    
    [self.contentNavigationController setViewControllers:@[viewController]];
    
    if ([self.contentNavigationController.parentViewController isKindOfClass:[self class]])
    {
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            [self.sideMenuLoader setupSideMenu:viewController.view inViewController:self navigationRouter:self.navigationRouter];
        }
    }
    
    [self setupMenuButton];
    [self toggleMenu:@NO];
}

- (MAMMainMenuViewController *)mainMenuViewController
{
    if (_mainMenuViewController)
    {
        return _mainMenuViewController;
    }
    
    MAMMainMenuViewController *mainMenu = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MAMMainMenuViewController"];
    mainMenu.navigationRouter = _navigationRouter;
    mainMenu.connectionManager = _navigationRouter.dataInitializer.myConnectionManager;
    mainMenu.mainMenuDelegate = self;
    [mainMenu configureHeaderView];
    
    _mainMenuViewController = mainMenu;
    
    return _mainMenuViewController;
}

- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadLogin:(UIViewController *)viewController
{
    self.maximumPrimaryColumnWidth = 0;
    
    self.contentNavigationController.viewControllers = @[viewController];
    [self.mainMenuViewController menuSelectable:NO];
    
    [self toggleMenu:@NO];
}

- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoginSSO:(NSURL *)url
{
    [self handleLogin:url];
}

- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadMainScreen:(UIViewController *)viewController
{
    self.maximumPrimaryColumnWidth = 300;
    
    [self.contentNavigationController setNavigationBarHidden:NO];
    [self.mainMenuViewController menuSelectable:YES];
    
    [self.mainMenuViewController configureHeaderView];
//    [self.mainMenuViewController updateNavigationItems];
    
    [self loadViewController:viewController animated:NO];
    
    [self toggleMenu:@NO];
}

- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadPhotoUpload:(UIViewController *)viewController
{
    if ([viewController respondsToSelector:@selector(setCustomLeftBarItem:)])
    {
        id customizableLeftBarItem = (id)viewController;
        
        UIBarButtonItem *customBackButton = [UIButton refreshMenuButton:@{@"imageName": @"backIcon"}
                                                                 target:viewController
                                                               selector:@selector(returnPrevious:)];
        [customBackButton setTarget:viewController];
        [customBackButton setAction:@selector(returnPrevious:)];
        
        [customizableLeftBarItem setCustomLeftBarItem:customBackButton];
    }
    
    [self.contentNavigationController pushViewController:viewController animated:true];
}

- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didPush:(UIViewController *)viewController
{
    if (viewController)
    {
        [self.contentNavigationController pushViewController:viewController animated:YES];
    }
    else
    {
        DLog(@"\nview controller was nil %@",viewController);
    }
}

- (void)navigationRouterDidGoBack:(MTPNavigationRouter *)navigationRouter
{
    [self.contentNavigationController popViewControllerAnimated:YES];
}

- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadDocument:(NSURL *)remoteUrl
{
    if (self.documentViewer == nil)
    {
        MTPDocumentViewerCoordinator *documentViewer = [MTPDocumentViewerCoordinator new];
        self.documentViewer = documentViewer;
    }
    self.documentViewer.titleTextColor = [UIColor mtp_colorFromString:[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color25]];
    
    if ([self.documentViewer fileExists:remoteUrl] == NO)
    {
        MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        progress.label.text = @"Fetching Document";
        
        __weak typeof(&*self)weakSelf = self;
        [self.documentViewer fetchDocument:remoteUrl completion:^(NSURL *documentLocalUrl, NSError *fetchError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [progress hideAnimated:YES];
                
                if (fetchError)
                {
                    DLog(@"\nfetch error %@",fetchError);
                }
                else
                {
                    [weakSelf openDocument:documentLocalUrl];
                }
            });
        }];
    }
    else
    {
        NSURL *localSave = [self.documentViewer localSaveLocation:[remoteUrl.lastPathComponent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [self openDocument:localSave];
    }
}

- (void)openDocument:(NSURL *)localFileUrl
{
    if (localFileUrl == nil) {
        return;
    }
    [self.documentViewer openDocument:localFileUrl presenter:self];
}

- (void)mainMenu:(MAMMainMenuViewController *)mainMenu didSelectMainMenuItem:(MTPMenuItem *)menuItem
{
    [self.navigationRouter loadViewController:menuItem animated:true];
}

- (void)toggleEditProfileVisibility
{
    if (self.editProfilePresenter.userID == nil && self.navigationRouter.currentUser.user_id)
    {
        self.editProfilePresenter.userID = self.navigationRouter.currentUser.user_id;
    }
    [self.editProfilePresenter toggleEditProfile];
}

- (void)profilePresenter:(MTPEditProfilePresenter *)profilePresenter didToggleVisiblity:(BOOL)visible
{
    if (!visible)
    {
        [self.mainMenuViewController configureHeaderView];
    }
}

- (void)topViewControllerShouldToggleMenu:(id)sender
{
    [self toggleMenu:nil];
}

- (void)setupMenuButton
{
    if ([self.contentNavigationController.parentViewController isKindOfClass:[MAMBaseViewController class]])
    {
        [self setupLeftBarButton:nil];
        
        MAMBaseViewController *baseViewController = (MAMBaseViewController *)self.contentNavigationController.parentViewController;
        if (baseViewController.contentContainerLeading)
        {
            [baseViewController topViewControllerShouldToggleMenu:nil];
        }
        else
        {
            DLog(@"\ntoggling not necessary when loading view controller");
        }
    }
    else
    {
        DLog(@"\nnot contained in a base view controller %@", self.contentNavigationController);
    }
}

- (void)toggleMenu:(id)sender
{
    if ([self.contentNavigationController.parentViewController isKindOfClass:[MAMBaseViewController class]])
    {
        MAMBaseViewController *baseViewController = (MAMBaseViewController *)self.contentNavigationController.parentViewController;
        if (baseViewController.contentContainerLeading)
        {
            [baseViewController topViewControllerShouldToggleMenu:sender];
        }
        else
        {
            DLog(@"\ntoggling not necessary when loading view controller");
        }
    }
    else
    {
        DLog(@"\nnot contained in a base view controller %@", self.contentNavigationController);
    }
}

- (void)setupLeftBarButton:(UIBarButtonItem *)leftBarButton
{
    if ([[self.contentNavigationController topViewController] respondsToSelector:@selector(setCustomLeftBarItem:)] && [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad)
    {
        UIBarButtonItem *toggleMenuButton = [[self.contentNavigationController topViewController] customBarButtonItem:@selector(toggleMenu:)];
        [(id<MTPNavigationItemCustomizable>)[self.contentNavigationController topViewController] setCustomLeftBarItem:toggleMenuButton];
    }
}

- (void)toggleSideMenu:(id)sender
{
    if (self.sideMenuLoader.rightMenuLeading.constant == 0)
    {
        [self.sideMenuLoader showMenu];
    }
    else
    {
        [self.sideMenuLoader hideMenu];
    }
}

#pragma mark UISplitViewController

- (UIViewController *)primaryViewControllerForCollapsingSplitViewController:(UISplitViewController *)splitViewController
{
    MAMBaseViewController *baseViewController = self.baseViewController;
    [baseViewController addMainMenu:self.mainMenuViewController];
    
    [self.contentNavigationController setNavigationBarHidden:NO];
    [self setupLeftBarButton:nil];
    
    // on initial load, it provides the menu button for iphone layout
    if ([self.contentNavigationController.topViewController respondsToSelector:@selector(setMenuToggler:)])
    {
        [(id)self.contentNavigationController.topViewController setMenuToggler:baseViewController];
        [(id<MTPNavigationItemCustomizable>)self.contentNavigationController.topViewController setupLeftBarButton];
    }
    else
    {
        
    }
    self.viewControllers = @[baseViewController];
    
    return baseViewController;
}

- (UIViewController *)primaryViewControllerForExpandingSplitViewController:(UISplitViewController *)splitViewController
{
    return self.mainMenuViewController;
}

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    return YES;
}

- (MAMBaseViewController *)createBaseViewController
{
    MAMBaseViewController *baseViewController = [MAMBaseViewController new];
    baseViewController.navigationRouter = self.navigationRouter;
    baseViewController.currentUser = self.navigationRouter.currentUser;
    baseViewController.connectionManager = self.navigationRouter.dataInitializer.myConnectionManager;
    
    baseViewController.contentViewController = self.contentNavigationController;
    [baseViewController addChildViewController:self.contentNavigationController];
    
    [baseViewController.view sendSubviewToBack:baseViewController.mainMenuController.view];

    return baseViewController;
}

#pragma mark - IBActions

#pragma mark - Helper Methods

- (void)handleLogin:(NSURL *)url
{
    if ([self.contentNavigationController.topViewController isKindOfClass:[MAMLoginViewController class]])
    {
        __block NSString *email = nil;
        
        NSString *queryString = url.query;
        NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
        [queryComponents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSArray *singleQuery = [obj componentsSeparatedByString:@"="];
            if (singleQuery.count == 2)
            {
                NSString *key = singleQuery.firstObject;
                NSString *value = singleQuery.lastObject;
                if ([key isEqualToString:@"email"] && value.length > 0)
                {
                    email = value;
                    *stop = true;
                }
            }
        }];
        
        MAMLoginViewController *loginVC = (MAMLoginViewController *)self.contentNavigationController.topViewController;
        [loginVC login:email];
    }
}

- (void)openQRCode:(id)sender
{
    [self.navigationRouter openQRCode];
}

#pragma mark - Initial Setup

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end


