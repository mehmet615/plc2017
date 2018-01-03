//
//  MTPAssetData.m
//  MPFusionBaseProject
//
//  Created by Admin on 8/27/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPAssetData.h"
#import "NSObject+MTPModelValidation.h"

@implementation MTPAssetData

- (void)updateWithData:(NSDictionary *)assetData
{
    self.assetID = [assetData[@"assetID"] mtp_numberValue];
    self.assetName = [assetData[@"assetName"] mtp_stringValue];
    self.assetFile = [assetData[@"assetFile"] mtp_stringValue];
    self.assetExtension = [assetData[@"assetExtension"] mtp_stringValue];
    self.publishDate = [assetData[@"publishDate"] mtp_stringValue];
    self.descriptionString = [assetData[@"description"] mtp_stringValue];
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    MTPAssetData *assetData = [MTPAssetData new];
    
    self.assetID = [aDecoder decodeObjectForKey:@"assetID"];
    self.assetName = [aDecoder decodeObjectForKey:@"assetName"];
    self.assetFile = [aDecoder decodeObjectForKey:@"assetFile"];
    self.assetExtension = [aDecoder decodeObjectForKey:@"assetExtension"];
    self.publishDate = [aDecoder decodeObjectForKey:@"publishDate"];
    self.descriptionString = [aDecoder decodeObjectForKey:@"description"];
    
    return assetData;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.assetID forKey:@"assetID"];
    [aCoder encodeObject:self.assetName forKey:@"assetName"];
    [aCoder encodeObject:self.assetFile forKey:@"assetFile"];
    [aCoder encodeObject:self.assetExtension forKey:@"assetExtension"];
    [aCoder encodeObject:self.publishDate forKey:@"publishDate"];
    [aCoder encodeObject:self.descriptionString forKey:@"description"];
}

@end
