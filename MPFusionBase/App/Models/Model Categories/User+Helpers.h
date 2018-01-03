//
//  User+Helpers.h
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/7/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "User.h"
#import "NSManagedObject+Helpers.h"
#import "MAMConnectionDetailsViewController.h"

@class UIImageView;

@interface User (Helpers) <MTPConnectionDetailsDisplayable>

+ (User *)currentUser:(NSManagedObjectContext *)managedObjectContext;

+ (User *)findUser:(NSNumber *)userID context:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)findUsers:(NSArray *)userIDs context:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)allUsersInContext:(NSManagedObjectContext *)managedObjectContext;

+ (User *)createInContext:(NSManagedObjectContext *)managedObjectContext;

- (void)updateUser:(NSDictionary*)jsonData;

- (void)fetchUpdatedInfo:(void(^)(User *currentUser))completionHandler;

+ (NSArray*)createUsers:(NSArray*)jsonData context:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)requiredKeys;

@end
