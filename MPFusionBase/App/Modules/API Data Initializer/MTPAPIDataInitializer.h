//
//  MTPAPIDataInitializer.h
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/7/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MDBeaconManager, MTPSessionManager, MTPSponsorManager, MDMyConnectionManager, NSManagedObjectContext,MTPNearbyCoordinator,MTPMatchCoordinator,MTPSpeakerCoordinator,MTPGeneralInfoCoordinator;

@interface MTPAPIDataInitializer : NSObject
@property (nonatomic, strong) NSManagedObjectContext *rootObjectContext;
@property (nonatomic, strong) MDBeaconManager *beaconManager;
@property (nonatomic, strong) MTPSessionManager *sessionManager;
@property (nonatomic, strong) MTPSponsorManager *sponsorManager;
@property (nonatomic, strong) MDMyConnectionManager *myConnectionManager;
@property (strong, nonatomic) MTPMatchCoordinator *matchCoordinator;
@property (strong, nonatomic) MTPSpeakerCoordinator *speakerCoordinator;
@property (strong, nonatomic) MTPGeneralInfoCoordinator *generalInfoCoordinator;

@property (strong, nonatomic) MTPNearbyCoordinator *nearbyCoordinator;

@property (readonly, nonatomic) NSArray *users;
- (NSArray *)attendees;

+ (instancetype)dataInitializer:(NSManagedObjectContext *)rootObjectContext;
- (void)fetchInitialAPIData;

- (void)fetchAllUsers;
- (void)fetchDrawingTypes;
- (void)fetchAllSponsors;
- (void)fetchAllSessions;
- (void)fetchConnected;

@end
