//
//  MTPAPIDataInitializer.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/7/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPAPIDataInitializer.h"
#import "MTAPIClient.h"
//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"
#import "MTPNearbyCoordinator.h"
#import "MTPMatchCoordinator.h"
#import "MTPSpeakerCoordinator.h"
#import "MTPGeneralInfoCoordinator.h"

#import "User+Helpers.h"
#import "NSManagedObject+Helpers.h"
#import "MDMyConnectionManager.h"
#import "MDBeaconManager.h"

#import "MTPSession.h"
#import "MTPSessionManager.h"

#import "Sponsor+Helpers.h"
#import "MTPSponsorManager.h"

#import "NSMutableURLRequest+MTPHelper.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "NSObject+MTPModelValidation.h"

#import "EventKeys.h"
#import "MTPAppSettingsKeys.h"

#import <CoreData/CoreData.h>

@interface MTPAPIDataInitializer ()
@property (nonatomic, strong) NSManagedObjectContext *scratchContext;
@property (nonatomic, strong) NSTimer *sessionUpdateTimer;
@property (readwrite, nonatomic) NSArray *users;
@end

@implementation MTPAPIDataInitializer

+ (instancetype)dataInitializer:(NSManagedObjectContext *)rootObjectContext
{
    return [[MTPAPIDataInitializer alloc] init:rootObjectContext];
}

- (instancetype)init:(NSManagedObjectContext *)managedObjectContext
{
    self = [super init];
    if (self) {
        _sessionManager = [[MTPSessionManager alloc] init];
        _beaconManager = [[MDBeaconManager alloc] init];
        _beaconManager.sessionManager = _sessionManager;
        _rootObjectContext = managedObjectContext;
        _scratchContext = _rootObjectContext;
        _sponsorManager = [[MTPSponsorManager alloc] initManagedObjectContext:_rootObjectContext];
        _myConnectionManager = [MDMyConnectionManager connectionManager:_rootObjectContext];
        _nearbyCoordinator = [MTPNearbyCoordinator new];
        _nearbyCoordinator.beaconManager = _beaconManager;
        _nearbyCoordinator.rootObjectContext = _rootObjectContext;
        _matchCoordinator = [MTPMatchCoordinator new];
        _speakerCoordinator = [MTPSpeakerCoordinator new];
        _generalInfoCoordinator = [MTPGeneralInfoCoordinator new];
    }
    
    return self;
}

- (void)dealloc
{
    [self.sessionUpdateTimer invalidate];
}

- (void)fetchInitialAPIData
{
    //    [self fetchDrawingTypes];
    NSString *lastUpdateString = [[NSUserDefaults standardUserDefaults] objectForKey:@"MTP_AttendeesLastUpdate"];
    NSDate *lastUpdate = [self timestampFromString:lastUpdateString];
    if (lastUpdate == nil)
    {
        [self fetchAllUsers];
    }
    else
    {
        [self fetchUpdateAttendeeTimestamp:^(NSDate *remoteTimestamp, NSError *error)
         {
             if (error)
             {
                 DLog(@"\ndebugging message %@",error);
             }
             else
             {
                 if ([lastUpdate earlierDate:remoteTimestamp] == lastUpdate)
                 {
                     [self fetchAllUsers];
                 }
             }
         }];
    }
    
    NSString *lastSessionUpdateString = [[NSUserDefaults standardUserDefaults] objectForKey:kLastSessionUpdate];
    NSDate *lastSessionUpdate = [self timestampFromString:lastSessionUpdateString];
    if (lastSessionUpdate == nil)
    {
        [self fetchAllSessions];
    }
    else
    {
        [self fetchUpdateSessionsTimestamp:^(NSDate *remoteTimestamp, NSError *error)
         {
             if (error)
             {
                 DLog(@"\ndebugging message %@",error);
             }
             else
             {
                 if ([lastUpdate earlierDate:remoteTimestamp] == lastUpdate)
                 {
                     [self fetchAllSessions];
                 }
             }
         }];
    }
}

- (void)fetchUpdateAttendeeTimestamp:(void(^)(NSDate *remoteTimestamp,NSError *error))completionHandler
{
    NSString *attendeeListChange = [NSString mobileUpdateSettings];
    NSURLRequest *changeTimestampRequest = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:attendeeListChange parameters:nil];
    [[[NSURLSession sharedSession] dataTaskWithRequest:changeTimestampRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSError *requestError = nil;
          NSDate *remoteTimestamp = nil;
          if (error)
          {
              DLog(@"\nerror %@",error);
              requestError = error;
          }
          else
          {
              id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&requestError];
              if (responseObject)
              {
                  NSString *timestampString = [responseObject[@"apiattendeelastupdate"] mtp_stringValue];
                  remoteTimestamp = [self timestampFromString:timestampString];
              }
              else
              {
                  DLog(@"\nrequest error %@",requestError);
              }
          }
          
          if (completionHandler)
          {
              completionHandler(remoteTimestamp,requestError);
          }
      }] resume];
}

- (void)fetchUpdateSessionsTimestamp:(void(^)(NSDate *remoteTimestamp,NSError *error))completionHandler
{
    NSString *sessionsListChange = [NSString mobileUpdateSettings];
    NSURLRequest *changeTimestampRequest = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:sessionsListChange parameters:nil];
    [[[NSURLSession sharedSession] dataTaskWithRequest:changeTimestampRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSError *requestError = nil;
          NSDate *remoteTimestamp = nil;
          if (error)
          {
              DLog(@"\nerror %@",error);
              requestError = error;
          }
          else
          {
              id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&requestError];
              if (responseObject)
              {
                  NSString *timestampString = [responseObject[@"apisessionslastupdate"] mtp_stringValue];
                  remoteTimestamp = [self timestampFromString:timestampString];
              }
              else
              {
                  DLog(@"\nrequest error %@",requestError);
              }
          }
          
          if (completionHandler)
          {
              completionHandler(remoteTimestamp,requestError);
          }
      }] resume];
}

- (NSDate *)timestampFromString:(NSString *)timestampString
{
    if ([timestampString isKindOfClass:[NSString class]] == NO)
    {
        return nil;
    }
    
    if (timestampString.length == 0)
    {
        return nil;
    }
    
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    dateFormat.dateFormat = @"MM/dd/yyyy HH:mm:ss Z";
    NSDate *remoteTimestamp = [dateFormat dateFromString:timestampString];
    return remoteTimestamp;
}

- (NSManagedObjectContext *)createScratchContext:(NSManagedObjectContext *)rootContext
{
    NSManagedObjectContext *scratchContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    scratchContext.parentContext = rootContext;
    
    return scratchContext;
}

- (void)fetchDrawingTypes
{
    if ([[self.userDefaults objectForKey:MTP_EventConnectionGame] boolValue])
    {
        NSArray *drawingTypes = [[NSUserDefaults standardUserDefaults] objectForKey:kDrawingTypesUserDefaultsKey];
        if (drawingTypes.count > 0) {
            return;
        }
        [[MTAPIClient sharedClient] GET:[NSString drawingTypes] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            id allDrawingTypes = [responseObject objectForKey:@"data"];
            
            if (allDrawingTypes && [allDrawingTypes isKindOfClass:[NSArray class]]) {
                [[NSUserDefaults standardUserDefaults] setObject:allDrawingTypes forKey:kDrawingTypesUserDefaultsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                DLog(@"\nDrawing types or type of data failed\n%@", allDrawingTypes);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DLog(@"\nError occurred %ld: %@", error.code, error.localizedDescription);
        }];
    }
    else
    {
        DLog(@"\nConnection game is disabled");
    }
}

- (void)fetchAllUsers
{
    BOOL fetchAllUsersEnabled = [[[NSUserDefaults standardUserDefaults] objectForKey:@"MTP_FetchAllUsers"] boolValue];
    if (fetchAllUsersEnabled)
    {
        __weak __typeof(&*self)weakSelf = self;
        
        [self sendAPI:[NSString userCollection] completionHandler:^(NSData *data, NSDictionary *responseObject)
         {
             if ([responseObject isKindOfClass:[NSDictionary class]])
             {
                 NSManagedObjectContext *privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
                 privateContext.parentContext = weakSelf.rootObjectContext;
                 
                 [privateContext performBlock:^
                  {
                      NSArray *allUsers = [NSArray array];
                      allUsers = [User createUsers:[responseObject objectForKey:@"data"] context:privateContext];
                      weakSelf.users = allUsers;
                      
                      if (allUsers.count)
                      {
                          NSString *responsePhotoUrl = [[responseObject objectForKey:@"info"] objectForKey:kResponsePhotoUrl];
                          [[NSUserDefaults standardUserDefaults] setObject:responsePhotoUrl forKey:kProfileImageUrl];
                          
                          NSDate *timeNow = [NSDate date];
                          NSDateFormatter *dateFormat = [NSDateFormatter new];
                          dateFormat.dateFormat = @"MM/dd/yyyy HH:mm:ss Z";
                          
                          NSString *dateString = [dateFormat stringFromDate:timeNow];
                          [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:@"MTP_AttendeesLastUpdate"];
                          
                          if (privateContext.hasChanges)
                          {
                              NSError *privateContextSaveError = nil;
                              if ([privateContext save:&privateContextSaveError])
                              {
                                  NSArray *usersInStore = [User allUsersInContext:weakSelf.rootObjectContext];
                                  
                                  DLog(@"\nsuccessful allUsers processing -- %@",@(usersInStore.count));
                                  NSError *saveError = nil;
                                  if (![privateContext.parentContext save:&saveError])
                                  {
                                      DLog(@"\nsave error %@", saveError);
                                  }
                                  else
                                  {
                                      DLog(@"\nparent context saved");
                                  }
                              }
                              else
                              {
                                  DLog(@"\ncontextSave Error %@",privateContextSaveError);
                              }
                          }
                          else
                          {
                              DLog(@"\nNo changes in context");
                          }
                          [[NSNotificationCenter defaultCenter] postNotificationName:MTP_DidFetchAllUsersNotification object:nil];
                      }
                      else
                      {
                          DLog(@"\nno users found");
                      }
                  }];
             }
             else
             {
                 DLog(@"\ninvalid type: missing dictionary keys");
             }
             
             [[NSUserDefaults standardUserDefaults] setBool:true forKey:kFetchUsersUpdate];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }];
    }
}

- (NSArray *)attendees
{
    NSArray *attendees = [User allUsersInContext:self.rootObjectContext];
    return attendees;
}

- (void)fetchAllSponsors
{
    __weak __typeof(&*self)weakSelf = self;
    [self sendAPI:[NSString sponsorsAll] completionHandler:^(NSData *data, NSDictionary *responseObject) {
        NSArray *allSponsors = [[responseObject objectForKey:@"data"] objectForKey:@"sponsors"];
        if ([weakSelf.sponsorManager processRemoteSponsorData:allSponsors]) {
            NSLog(@"Successfully processed Sponsors");
        }
        NSString *sponsorProfileUrl = [[responseObject objectForKey:@"data"] objectForKey:@"logo"];
        [[NSUserDefaults standardUserDefaults] setObject:sponsorProfileUrl forKey:kSponsorLogoUrl];
    }];
}

- (void)fetchAllSessions
{
    [self.sessionManager fetchSessions:^(NSArray *sessionCollection, NSError *error)
     {
         NSDate *timeNow = [NSDate date];
         NSDateFormatter *dateFormat = [NSDateFormatter new];
         dateFormat.dateFormat = @"MM/dd/yyyy HH:mm:ss Z";
         
         NSString *dateString = [dateFormat stringFromDate:timeNow];
         [[NSUserDefaults standardUserDefaults] setObject:dateString forKey:kLastSessionUpdate];
         [[NSUserDefaults standardUserDefaults] synchronize];
     }];
}

- (void)fetchSessionBeacons {
    /*
     [[MTAPIClient sharedClient] GET:SESSIONS_BEACONS parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
     NSArray *allSessions = [[responseObject objectForKey:@"data"] objectForKey:@"sessions"];
     [allSessions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
     MDSSession *session = [[MDSessionManager sharedManager] getSession:[obj objectForKey:@"session_id"]];
     session.beaconId = [obj objectForKey:@"beacon_id"];
     }];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     DLog(@"\nfailed");
     }];
     */
}

- (void)fetchConnected
{
    [self.sponsorManager fetchConnectedSponsors:nil];
    [self.myConnectionManager updateConnectionsFromApi];
}

- (void)sendAPI:(NSString *)apiRequestURL completionHandler:(void (^)(NSData *data, NSDictionary *responseObject))completionHandler {
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:apiRequestURL]];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setAllHTTPHeaderFields:@{@"accept": @"application/json",
                                         @"X-Authentication-Token": [[self.userDefaults objectForKey:MTP_NetworkOptions] objectForKey:MTP_XAuthToken]}];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            DLog(@"\nrequest error %@\nresponse %@\nrequest %@", error.localizedDescription,response,urlRequest);
        } else {
            NSError *serializationError;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                options:NSJSONReadingAllowFragments
                                                                  error:&serializationError];
            if (serializationError) {
                DLog(@"\nserialization of all sponsors request error: %@\n response %@\nrequest %@", serializationError.localizedDescription,response,urlRequest);
                return;
            }
            
            if ([responseObject isKindOfClass:[NSDictionary class]] == false) {
                DLog(@"\nNot a Dictionary");
                return;
            }
            
            NSArray *allKeys = [responseObject allKeys];
            if ([allKeys containsObject:@"data"] == false) {
                DLog(@"\ndoesnt contain data key");
                return;
            }
            
            if (completionHandler) {
                completionHandler(data,responseObject);
            }
        }
    }] resume];
}

- (void)updateSessionInformation
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        NSDate *lastSessionUpdate = [self.userDefaults objectForKey:kLastSessionUpdate];
        if (!lastSessionUpdate) {
            lastSessionUpdate = [NSDate date];
            [self.userDefaults setObject:lastSessionUpdate forKey:kLastSessionUpdate];
        }
        NSTimeInterval thirtyMinutes = 30 * 60;
        
        NSTimeInterval lastUpdateTimeInterval = [[NSDate date] timeIntervalSinceDate:lastSessionUpdate];
        if (lastUpdateTimeInterval > thirtyMinutes)
        {
            [self fetchAllSessions];
#ifdef DEBUG
            UILocalNotification *localNotification = [[UILocalNotification alloc] init];
            localNotification.alertBody = [NSString stringWithFormat:@"Refreshed session information on %@",[NSDate date]];
            [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
#endif
        }
    }
}

- (NSTimer *)sessionUpdateTimer
{
    if (!_sessionUpdateTimer)
    {
        _sessionUpdateTimer = [NSTimer timerWithTimeInterval:(20 * 60)
                                                      target:self
                                                    selector:@selector(updateSessionInformation)
                                                    userInfo:nil
                                                     repeats:true];
        if ([_sessionUpdateTimer respondsToSelector:@selector(tolerance)])
        {
            [_sessionUpdateTimer setTolerance:10];
        }
    }
    
    return _sessionUpdateTimer;
}

@end
