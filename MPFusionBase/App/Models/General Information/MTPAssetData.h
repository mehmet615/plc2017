//
//  MTPAssetData.h
//  MPFusionBaseProject
//
//  Created by Admin on 8/27/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTPAssetData : NSObject

@property (nonatomic, strong) NSNumber *assetID;
@property (nonatomic, strong) NSString *assetFile;
@property (nonatomic, strong) NSString *assetExtension;
@property (nonatomic, strong) NSString *assetName;
@property (nonatomic, strong) NSString *descriptionString;
@property (nonatomic, strong) NSString *publishDate;

- (void)updateWithData:(NSDictionary *)assetData;

@end
