//
//  MTPGimbalInitializer.h
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/8/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTPBeaconSightingManager, GMBLBeaconManager, NSManagedObjectContext;

@interface MTPGimbalInitializer : NSObject
@property (nonatomic, strong) GMBLBeaconManager *gimbalBeaconManager;
@property (nonatomic, strong) MTPBeaconSightingManager *beaconSightingManager;

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)rootObjectContext;

@end
