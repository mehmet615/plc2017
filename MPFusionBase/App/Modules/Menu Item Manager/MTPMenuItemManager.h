//
//  MTPMenuItemManager.h
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/17/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTPNavigationMenuLoader;

@interface MTPMenuItemManager : NSObject

@property (strong, nonatomic) NSArray *sideNavigationItems;
@property (strong, nonatomic) NSArray *homepageItems;

@property (strong, nonatomic) MTPNavigationMenuLoader *menuLoader;

- (NSDictionary *)loadMenuItems;

- (void)parseMenuItems:(NSDictionary *)menuItemData;

- (void)fetchMenuItemsForMeeting:(NSString *)meetingName menuFilename:(NSString *)remoteFilename completion:(void(^)(NSArray *navigationItems,NSArray *quickLinksItems,NSError *error))completionHandler;

- (NSURL *)updatedMenuSaveURL;

@end
