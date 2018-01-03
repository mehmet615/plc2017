//
//  MTPGeneralInfoCoordinator.h
//  MPFusionBaseProject
//
//  Created by Admin on 8/19/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTPGeneralInformation, MTPAssetData;

@interface MTPGeneralInfoCoordinator : NSObject

@property (strong, nonatomic, readonly) NSArray *generalInfos;

- (void)fetchGeneralInfo:(BOOL)forceFetch completion:(void(^)(NSArray *generalInfos, NSError *error))completionHandler;
- (void)fetchGeneralInfoWithId:(NSNumber *)generalInfoId completion:(void(^)(NSArray <MTPAssetData *> *files, NSError *error))completionHandler;

- (MTPGeneralInformation *)generalInfoWithID:(NSNumber *)generalInfoID;


@end
