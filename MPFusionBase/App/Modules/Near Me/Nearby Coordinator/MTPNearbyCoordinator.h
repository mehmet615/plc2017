//
//  MTPNearbyCoordinator.h
//  MeetingPlay
//
//  Created by MeetingPlay on 4/3/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDBeaconManager,MDCustomTransmitter,NSManagedObjectContext;

@interface MTPNearbyCoordinator : NSObject

@property (strong, nonatomic) MDBeaconManager *beaconManager;
@property (strong, nonatomic) NSManagedObjectContext *rootObjectContext;

- (void)checkNearbyEnabled:(void(^)(BOOL enabled,NSString *message))completionHandler;

- (NSArray *)nearbyUsers:(NSNumber *)userID;

@end
