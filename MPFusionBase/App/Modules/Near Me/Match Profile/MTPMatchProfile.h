//
//  MTPMatchProfile.h
//  CPC2016
//
//  Created by Michael Thongvanh on 11/30/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTPMatchProfile : NSObject

@property (strong, nonatomic) NSNumber *meetingSizeMatch;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSNumber *tierMatch;
@property (strong, nonatomic) NSString *company;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSNumber *sponsorMatch;
@property (strong, nonatomic) NSNumber *meetingMatch;
@property (strong, nonatomic) NSNumber *userID;
@property (strong, nonatomic) NSString *photo;
@property (strong, nonatomic) NSString *jobTitle;
@property (strong, nonatomic) NSNumber *totalScore;
@property (strong, nonatomic) NSNumber *stateMatch;

@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSNumber *xCoord;
@property (strong, nonatomic) NSNumber *sortOrder;
@property (strong, nonatomic) NSString *tierName;
@property (strong, nonatomic) NSNumber *yCoord;
@property (strong, nonatomic) NSString *logo;
@property (strong, nonatomic) NSString *sponsorName;
@property (strong, nonatomic) NSNumber *sponsorID;
@property (strong, nonatomic) NSString *beaconID;

+ (instancetype)profile:(NSDictionary *)data;

@end
