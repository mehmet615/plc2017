//
//  MTPRemoteNotificationHandler.h
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/3/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate, MTPNavigationRouter;

@interface MTPRemoteNotificationHandler : NSObject

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) MTPNavigationRouter *navigationRouter;

+ (instancetype)notificationHandler:(AppDelegate *)appDelegate
                   navigationRouter:(MTPNavigationRouter *)navigationRouter;

- (instancetype)initWithAppDelegate:(AppDelegate *)appDelegate
                   navigationRouter:(MTPNavigationRouter *)navigationRouter;

- (void)launchWithOptions:(NSDictionary *)launchOptions;
- (void)processUserInfo:(NSDictionary*)userInfo;

- (void)uploadDeviceToken:(NSDictionary *)parameters;
- (void)uploadDeviceToken:(NSDictionary *)parameters userID:(NSNumber *)userID;

@end
