//
//  MTPSession.h
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/7/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTPSession : NSObject <NSCoding>

@property (strong, nonatomic) NSString *location;
@property (strong, nonatomic) NSString *track;
@property (strong, nonatomic) NSString *modified;
@property (strong, nonatomic) NSString *sessionDescription;
@property (strong, nonatomic) NSString *teaser;
@property (strong, nonatomic) NSNumber *session_id;
@property (strong, nonatomic) NSNumber *schedule_id;
@property (assign, nonatomic) BOOL allow_questions;
@property (strong, nonatomic) NSString *end_time;
@property (strong, nonatomic) NSString *start_time;
@property (strong, nonatomic) NSString *created;
@property (strong, nonatomic) NSString *photo;
@property (strong, nonatomic) NSString *sessionTitle;
@property (strong, nonatomic) NSString *beaconId;
@property (strong, nonatomic) NSNumber *goto_session_details;

@property (strong, nonatomic) NSAttributedString *attributedSessionTitle;
@property (strong, nonatomic) NSAttributedString *attributedSessionTeaser;
@property (strong, nonatomic) NSAttributedString *attributedSessionDescription;

- (void)fillValuesFromResponseObject:(NSDictionary*)response;

- (NSDate *)dateFromString:(NSString *)dateString;

@end
