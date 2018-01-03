//
//  MTPSpeaker.h
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 8/16/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTPSession.h"

@interface MTPSpeaker : NSObject <NSCoding>

@property (strong, nonatomic) NSNumber *speakerSortOrder;
@property (strong, nonatomic) NSNumber *speakerID;
@property (strong, nonatomic) NSString *lastname;
@property (strong, nonatomic) NSString *alpha;
@property (strong, nonatomic) NSString *bio;
@property (strong, nonatomic) NSString *firstname;
@property (strong, nonatomic) NSString *photo;
@property (strong, nonatomic) NSString *jobTitle;
@property (strong, nonatomic) NSString *company;

@property (strong, nonatomic) NSArray<MTPSession *> *sessionData;

- (void)updateWithData:(NSDictionary *)speakerData;

@end
