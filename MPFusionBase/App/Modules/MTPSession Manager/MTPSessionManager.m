//
//  MTPSessionManager.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/7/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPSessionManager.h"
#import "MTPSession.h"
#import "MTPDLogDefine.h"
#import "NSMutableURLRequest+MTPHelper.h"
#import "NSString+MTPAPIAddresses.h"

@implementation MTPSessionManager

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        NSArray *sessions = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:[self sessionsSavePath]]];
        _sessionCollection = [NSMutableArray arrayWithArray:sessions];
        if (_sessionCollection == nil)
        {
            _sessionCollection = [NSMutableArray new];
        }
    }
    return self;
}

+ (instancetype)sessionManager
{
    return [[MTPSessionManager alloc] init];
}

- (void)addSession:(MTPSession *)session
{
    if (![self.sessionCollection containsObject:session]) {
        [self.sessionCollection addObject:session];
    }
}

- (MTPSession *)getSession:(NSNumber*)sessionID
{
    __block MTPSession *foundSession;
    [self.sessionCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(MTPSession *)obj session_id] isEqualToNumber:sessionID]) {
            foundSession = obj;
        }
    }];
    return foundSession;
}

- (MTPSession *)getSessionByBeaconID:(NSString*)beaconID
{
    __block MTPSession *foundSession;
    [self.sessionCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[(MTPSession *)obj beaconId].uppercaseString isEqualToString:beaconID.uppercaseString]) {
            foundSession = obj;
        }
    }];
    return foundSession;
}

- (void)fetchSessions:(void(^)(NSArray *sessionCollection,NSError *error))completionHandler
{
    NSMutableURLRequest *sessionRequest = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:[NSString sessionsAll] parameters:nil];
    sessionRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    __weak __typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:sessionRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *sessionError = nil;
        if (error)
        {
            DLog(@"\ndebugging message %@", error);
            sessionError = error;
        }
        else
        {
            NSError *serializationError = nil;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
            if (responseObject)
            {
                NSArray *allSessions = [[responseObject objectForKey:@"data"] objectForKey:@"sessions"];
                [weakSelf processCollection:allSessions completionHandler:completionHandler];
                if ([weakSelf archiveSessions:allSessions])
                {
                    DLog(@"\narchived sessions");
                }
                else
                {
                    DLog(@"\ndidnt archive sessions");
                }
                return;
            }
            else
            {
                DLog(@"\nserialization error %@",serializationError);
                sessionError = serializationError;
            }
        }
        
        if (completionHandler)
        {
            completionHandler(nil,sessionError);
        }
    }] resume];
}

- (void)processCollection:(NSArray *)sessionData completionHandler:(void(^)(NSArray *sessionCollection,NSError *error))completionHandler
{
    __block NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.formatterBehavior = [NSDateFormatter defaultFormatterBehavior];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setDateFormat:@"MMMM, dd yyyy hh:mm:ss"];
    
    __block NSMutableSet *dates = [NSMutableSet new];
    __block NSMutableSet *tracks = [NSMutableSet new];
    
    __block NSMutableArray *sessions = [NSMutableArray new];
    
    [sessionData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         MTPSession *session = [[MTPSession alloc] init];
         [session fillValuesFromResponseObject:obj];
         [sessions addObject:session];
         
         if (session.track.length)
         {
             [tracks addObject:session.track];
         }
         
         NSDate *date = [dateFormatter dateFromString:session.start_time];
         if (date)
         {
             NSCalendar *calendar = [NSCalendar currentCalendar];
             NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitYear fromDate:date];
             
             NSDate *scrubbedDate = [calendar dateFromComponents:dateComponents];
             
             if (scrubbedDate)
             {
                 [dates addObject:scrubbedDate];
             }
         }
     }];
    
    self.tracks = [tracks allObjects];
    self.dates = [dates sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"timeIntervalSince1970" ascending:YES]]];
    
    self.sessionCollection = [NSMutableArray arrayWithArray:sessions];
    
    if (completionHandler)
    {
        completionHandler(self.sessionCollection,nil);
    }
}

- (NSDictionary *)sortAgendaWithDate:(NSDate *)selectedDate track:(NSString *)trackName
{
    NSDictionary *sessionsByDate =  [self sessionForDate:selectedDate sessionCollection:[MTPSessionManager sortSessions:self.sessionCollection]];
    NSDictionary *sortedSessionsByDateAndTrack = trackName.length ? [self sessionByDateForTrack:trackName sessionCollection:sessionsByDate] : sessionsByDate;
    
    return sortedSessionsByDateAndTrack;
}

- (NSDictionary *)sessionForDate:(NSDate *)date sessionCollection:(NSDictionary *)sessionCollection
{
    NSDictionary *sessionsByDate = nil;
    if (date)
    {
        NSArray *sessionsForDate = [[MTPSessionManager sortSessions:self.sessionCollection] objectForKey:date];
        
        if (sessionsForDate.count)
        {
            sessionsByDate = @{date: sessionsForDate};
        }
    }
    else
    {
        sessionsByDate = [MTPSessionManager sortSessions:self.sessionCollection];
    }
    
    return sessionsByDate;
}

- (NSDictionary *)sortSessionByTrack:(NSString *)trackName
{
    NSMutableArray *sessionsByTrack = [NSMutableArray new];
    
    NSArray *sessions = [NSArray arrayWithArray:self.sessionCollection];
    for (MTPSession *session in sessions)
    {
        if ([session.track rangeOfString:trackName options:NSCaseInsensitiveSearch].length)
        {
            [sessionsByTrack addObject:session];
        }
    }
    
    NSDictionary *sortedSessionByDate = [MTPSessionManager sortSessions:sessionsByTrack];
    return sortedSessionByDate;
}

- (NSDictionary *)sessionByDateForTrack:(NSString *)trackName sessionCollection:(NSDictionary *)sessionCollection
{
    __block NSMutableDictionary *sessionByDateForTrack = [NSMutableDictionary new];
    [sessionCollection enumerateKeysAndObjectsUsingBlock:^(NSDate *key, NSArray *obj, BOOL * _Nonnull stop)
     {
         NSArray *filteredByTrack = [obj filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.track contains[cd] %@",trackName]];
         if (filteredByTrack.count)
         {
             [sessionByDateForTrack setObject:filteredByTrack forKey:key];
         }
     }];
    
    return [NSDictionary dictionaryWithDictionary:sessionByDateForTrack];
}

+ (NSDictionary *)sortSessions:(NSArray *)sessionCollection
{
    NSMutableDictionary *sortedSessionsByDay = [NSMutableDictionary new];
    NSMutableArray *sessionsForDay = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    for (MTPSession *session in sessionCollection)
    {
        NSDate *sessionStart = [session dateFromString:session.start_time];
        if (sessionStart)
        {
            NSDate *day = [calendar startOfDayForDate:sessionStart];
            sessionsForDay = sortedSessionsByDay[day];
            if (sessionsForDay.count == 0)
            {
                sessionsForDay = [NSMutableArray new];
            }
            
            [sessionsForDay addObject:session];
            [sortedSessionsByDay setObject:sessionsForDay forKey:day];
        }
        else
        {
            DLog(@"\nsession start nil %@",session);
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:sortedSessionsByDay];
}

- (NSMutableArray*)sessionCollection
{
    if (!_sessionCollection) {
        _sessionCollection = [NSMutableArray array];
    }
    return _sessionCollection;
}

- (BOOL)archiveSessions:(NSArray *)sessions
{
    NSString *savePath = [self sessionsSavePath];
    BOOL saved = [NSKeyedArchiver archiveRootObject:sessions toFile:savePath];
    return saved;
}

- (NSString *)sessionsSavePath
{
    NSString *sessionsSavePath = [[[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"sessions.data"] path];
    return sessionsSavePath;
}

@end
