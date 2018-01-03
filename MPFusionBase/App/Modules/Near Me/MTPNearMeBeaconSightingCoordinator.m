//
//  MTPNearMeBeaconSightingCoordinator.m
//  MeetingPlay
//
//  Created by MeetingPlay on 3/31/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPNearMeBeaconSightingCoordinator.h"
#import "MDBeaconManager.h"
#import "MDCustomTransmitter.h"

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UILocalNotification.h>
#import <UIKit/UIApplication.h>
#import "MTPDLogDefine.h"
#import "EventKeys.h"

@interface MTPNearMeBeaconSightingCoordinator () <CLLocationManagerDelegate>
@property (strong, nonatomic) MDBeaconManager *beaconManager;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLBeaconRegion *beaconRegion;
@property (strong, nonatomic) NSTimer *updateTimer;
@property (strong, nonatomic) NSDate *lastAPIUpdate;
@end

@implementation MTPNearMeBeaconSightingCoordinator

NSString *const kMTP_Beacon_Region_UUID = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0";
NSString *const kMTP_beacon_Region_Identifier = @"minewbeacon";

- (instancetype)initWithManager:(MDBeaconManager *)beaconManager
{
    if (self = [super init])
    {
        _beaconManager = beaconManager;
        CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID:[[NSUUID alloc] initWithUUIDString:kMTP_Beacon_Region_UUID] identifier:kMTP_beacon_Region_Identifier];
        _beaconRegion = beaconRegion;
    }
    
    return self;
}

- (void)startScan
{
    if (self.locationManager == nil)
    {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    
    self.locationManager.delegate = self;
    [self.locationManager startRangingBeaconsInRegion:self.beaconRegion];

}

- (void)stopScan
{
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
}

#pragma mark - Protocol Conformance
- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    [self processBeaconSightings:beacons];
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //    NSLog(@"did enter region");
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    DLog(@"monitoring did fail %@",error.localizedDescription);
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error {
    DLog(@"rangingDidFail %@",error.localizedDescription);
}

- (void)processBeaconSightings:(NSArray *)beacons
{
    for (CLBeacon *sightedBeacon in beacons)
    {
        [self updateBeacon:sightedBeacon];
    }
    
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive)
    {
        NSDate *timeNow = [NSDate date];
        NSTimeInterval interval = [timeNow timeIntervalSinceDate:self.lastAPIUpdate];
        if (interval > 60)
        {
            self.lastAPIUpdate = [NSDate date];
            [self updateAPI];
#ifdef DEBUG
            UILocalNotification *local = [UILocalNotification new];
            local.alertBody = @"beacons sent to api";
            //            [[UIApplication sharedApplication] presentLocalNotificationNow:local];
#endif
        }
    }
}

- (void)updateBeacon:(CLBeacon *)sightedBeacon
{
    NSNumber *RSSI = @(sightedBeacon.rssi);
    if (RSSI.integerValue < 0)
    {
        MDCustomTransmitter *beacon = [self.beaconManager findBeacon:[NSString stringWithFormat:@"%@",sightedBeacon.minor]];
        if (beacon == nil)
        {
            return;
        }
        else if (RSSI.integerValue < beacon.rssi_entry.integerValue)
        {
            return;
        }
        
        [self.beaconManager updateRSSI:RSSI forBeacon:beacon.identifier];
        beacon.lastSighted = [NSDate date];
        
        NSNumber *entryThreshold = beacon.rssi_entry;
        NSNumber *exitThreshold = beacon.rssi_exit;
        
        if (beacon && RSSI.integerValue > entryThreshold.integerValue)
        {
            if (beacon.triggeredEvent == NO)
            {
                [self.beaconManager transmitBeaconData:@[beacon] updateType:kBeaconAddUser];
                [self.beaconManager transmitBeaconData:@[beacon] updateType:kBeaconEvents];
                beacon.triggeredEvent = YES;
            }
        }
        else if (beacon.triggeredEvent &&
                 beacon.RSSI.integerValue < exitThreshold.integerValue)
        {
            //            beacon.RSSI = [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_BeaconOptions] objectForKey:MTP_DefaultNilRSSI];
            //            beacon.triggeredEvent = NO;
        }
        else
        {
            //            DLog(@"\n%@  %@",beacon.identifier,beacon.major);
        }
    }
}

- (void)updateAPI
{
    if (self.currentUser == nil)
    {
        return;
    }
    
    __block NSMutableArray *beaconsFound = [NSMutableArray new];
    NSDictionary *beaconsByType = [[self.beaconManager beaconsByType] copy];
    __block NSMutableDictionary *sortedBeaconsByType = [NSMutableDictionary new];
    [beaconsByType enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull beaconTypeKey, NSSet * _Nonnull beacons, BOOL * _Nonnull stop)
     {
         NSArray *sortedBeacons = [self.beaconManager compareBeacons:beacons.allObjects];
         if (sortedBeacons.count)
         {
             [beaconsFound addObjectsFromArray:sortedBeacons];
             [sortedBeaconsByType setObject:sortedBeacons forKey:beaconTypeKey];
         }
     }];
    
    [self.beaconManager transmitBeaconData:beaconsFound updateType:kUserAddBeacons];
}
@end
