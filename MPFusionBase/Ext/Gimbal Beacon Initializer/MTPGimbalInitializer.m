//
//  MTPGimbalInitializer.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/8/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPGimbalInitializer.h"
#import <Gimbal/Gimbal.h> 
#import "MTPBeaconSightingManager.h"
#import <CoreData/CoreData.h>

@implementation MTPGimbalInitializer

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)rootObjectContext
{
    self = [super init];
    if (self) {
        _gimbalBeaconManager = [[GMBLBeaconManager alloc] init];
        _beaconSightingManager = [MTPBeaconSightingManager sightingManager:_gimbalBeaconManager];
        _beaconSightingManager.rootObjectContext = rootObjectContext;
        _gimbalBeaconManager.delegate = _beaconSightingManager;
    }
    return self;
}


@end
