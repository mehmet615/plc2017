//
//  AppDelegate.m
//
//  Created by MeetingPlay on 4/10/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

// Base application release version 1.0.3.18

#import "AppDelegate.h"
#import "MAMRootNavigationViewController.h"
#import "MTPNavigationRouter.h"

// Managers
#import "MTPCoreDataInitializationHelper.h"
#import "MTPApplicationDefaultsManager.h"
#import "MTPRemoteNotificationHandler.h"
#import "MTPAlertManager.h"

#import "MTPAPIDataInitializer.h"
#import "MTPGimbalInitializer.h"

#import "NSObject+EventDefaultsHelpers.h"
#import "NSObject+MTPFileManager.h"

#import "MTPAppSettingsKeys.h"
#import "MTPLoginNotificationHandler.h"
#import "MTPBaseSplitViewController.h"
#import "MTPMenuItemManager.h"
#import "MTPThemeOptionsManager.h"
#import "MTPOneSignalInterface.h"

#import "AFNetworkReachabilityManager.h"
#import "MTPApplicationDefaultsConstants.h"

// Services
#import <Gimbal/Gimbal.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "OneSignal.h"

@interface AppDelegate ()
@property (nonatomic, strong) MTPNavigationRouter *navigationRouter;
@property (nonatomic, strong) MTPBaseSplitViewController *baseSplitViewController;

@property (nonatomic, strong) MTPCoreDataInitializationHelper *coreDataHelper;
@property (nonatomic, strong) MTPApplicationDefaultsManager *defaultsManager;
@property (nonatomic, strong) MTPRemoteNotificationHandler *notificationHandler;
@property (nonatomic, strong) MTPAPIDataInitializer *apiInitializer;
@property (nonatomic, strong) MTPGimbalInitializer *gimbalInitializer;
@property (nonatomic, strong) MTPLoginNotificationHandler *loginNotificationHandler;
@property (nonatomic, strong) MTPAlertManager *alertManager;

@property (strong, nonatomic) MTPMenuItemManager *menuItemManager;
@property (strong, nonatomic) MTPThemeOptionsManager *themeOptionsManager;

@property (nonatomic, strong) NSURL *cacheDirectory;
@end

@implementation AppDelegate

NSString *const PROJECT_NAME = @"MeetingPlayBaseProject";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLoginNotification:)
                                                 name:MTP_LoginNotification
                                               object:nil];
    
    // start AFNetworkingReachabilityMonitor
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [self configureApplicationWithApplicationDelegate:self];
    
    self.baseSplitViewController.navigationRouter = self.navigationRouter;
    [self.baseSplitViewController loadMainViewControllers];
    self.window.rootViewController = self.baseSplitViewController;
    
    [self.navigationRouter loadInitialViewController:nil];
    
    return YES;
}

- (void)configureApplicationWithApplicationDelegate:(AppDelegate *)applicationDelegate
{
    self.coreDataHelper = [[MTPCoreDataInitializationHelper alloc] initWithManagedObjectModelName:@"MarriottTPC"
                                                                                  sqliteStoreName:@"MarriottTPC"];
    
    NSManagedObjectContext *rootManagedObjectContext = self.coreDataHelper.managedObjectContext;
    
    // setup navigation router
    self.baseSplitViewController = [MTPBaseSplitViewController new];
    self.navigationRouter = [[MTPNavigationRouter alloc] initWithRouterDelegate:self.baseSplitViewController];
    
    self.navigationRouter.rootObjectContext = rootManagedObjectContext;
    self.navigationRouter.currentUser = [User currentUser:rootManagedObjectContext];
    
    self.defaultsManager = [MTPApplicationDefaultsManager defaultsManager:applicationDelegate];
    self.menuItemManager = [self.defaultsManager menuItemManager];
    self.themeOptionsManager = [self.defaultsManager themeOptionsManager];
    
    self.apiInitializer = [MTPAPIDataInitializer dataInitializer:rootManagedObjectContext];
    
    [self setupThirdPartySDKs];
    
    self.gimbalInitializer = [[MTPGimbalInitializer alloc] initWithManagedObjectContext:rootManagedObjectContext];
    self.gimbalInitializer.beaconSightingManager.beaconManager = self.apiInitializer.beaconManager;
    self.gimbalInitializer.beaconSightingManager.beaconManager.matchCoordinator = self.apiInitializer.matchCoordinator;
    
    [self.apiInitializer fetchInitialAPIData];
    self.navigationRouter.dataInitializer = self.apiInitializer;
    self.navigationRouter.menuItemManager = self.menuItemManager;
    self.navigationRouter.themeOptionsManager = self.themeOptionsManager;
    
    // alert manager will use the navigation controllers session manager that was initialized in
    // the api initializer to show session details
    self.alertManager = [[MTPAlertManager alloc] initWithDelegate:self.navigationRouter];
    self.alertManager.sessionManager = self.apiInitializer.sessionManager;
    self.apiInitializer.beaconManager.alertManager = self.alertManager;
    
    self.notificationHandler = [MTPRemoteNotificationHandler notificationHandler:applicationDelegate
                                                                navigationRouter:self.navigationRouter];
    
    self.loginNotificationHandler = [MTPLoginNotificationHandler new];
    self.loginNotificationHandler.navigationRouter = self.navigationRouter;
    
    
    if (self.navigationRouter.themeOptionsManager)
    {
        [self.navigationRouter.themeOptionsManager fetchThemeOptions:nil];
    }
}

- (void)setupThirdPartySDKs
{
    // setup gimbal
#ifdef DEBUG
#else
    if (MTP_GIMBAL_API_KEY.length == 0)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Invalid Gimbal App ID"];
    }
#endif
    [Gimbal setAPIKey:MTP_GIMBAL_API_KEY options:nil];
    
    // setup fabric
    [Fabric with:@[[Crashlytics class]]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
//    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (self.apiInitializer)
    {
        [self.apiInitializer fetchAllSessions];
    }
    
    [self.themeOptionsManager fetchThemeOptions:nil];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (self.navigationRouter && self.navigationRouter.routerDelegate)
    {
        if ([[url host] rangeOfString:@"photoUpload" options:NSCaseInsensitiveSearch].location == 0)
        {
            [self.navigationRouter openPhotoUploads:url profile:NO video:NO];
        }
        else if ([[url host] rangeOfString:@"videoUpload" options:NSCaseInsensitiveSearch].length)
        {
            [self.navigationRouter openPhotoUploads:url profile:NO video:YES];
        }
        else if ([[url host] rangeOfString:@"profilePhotoUpload" options:NSCaseInsensitiveSearch].length)
        {
            [self.navigationRouter openPhotoUploads:url profile:YES video:NO];
        }
        else if ([[url host] rangeOfString:@"scanner" options:NSCaseInsensitiveSearch].length)
        {
            [self.navigationRouter openQRCode];
        }
        else if ([[url host] rangeOfString:@"login" options:NSCaseInsensitiveSearch].length)
        {
            [self.navigationRouter handleLogin:url];
        }
        else if ([[url host] rangeOfString:@"navigation" options:NSCaseInsensitiveSearch].length)
        {
            [self.navigationRouter openPage:url];
        }
        else if ([[url host] rangeOfString:@"documentViewer" options:NSCaseInsensitiveSearch].length)
        {
            [self.navigationRouter openDocument:url];
        }
        else if ([[url host] rangeOfString:@"dashboard" options:NSCaseInsensitiveSearch].length)
        {
            [self.navigationRouter dashboard];
        }
        else if ([[url host] rangeOfString:@"pushPage" options:NSCaseInsensitiveSearch].length)
        {
            [self.navigationRouter pushPage:url];
        }
        else if ([[url host] rangeOfString:@"goBack" options:NSCaseInsensitiveSearch].length)
        {
            [self.navigationRouter goBack];
        }
        else if ([[url host] rangeOfString:@"calendar" options:NSCaseInsensitiveSearch].length)
        {
            [self.navigationRouter scheduleEvent:url];
        }
    }
    else
    {
        NSLog(@"%s\n[%s]: Line %i] launch failed: navigation router %@\nrouterDelegate %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
              self.navigationRouter,self.navigationRouter.routerDelegate);
    }
    
    return true;
}


#pragma mark - Core Data Saving support
- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.coreDataHelper.managedObjectContext;
    if (managedObjectContext != nil)
    {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}

- (void)didReceiveLoginNotification:(NSNotification *)notification
{
    [self setupOneSignal:nil];
}
@end

@implementation AppDelegate (RemoteNotificationRegistration)

#pragma mark - Remote Notification Registration
- (void)registerForRemoteNotifications
{
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                         settingsForTypes:(UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound)
                                                                         categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSData *previousDeviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:MTP_APNSDeviceToken];
    if (previousDeviceToken.length > 0 && [previousDeviceToken isEqualToData:deviceToken] == false)
    {
        DLog(@"\nremove the device token from the API %@",deviceToken);
    }
    [[NSUserDefaults standardUserDefaults] setValue:deviceToken forKey:MTP_APNSDeviceToken];
    
    [MTPOneSignalInterface signUpForNotifications:self.navigationRouter.currentUser.user_id
                                   attendeeTypeID:self.navigationRouter.currentUser.attendeetypeid];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"%s [%s]: Line %i]\nFailed to get token, error: %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,error);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *notificationInfo = notification.userInfo;
    NSString *eventType = [notificationInfo objectForKey:@"eventType"];
    if ([eventType isEqualToString:kEventTypeSession])
    {
        NSString *scheduleID = [notificationInfo objectForKey:@"details"];
        if (scheduleID.length > 0)
        {
            [self.navigationRouter openSessionDetails:scheduleID];
        }
    }
    else if ([eventType isEqualToString:kEventTypeSessionPoll])
    {
        NSString *pollURL = [notificationInfo objectForKey:@"details"];
        if (pollURL.length > 0)
        {
            [self.navigationRouter openPoll:[NSURL URLWithString:pollURL] realTimePoll:@(0)];
        }
    }
    else
    {
        DLog(@"\nnotificationInfo %@", notificationInfo);
    }
}

- (void)setupOneSignal:(NSDictionary *)launchOptions
{
#ifdef DEBUG
#else
    if (MTP_ONESIGNAL_APP_ID.length == 0)
    {
        [NSException raise:NSInternalInconsistencyException format:@"Invalid OneSignal App ID"];
    }
#endif
    [OneSignal initWithLaunchOptions:launchOptions appId:MTP_ONESIGNAL_APP_ID handleNotificationReceived:^(OSNotification *notification) {
        if (notification.payload.rawPayload)
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.notificationHandler processUserInfo:notification.payload.rawPayload];
            });
        }
    } handleNotificationAction:nil settings:@{kOSSettingsKeyInFocusDisplayOption:@(OSNotificationDisplayTypeNone)}];
}

@end
