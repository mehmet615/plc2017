//
//  MTPBeaconSightingManager.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/3/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPBeaconSightingManager.h"
#import "MDBeaconManager.h"
#import "MTPNearMeBeaconSightingCoordinator.h"
#import "User+Helpers.h"

#import <Gimbal/GMBLBeaconSighting.h>
#import <Gimbal/GMBLBeacon.h>
#import "MDCustomTransmitter.h"

#import "User+Helpers.h"
#import "MTAPIClient.h"
#import "MTPNavigationRouter.h"
#import "MTPMatchCoordinator.h"
#import "MTPMatchProfile.h"

#import "EventKeys.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "MTPApplicationDefaultsConstants.h"

#import "MTPAppSettingsKeys.h"

@interface MTPBeaconSightingManager ()
@property (strong, nonatomic) MTPNearMeBeaconSightingCoordinator *nearMeSightCoordinator;
@end

@implementation MTPBeaconSightingManager

+ (instancetype)sightingManager:(GMBLBeaconManager *)beaconManager
{
    return [[MTPBeaconSightingManager alloc] initWithGimbalBeaconManager:beaconManager];
}

- (instancetype)initWithGimbalBeaconManager:(GMBLBeaconManager *)beaconManager
{
    if (self = [super init]) {
        _beaconService = beaconManager;
        [self configureSightingManager];
    }
    return self;
}

- (void)configureSightingManager
{
    [self registerForNotifications];
    [self setupAPICallTimer];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark Gimbal Beacon Manager Delegate

- (void)beaconManager:(GMBLBeaconManager *)manager didReceiveBeaconSighting:(GMBLBeaconSighting *)sighting
{
    NSNumber *RSSI = @(sighting.RSSI);
    
    if (RSSI.integerValue != -66) {
        MDCustomTransmitter *beacon = [self.beaconManager findBeacon:sighting.beacon.identifier];
        if (beacon == nil)
        {
            [self.beaconManager addBeacon:sighting.beacon];
        }
        [self.beaconManager updateRSSI:RSSI forBeacon:beacon.identifier];
        
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
            else
            {
                if (MTP_SPONSOR_MATCHES_ENABLED)
                {
                    // trigger match alert
                    MTPMatchCoordinator *matchCoordinator = self.beaconManager.matchCoordinator;
                    if  ([matchCoordinator isSponsorMatch:beacon.identifier])
                    {
                        if ([matchCoordinator showedSponsorMatchAlert:beacon.identifier] == NO)
                        {
                            MTPMatchProfile *matchProfile = [matchCoordinator sponsorMatchProile:beacon.identifier];
                            if (matchProfile.sponsorName.length)
                            {
                                [self.beaconManager.alertManager showAlertForBeaconID:beacon.identifier
                                                                          withContent:@{@"title": matchProfile.sponsorName}
                                                                             forEvent:@"kEventTypeSponsorMatch"];
                                [matchCoordinator addSponsorMatchAlertID:beacon.identifier];
                            }
                        }
                    }
                }
            }
        }
        else {
            //        DLog(@"\n%@  %@",beacon.identifier,beacon.major);
        }
        [self.beaconManager compareBeacons];
    }
}

- (MDBeaconManager*)beaconManager {
    if (!_beaconManager) {
        _beaconManager = [MDBeaconManager new];
        [_beaconManager getEventBeacons];
    }
    return _beaconManager;
}

- (NSTimer*)apiCallTimer {
    if (!_apiCallTimer) {
        _apiCallTimer = [NSTimer scheduledTimerWithTimeInterval:60
                                                         target:self
                                                       selector:@selector(updateAPI)
                                                       userInfo:nil
                                                        repeats:YES];
        _apiCallTimer.tolerance = 5;
    }
    return _apiCallTimer;
}

#pragma mark - NSNotification Methods
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLoginNotification:)
                                                 name:MTP_LoginNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveLogoutNotification:)
                                                 name:MTP_LogoutNotification
                                               object:nil];
}

- (void)didReceiveLoginNotification:(NSNotification*)notificationInfo
{
    NSNumber *userID = [[notificationInfo userInfo] objectForKey:kUserID];
    if (userID)
    {
        self.beaconManager.currentUser = [User findUser:userID
                                                context:self.rootObjectContext];
    }
    
    [self.beaconService startListening];
    
    if (self.nearMeSightCoordinator == nil)
    {
        self.nearMeSightCoordinator = [[MTPNearMeBeaconSightingCoordinator alloc] initWithManager:self.beaconManager];
    }
    [self.nearMeSightCoordinator startScan];
}

- (void)didReceiveLogoutNotification:(NSNotification*)notificationInfo
{
    [self.beaconService stopListening];
    [self.nearMeSightCoordinator stopScan];
}

- (void)setupAPICallTimer
{
    [self.apiCallTimer fire];
}

- (void)updateAPI {
    if (![User currentUser:self.rootObjectContext]) {
        return;
    }
    
    [self.beaconManager compareBeacons];
    // this will update only if there is a different beacon in the collection
    // regardless of the order of RSSI strength
    __block BOOL strongBeaconsDidChange = YES;
    NSMutableArray *lastUpdateIDs = [NSMutableArray new];
    [self.lastUpdatedBeacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [lastUpdateIDs addObject:[obj identifier]];
    }];
    
    NSMutableArray *nearbyIDs = [NSMutableArray new];
    [self.beaconManager.nearbyBeacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [nearbyIDs addObject:[obj identifier]];
    }];
    
    if (self.lastUpdatedBeacons) {
        if (self.lastUpdatedBeacons.count == self.beaconManager.nearbyBeacons.count) {
            [lastUpdateIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (![nearbyIDs containsObject:obj]) {
                    strongBeaconsDidChange = YES;
                    *stop = YES;
                } else {
                    strongBeaconsDidChange = NO;
                }
            }];
        } else {
            strongBeaconsDidChange = YES;
        }
        
        NSString *newBeacon = [[self.beaconManager.nearbyBeacons firstObject] identifier];
        if ([self.lastStrongestID isEqualToString:newBeacon]) {
            //            DLog(@"\nstrong beacons are the same: last %@ and new %@",self.lastStrongestID,newBeacon);
        } else {
            id beacon = self.beaconManager.activeBeacon;
            if (beacon) {
                [[NSNotificationCenter defaultCenter] postNotificationName:MTP_MyLocationChanged
                                                                    object:nil
                                                                  userInfo:@{@"beacon": self.beaconManager.activeBeacon}];
            }
        }
        self.lastStrongestID = newBeacon;
    }
    
    if (strongBeaconsDidChange)
    {
        [self.beaconManager transmitBeaconData:self.beaconManager.nearbyBeacons
                                    updateType:kUserAddBeacons];
        self.lastUpdatedBeacons = [NSArray arrayWithArray:self.beaconManager.nearbyBeacons];
    } else {
        //        DLog(@"\nbeacons are the same last updated: %@\nnearBy %@", self.lastUpdatedBeacons,self.beaconManager.nearbyBeacons);
    }
}


@end
