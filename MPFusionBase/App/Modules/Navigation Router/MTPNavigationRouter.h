//
//  MTPNavigationRouter.h
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 11/19/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>
#import "MTPAlertManager.h"
#import "MTPMainMenuTogglable.h"

@class MTPNavigationRouter,MTPMenuItem,NSManagedObjectContext,User,MTPBaseNavigationController,MTPLoginClient,MAMLoginViewController,MTPAPIDataInitializer,MTPMenuItemManager,MTPThemeOptionsManager,WKProcessPool;

#pragma mark - Protocol Declarations
@protocol MTPNavigationRouterDelegate <MTPAlertDelegate>
- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadViewController:(UIViewController *)viewController animated:(BOOL)animated;
@optional
- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadLogin:(UIViewController *)viewController;
- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoginSSO:(NSURL *)url;
- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadMainScreen:(UIViewController *)viewController;
- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadPhotoUpload:(UIViewController *)viewController;
- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didLoadDocument:(NSURL *)remoteUrl;
- (void)navigationRouter:(MTPNavigationRouter *)navigationRouter didPush:(UIViewController *)viewController;
- (void)navigationRouterDidGoBack:(MTPNavigationRouter *)navigationRouter;
@end

#pragma mark - MTPNavigationRouter Interface
@interface MTPNavigationRouter : NSObject <MTPNavigationRouterDelegate>

#pragma mark Property Declarations
@property (nonatomic, weak) id <MTPNavigationRouterDelegate,MTPMainMenuTogglable> routerDelegate;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSManagedObjectContext *rootObjectContext;
@property (nonatomic, strong) MTPAPIDataInitializer *dataInitializer;
@property (strong, nonatomic) MTPMenuItemManager *menuItemManager;
@property (strong, nonatomic) MTPThemeOptionsManager *themeOptionsManager;
@property (strong, nonatomic) WKProcessPool *processPool;

#pragma mark Instance Method Declarations
- (instancetype)initWithRouterDelegate:(id<MTPNavigationRouterDelegate,MTPMainMenuTogglable>)routerDelegate;

- (void)loadInitialViewController:(void(^)(UIViewController *))completionHandler;

#pragma mark Generic View Controller Loading
- (void)loadViewController:(MTPMenuItem *)menuItem animated:(BOOL)animated;

- (UIViewController *)configureViewController:(MTPMenuItem *)dataSource
                                  currentUser:(User *)currentUser
                         managedObjectContext:(NSManagedObjectContext *)rootObjectContext;

#pragma mark Specific View Controller Loading
- (UIViewController *)loadLogin:(NSManagedObjectContext *)rootObjectContext;
- (UIViewController *)loadMainScreen:(User *)currentUser;

- (void)loadSearch:(NSString *)searchQuery;

- (void)openPhotoUploads:(NSURL *)url profile:(BOOL)profileUpload video:(BOOL)videoUpload;
- (void)openQRCode;
- (void)openDocument:(NSURL *)url;
- (void)openPage:(NSURL *)url;
- (void)pushPage:(NSURL *)url;
- (void)goBack;
- (void)dashboard;
- (void)scheduleEvent:(NSURL *)eventURL;

// SSO handling
- (void)handleLogin:(NSURL *)url;

@end