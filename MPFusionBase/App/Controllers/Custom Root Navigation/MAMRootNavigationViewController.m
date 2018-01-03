//
//  MAMRootNavigationViewController.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/13/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMRootNavigationViewController.h"

#import "MAMLoginViewController.h"
#import "MAMBaseViewController.h"

#import "MTPNavigationRouter.h"
#import "MTPAPIDataInitializer.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "MTPAppSettingsKeys.h"

#import "NSString+MTPWebViewURL.h"

@interface MAMRootNavigationViewController ()

@end

@implementation MAMRootNavigationViewController
#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    
    self.navigationBarHidden = true;
}

#pragma mark - Protocol Conformance
- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController)
    {
        [self loadBaseViewController:viewController animated:NO];
    }
    else
    {
        DLog(@"\nno view controller found to load %@", navigationRouter);
    }
}

- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadLogin:(UIViewController *)viewController
{
    [self setViewControllers:@[viewController] animated:NO];
}

- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadMainScreen:(UIViewController *)viewController
{
    [self loadBaseViewController:viewController animated:NO];
}

- (void)loadBaseViewController:(UIViewController *)rootViewController animated:(BOOL)animated
{
    MTPBaseNavigationController *baseNavigationController = [[MTPBaseNavigationController alloc] initWithRootViewController:rootViewController];
    baseNavigationController.view.translatesAutoresizingMaskIntoConstraints = false;
    
    MAMBaseViewController *baseViewController = [MAMBaseViewController new];
    baseViewController.navigationRouter = self.applicationRouter;
    baseViewController.currentUser = self.applicationRouter.currentUser;
    baseViewController.connectionManager = self.applicationRouter.dataInitializer.myConnectionManager;
    baseViewController.contentViewController = baseNavigationController;
    
    [self setViewControllers:@[baseViewController] animated:animated];
    
    [(id<MTPMainMenuTogglable>)baseViewController topViewControllerShouldToggleMenu:@(0)];
}

#pragma mark - Alternate View Controller Loading
/*
 *  Used in SSO-Login apps to bypass normal authentication method
 */
- (void)handleLogin:(NSURL *)url
{
    if ([self.topViewController isKindOfClass:[MAMLoginViewController class]])
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
        
        MAMLoginViewController *loginVC = (MAMLoginViewController *)self.topViewController;
        [loginVC login:email];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end





