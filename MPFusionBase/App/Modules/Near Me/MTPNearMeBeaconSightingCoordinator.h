//
//  MTPNearMeBeaconSightingCoordinator.h
//  MeetingPlay
//
//  Created by MeetingPlay on 3/31/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User,MDBeaconManager;

@interface MTPNearMeBeaconSightingCoordinator : NSObject
@property (strong, nonatomic) User *currentUser;
- (instancetype)initWithManager:(MDBeaconManager *)beaconManager;
- (void)startScan;
- (void)stopScan;
@end
