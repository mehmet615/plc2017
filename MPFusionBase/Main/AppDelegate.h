//
//  AppDelegate.h
//
//  Created by MeetingPlay on 4/10/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)saveContext;

@end

@interface AppDelegate (RemoteNotificationRegistration)

- (void)registerForRemoteNotifications;
- (void)setupOneSignal:(NSDictionary *)launchOptions;
@end


