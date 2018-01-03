//
//  MTPSpeaker.m
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 8/16/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPSpeaker.h"
#import "NSObject+MTPModelValidation.h"

@implementation MTPSpeaker

- (void)updateWithData:(NSDictionary *)speakerData
{
    self.speakerSortOrder = [speakerData[@"speakerSortOrder"] mtp_numberValue];
    self.speakerID = [speakerData[@"speakerID"] mtp_numberValue];
    self.lastname = [speakerData[@"lastname"] mtp_stringValue];
    self.alpha = [speakerData[@"alpha"] mtp_stringValue];
    self.bio = [speakerData[@"bio"] mtp_stringValue];
    self.firstname = [speakerData[@"firstname"] mtp_stringValue];
    self.photo = [speakerData[@"photo"] mtp_stringValue];
    self.jobTitle = [speakerData[@"jobTitle"] mtp_stringValue];
    self.company = [speakerData[@"company"] mtp_stringValue];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    MTPSpeaker *speaker = [MTPSpeaker new];
    
    self.speakerSortOrder = [aDecoder decodeObjectForKey:@"speakerSortOrder"];
    self.speakerID = [aDecoder decodeObjectForKey:@"speakerID"];
    self.lastname = [aDecoder decodeObjectForKey:@"lastname"];
    self.alpha = [aDecoder decodeObjectForKey:@"alpha"];
    self.bio = [aDecoder decodeObjectForKey:@"bio"];
    self.firstname = [aDecoder decodeObjectForKey:@"firstname"];
    self.photo = [aDecoder decodeObjectForKey:@"photo"];
    self.jobTitle = [aDecoder decodeObjectForKey:@"jobTitle"];
    self.company = [aDecoder decodeObjectForKey:@"company"];
    
    return speaker;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.speakerSortOrder forKey:@"speakerSortOrder"];
    [aCoder encodeObject:self.speakerID forKey:@"speakerID"];
    [aCoder encodeObject:self.lastname forKey:@"lastname"];
    [aCoder encodeObject:self.alpha forKey:@"alpha"];
    [aCoder encodeObject:self.bio forKey:@"bio"];
    [aCoder encodeObject:self.firstname forKey:@"firstname"];
    [aCoder encodeObject:self.photo forKey:@"photo"];
    [aCoder encodeObject:self.jobTitle forKey:@"jobTitle"];
    [aCoder encodeObject:self.company forKey:@"company"];
}

@end
