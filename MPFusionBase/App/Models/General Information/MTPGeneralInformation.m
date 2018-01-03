//
//  MTPGeneralInformation.m
//  MPFusionBaseProject
//
//  Created by Admin on 8/19/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPGeneralInformation.h"
#import "NSObject+MTPModelValidation.h"

@implementation MTPGeneralInformation

- (void)updateWithData:(NSDictionary *)generalInfoData
{
    self.contentID = [generalInfoData[@"contentID"] mtp_numberValue];
    self.sortOrderID = [generalInfoData[@"sortOrder"] mtp_numberValue];
    self.linkValue = [generalInfoData[@"linkValue"] mtp_stringValue];
    self.categoryTitle = [generalInfoData[@"categoryTitle"] mtp_stringValue];
    self.title = [generalInfoData[@"title"] mtp_stringValue];
    self.content = [generalInfoData[@"content"] mtp_stringValue];
    self.photo = [generalInfoData[@"photo"] mtp_stringValue];
    self.tagTitle = [generalInfoData[@"tagTitle"] mtp_stringValue];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    MTPGeneralInformation *generalInfo = [MTPGeneralInformation new];
    
    self.contentID = [aDecoder decodeObjectForKey:@"contentID"];
    self.sortOrderID = [aDecoder decodeObjectForKey:@"sortOrder"];
    self.linkValue = [aDecoder decodeObjectForKey:@"linkValue"];
    self.categoryTitle = [aDecoder decodeObjectForKey:@"categoryTitle"];
    self.title = [aDecoder decodeObjectForKey:@"title"];
    self.content = [aDecoder decodeObjectForKey:@"content"];
    self.photo = [aDecoder decodeObjectForKey:@"photo"];
    self.tagTitle = [aDecoder decodeObjectForKey:@"tagTitle"];
    
    return generalInfo;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.contentID forKey:@"contentID"];
    [aCoder encodeObject:self.sortOrderID forKey:@"sortOrder"];
    [aCoder encodeObject:self.linkValue forKey:@"linkValue"];
    [aCoder encodeObject:self.categoryTitle forKey:@"categoryTitle"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.content forKey:@"content"];
    [aCoder encodeObject:self.photo forKey:@"photo"];
    [aCoder encodeObject:self.tagTitle forKey:@"tagTitle"];
}

@end
