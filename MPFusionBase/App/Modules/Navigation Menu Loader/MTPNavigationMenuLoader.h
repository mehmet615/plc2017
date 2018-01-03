//
//  MTPNavigationMenuLoader.h
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 1/21/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTPNavigationMenuLoader;

@protocol MTPNavigationLoadable <NSObject>
@optional
- (void)updateNavigationItems;
@end

@interface MTPNavigationMenuLoader : NSObject

- (BOOL)verifyNetworkConnection;

- (void)availableMeeting:(NSString *)meetingName navigationMenu:(NSString *)navigationMenuName lastUpdate:(NSDate *)lastMenuUpdate completionHandler:(void (^)(BOOL, NSError *))completionHandler;

- (void)fetchMeeting:(NSString *)meetingName updatedMenu:(NSString *)navigationMenuName completionHandler:(void (^)(id responseObject, NSError *updateError))completionHandler;

- (void)loadDefaultMenuItems;

- (void)loadMenuItems:(NSDictionary *)menuItems;

- (NSURL *)updatedMenuSaveURL;

@end
