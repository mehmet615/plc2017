//
//  MTPGeneralInformation.h
//  MPFusionBaseProject
//
//  Created by Admin on 8/19/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTPAssetData.h"

@interface MTPGeneralInformation : NSObject

@property (nonatomic, strong) NSNumber *contentID;
@property (nonatomic, strong) NSNumber *sortOrderID;
@property (nonatomic, strong) NSString *linkValue;
@property (nonatomic, strong) NSString *categoryTitle;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *photo;
@property (nonatomic, strong) NSString *tagTitle;

@property (nonatomic, strong) NSArray<MTPAssetData *> *files;

- (void)updateWithData:(NSDictionary *)generalInfoData;

@end
