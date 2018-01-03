//
//  MTPNearMeProtocols.h
//  MeetingPlay
//
//  Created by MeetinPlay on 3/31/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTPMatchCoordinator;

@protocol MTPNearMeBeaconSighting <NSObject>
@property (strong, nonatomic) MTPMatchCoordinator *matchCoordinator;
@end

@protocol MTPNearMeBeaconManagement <NSObject>
@property (strong, nonatomic) NSMutableDictionary *beaconsByType;
-(NSArray *)compareBeacons:(NSArray *)beaconCollection max:(NSNumber *)maxBeacons;
-(void)resetSeen;
@end

@protocol MTPNearMeBeaconProtocol <NSObject>
@property (strong,nonatomic) NSString *beaconType;
@property (strong, nonatomic) NSDate *lastSighted;
@end