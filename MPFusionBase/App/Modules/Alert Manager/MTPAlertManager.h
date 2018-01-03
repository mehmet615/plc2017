//
//  MTPAlertManager.h
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/9/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SIAlertView.h"
#import "EventKeys.h"

@class MTPNavigationRouter, MTPSessionManager;

@protocol MTPAlertDelegate <NSObject>
@optional
- (void)openPoll:(NSURL *)destinationUrl
   realTimePoll:(NSNumber *)realTimePoll;
- (void)openSessionDetails:(NSString *)scheduleID;
@end

@interface MTPAlertManager : NSObject

@property (nonatomic, weak) id <MTPAlertDelegate> alertDelegate;
@property (nonatomic, strong) MTPSessionManager *sessionManager;

@property (assign, nonatomic, getter = isShowingAlert) BOOL showingAlert;
@property (strong, nonatomic) UILocalNotification *localNotification;
@property (assign, nonatomic, getter = isShowingLocalNotification) BOOL showingLocalNotification;
@property (assign, nonatomic, getter = inBackgroundMode) BOOL backgroundMode;

+ (instancetype)alertManager:(id<MTPAlertDelegate>)alertDelegate;
- (instancetype)initWithDelegate:(id<MTPAlertDelegate>)alertDelegate;

- (void)showAlertForBeaconID:(NSString *)beaconID withContent:(NSDictionary *)content forEvent:(NSString *)eventType;

@end
