//
//  MTPApplicationDefaultsManager.h
//
//  Created by MeetingPlay on 4/3/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDelegate,MTPMenuItemManager,MTPThemeOptionsManager;

@interface MTPApplicationDefaultsManager : NSObject

@property (nonatomic, weak) AppDelegate *appDelegate;
@property (nonatomic, strong) NSDictionary *eventDefaults;

+ (instancetype)defaultsManager:(AppDelegate *)appDelegate;

- (void)setupDefaults:(NSDictionary *)eventDefaults;

- (MTPMenuItemManager *)menuItemManager;
- (MTPThemeOptionsManager *)themeOptionsManager;

@end
