//
//  MTPMatchProfile.m
//  CPC2016
//
//  Created by Michael Thongvanh on 11/30/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPMatchProfile.h"
#import "NSObject+MTPModelValidation.h"

@implementation MTPMatchProfile

+ (instancetype)profile:(NSDictionary *)data
{
    MTPMatchProfile *matchProfile = [MTPMatchProfile new];
    [matchProfile updateWithData:data];
    return matchProfile;
}

- (void)updateWithData:(NSDictionary *)data
{
    NSDictionary *stringKeys = [self stringValueKeys];
    [stringKeys enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *value = [data[obj] mtp_stringValue];
        [self setValue:value forKey:key];
    }];
    
    NSDictionary *numberKeys = [self numberValueKeys];
    [numberKeys enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSNumber *value = [data[obj] mtp_numberValue];
        [self setValue:value forKey:key];
    }];
}

- (NSDictionary *)stringValueKeys
{
    return @{
             @"firstName" : @"firstname",
             @"email" : @"email",
             @"company" : @"company",
             @"lastName" : @"lastname",
             @"photo" : @"photo",
             @"jobTitle" : @"jobtitle",
             @"location": @"location",
             @"tierName": @"tiername",
             @"logo": @"logo",
             @"sponsorName": @"sponsorname",
             @"beaconID": @"beacon_id"
             };
}

- (NSDictionary *)numberValueKeys
{
    return @{
             @"meetingSizeMatch" : @"meetingsizematch",
             @"tierMatch" : @"tier_match",
             @"sponsorMatch" : @"sponsor_match",
             @"meetingMatch" : @"meeting_match",
             @"userID" : @"userid",
             @"totalScore" : @"totalscore",
             @"stateMatch" : @"state_match",
             @"xCoord": @"xcord",
             @"sortOrder": @"sortorder",
             @"yCoord": @"ycord",
             @"sponsorID": @"sponsorid"
             };
}
@end
