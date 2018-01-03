//
//  MTPSessionManager.h
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/7/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTPSession;

@interface MTPSessionManager : NSObject

@property (strong, nonatomic) NSMutableArray *sessionCollection;
@property (strong, nonatomic) NSArray *tracks;
@property (strong, nonatomic) NSArray *dates;

+ (instancetype)sessionManager;

+ (NSDictionary *)sortSessions:(NSArray *)sessionCollection;

- (void)addSession:(MTPSession *)session;

- (MTPSession *)getSession:(NSNumber *)sessionID;

- (MTPSession *)getSessionByBeaconID:(NSString *)beaconID;

- (NSDictionary *)sortSessionByTrack:(NSString *)trackName;

- (NSDictionary *)sortAgendaWithDate:(NSDate *)selectedDate track:(NSString *)trackName;
- (NSDictionary *)sessionForDate:(NSDate *)date sessionCollection:(NSDictionary *)sessionCollection;
- (NSDictionary *)sessionByDateForTrack:(NSString *)trackName sessionCollection:(NSDictionary *)sessionCollection;

- (void)fetchSessions:(void(^)(NSArray *sessionCollection,NSError *error))completionHandler;
- (void)processCollection:(NSArray *)sessionData completionHandler:(void(^)(NSArray *sessionCollection,NSError *error))completionHandler;

@end
