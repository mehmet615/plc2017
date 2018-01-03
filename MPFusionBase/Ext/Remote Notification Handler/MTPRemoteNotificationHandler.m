//
//  MTPRemoteNotificationHandler.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/3/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPRemoteNotificationHandler.h"
#import "MTPNavigationRouter.h"

#import "AppDelegate.h"
#import "SIAlertView.h"
#import "User+Helpers.h"
#import "MTPOneSignalInterface.h"

#import "NSObject+EventDefaultsHelpers.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSURLSession+MTPCategory.h"
#import "MTPAppSettingsKeys.h"

@implementation MTPRemoteNotificationHandler

+ (instancetype)notificationHandler:(AppDelegate *)appDelegate
                   navigationRouter:(MTPNavigationRouter *)navigationRouter
{
    return [[MTPRemoteNotificationHandler alloc] initWithAppDelegate:appDelegate
                                                    navigationRouter:navigationRouter];
}

- (instancetype)initWithAppDelegate:(AppDelegate *)appDelegate
                   navigationRouter:(MTPNavigationRouter *)navigationRouter
{
    self = [super init];
    if (self) {
        _appDelegate = appDelegate;
        _navigationRouter = navigationRouter;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerDeviceID:) name:MTP_LoginNotification object:nil];
}

- (void)registerDeviceID:(NSNotification *)notification
{
    NSNumber *userID = [[notification userInfo] objectForKey:@"user_id"];
    NSString *deviceToken = [self.userDefaults objectForKey:MTP_APNSDeviceToken];
    
    if (userID && deviceToken)
    {
        NSDictionary *parameters = @{@"device_token":[NSString stringWithFormat:@"%@",deviceToken]};
        [self uploadDeviceToken:parameters userID:userID];
    }
    else
    {
        [self.appDelegate registerForRemoteNotifications];
    }
}

- (void)launchWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (remoteNotification)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self processNotification:remoteNotification];
        });
    }
}

- (void)processNotification:(NSDictionary *)remoteNotification
{
    /*
    NSLog(@"%s [%s]: Line %i]\n"
          "%@",
          __FILE__,__PRETTY_FUNCTION__,__LINE__,
          remoteNotification);
     */
    [self processUserInfo:remoteNotification];
}

- (void)processUserInfo:(NSDictionary*)userInfo
{
//    NSLog(@"\n%s - line %d: userInfo %@",__PRETTY_FUNCTION__, __LINE__, userInfo);
    
    NSString *typeOfCommunication = [[userInfo[@"custom"] objectForKey:@"a"] objectForKey:@"type"];
    if ([typeOfCommunication isEqualToString:@"connection"])
    {
        [self processUserConnection:userInfo];
    }
    else if ([typeOfCommunication isEqualToString:@"notification"])
    {
        [self showAlert:userInfo];
    }
    else if ([typeOfCommunication isEqualToString:@"poll"])
    {
        [self loadPoll:userInfo ];
    }
    else {
        [self showAlert:userInfo];
    }
}

- (void)showAlert:(NSDictionary *)userInfo
{
    NSString *title = [[userInfo[@"custom"] objectForKey:@"a"] objectForKey:@"title"];
    if (title.length > 0)
    {
        title = [[userInfo[@"custom"] objectForKey:@"a"] objectForKey:@"title"];
    }
    else
    {
        title = @"Conference Alert";
    }
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                     andMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
    
    [alertView addButtonWithTitle:@"OK"
                             type:SIAlertViewButtonTypeCancel
                          handler:nil];
    
    [alertView show];
}

- (void)loadPoll:(NSDictionary*)userInfo
{
    NSLog(@"\n%s - line %d",__PRETTY_FUNCTION__, __LINE__);
    if (![[[userInfo[@"custom"] objectForKey:@"a"] allKeys] containsObject:@"target"])
    {
        NSLog(@"\n%s - line %d: doesn't contain target",__PRETTY_FUNCTION__, __LINE__);
        return;
    }
    
    if ([[[userInfo[@"custom"] objectForKey:@"a"] objectForKey:@"target"] isEqualToString:@"app"])
    {
        if ([self.userDefaults boolForKey:kLoggedIn] == false)
        {
            NSLog(@"\n%s - line %d - not logged in",__PRETTY_FUNCTION__, __LINE__);
        }
        else
        {
            NSString *title = [[userInfo[@"custom"] objectForKey:@"a"] objectForKey:@"title"];
            if (title.length > 0)
            {
                title = [[userInfo[@"custom"] objectForKey:@"a"] objectForKey:@"title"];
            }
            else
            {
                title = @"Conference Alert";
            }
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title
                                                             andMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
            
            [alertView addButtonWithTitle:@"View" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView)
             {
                 NSURL *pollURL = [NSURL URLWithString:[[userInfo[@"custom"] objectForKey:@"a"] objectForKey:@"url"]];
                 [self.navigationRouter openPoll:pollURL realTimePoll:@(true)];
             }];
            
            [alertView addButtonWithTitle:@"Cancel"
                                     type:SIAlertViewButtonTypeCancel
                                  handler:nil];
            
            [alertView show];
        }
    }
    else
    {
        NSLog(@"\n%s - line %d",__PRETTY_FUNCTION__, __LINE__);
        NSURL *url = [NSURL URLWithString:[[userInfo[@"custom"] objectForKey:@"a"] objectForKey:@"url"]];
        [self.appDelegate application:[UIApplication sharedApplication] openURL:url sourceApplication:nil annotation:nil];
    }
}

- (void)processUserConnection:(NSDictionary*)userInfo
{
    DLog(@"\ndead feature");
}

#pragma mark - API Service
- (void)uploadDeviceToken:(NSDictionary *)parameters
{
    [self uploadDeviceToken:parameters userID:nil];
}

- (void)uploadDeviceToken:(NSDictionary *)parameters userID:(NSNumber *)userID
{
    NSNumber *loggedInUserID = self.navigationRouter.currentUser.user_id ? self.navigationRouter.currentUser.user_id : userID;

    if (loggedInUserID)
    {
        NSString *deviceTokenUploadURLString = [NSString stringWithFormat:[NSString userDevice],loggedInUserID];
        
        NSMutableURLRequest *deviceTokenUploadRequest = [NSURLSession defaultRequestMethod:@"PUT"
                                                                                       URL:deviceTokenUploadURLString
                                                                                parameters:parameters];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:deviceTokenUploadRequest
                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
          {
              id responseObject = [NSURLSession serializeJSONData:data response:response error:error];
              NSLog(@"\ndevice token upload response %@", responseObject);
          }] resume];
        
        
        NSData *deviceToken = [self.userDefaults objectForKey:MTP_APNSDeviceToken];
        if (deviceToken.length > 0)
        {
            [MTPOneSignalInterface signUpForNotifications:loggedInUserID attendeeTypeID:self.navigationRouter.currentUser.attendeetypeid];
        }
        else
        {
            DLog(@"\nno device token found");
        }
    }
    else
    {
        DLog(@"\nno logged in user ID found %@", self.navigationRouter.currentUser);
    }
}







@end
