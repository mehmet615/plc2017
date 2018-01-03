//
//  MTPLoginNotificationHandler.m
//  MeetingPlayBaseiPhoneProject
//
//  Created by MeetingPlay on 12/2/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPLoginNotificationHandler.h"

#import "MTPNavigationRouter.h"
#import "MTPAlertManager.h"
#import "MTPLoginClient.h"
#import "MTPBeaconSightingManager.h"
#import "MDBeaconManager.h"
#import "MDMyConnectionManager.h"
#import "MTPSponsorManager.h"
#import "User+Helpers.h"
#import "MTPDLogDefine.h"

#import "MTPAPIDataInitializer.h"
#import "MTPOneSignalInterface.h"
#import "OneSignal.h"
#import "EventKeys.h"
#import "MTPPassCreator.h"
#import <WebKit/WebKit.h>

@implementation MTPLoginNotificationHandler

- (instancetype)init
{
    if (self = [super init])
    {
        [self registerForNotifications];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLoginNotification:)
                                                 name:MTP_LoginNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLogoutNotification:)
                                                 name:MTP_LogoutNotification
                                               object:nil];
}

- (void)didReceiveLoginNotification:(NSNotification *)notification
{
    NSNumber *userID = [[notification userInfo] objectForKey:kUserID];
    if (userID)
    {
        self.navigationRouter.currentUser = [User findUser:userID
                                                   context:self.navigationRouter.rootObjectContext];
        self.navigationRouter.currentUser.loggedIn = @(true);
        [self.navigationRouter.currentUser saveToPersistentStore:self.navigationRouter.rootObjectContext];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.navigationRouter.currentUser.user_id forKey:kUserID];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kLoggedIn];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.navigationRouter.dataInitializer.beaconManager.currentUser = self.navigationRouter.currentUser;
        [self.navigationRouter.dataInitializer.beaconManager getEventBeacons];
    }
}

- (void)didReceiveLogoutNotification:(NSNotification *)notification
{
    [self.navigationRouter.dataInitializer.myConnectionManager flushAll];
    
    self.navigationRouter.currentUser.loggedIn = @(false);
    [self.navigationRouter.currentUser saveToPersistentStore:self.navigationRouter.rootObjectContext];
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kUserID];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kLoggedIn];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:MTP_RegPass_SerialNumber];
    
    self.navigationRouter.currentUser = nil;

    [self clearWebCaches];
    
    [self.navigationRouter loadLogin:self.navigationRouter.rootObjectContext];
}

- (void)clearWebCaches
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4)
    {
        NSSet *websiteDataTypes = [NSSet setWithArray:@[WKWebsiteDataTypeDiskCache,
                                                        WKWebsiteDataTypeOfflineWebApplicationCache,
                                                        WKWebsiteDataTypeMemoryCache,
                                                        WKWebsiteDataTypeLocalStorage,
                                                        WKWebsiteDataTypeCookies,
                                                        WKWebsiteDataTypeSessionStorage,
                                                        WKWebsiteDataTypeIndexedDBDatabases,
                                                        WKWebsiteDataTypeWebSQLDatabases
                                                        ]];
        //// All kinds of data
//        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        //// Date from
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        //// Execute
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            // Done
//            DLog(@"\ndebugging message %@",websiteDataTypes);
        }];
    }
    
    self.navigationRouter.processPool = [WKProcessPool new];
}

@end
