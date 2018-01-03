//
//  MDBeaconManager.m
//  MarriottDigitalSummit
//
//  Created by Michael Thongvanh on 4/30/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import "MDBeaconManager.h"
#import "MDCustomTransmitter.h"
#import <Gimbal/GMBLBeacon.h>

#import "NSObject+MTPModelValidation.h"
#import "NSURLSession+MTPCategory.h"
#import "EventKeys.h"
#import "NSString+MTPWebViewURL.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "NSString+MTPAPIAddresses.h"
#import "User+Helpers.h"
#import "MTAPIClient.h"
#import "MTPSession.h"
#import "MTPSessionManager.h"
#import "MTPSponsorManager.h"
#import "Sponsor.h"
#import "MTPMatchCoordinator.h"
#import "MTPAlertManager.h"
#import "MTPAppSettingsKeys.h"

@interface MDBeaconManager ()
@property (strong, nonatomic) NSMutableDictionary *requestStatus;
@property (strong, nonatomic) MTAPIClient *apiClient;
@property (strong, nonatomic) NSMutableArray *httpRequestQueue;
@property (assign, nonatomic) BOOL performingRequest;
@end

@implementation MDBeaconManager

@synthesize beaconsByType;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _nearbyBeacons = [NSMutableArray new];
        _seenBeacons = [NSMutableArray new];
        _allBeacons = [NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithContentsOfFile:[self beaconsSavePath]]];
        if (_allBeacons == nil)
        {
            _allBeacons = [NSMutableArray new];
        }
        _requestStatus = [NSMutableDictionary new];
        _apiClient = [MTAPIClient sharedClient];
        _httpRequestQueue = [NSMutableArray new];
        beaconsByType = [NSMutableDictionary new];
    }
    return self;
}

- (void)addBeacon:(GMBLBeacon *)beacon shouldUpdate:(BOOL)shouldUpdate
{
    MDCustomTransmitter *customBeacon = [self findBeacon:beacon.identifier];
    if (!customBeacon)
    {
        customBeacon = [[MDCustomTransmitter alloc] init];
        [self.allBeacons addObject:customBeacon];
    }
    else
    {
//        DLog(@"\nbeacon exists already %@", customBeacon);
    }
    
    [self compareBeacons];
}

- (void)addBeacon:(GMBLBeacon *)beacon
{
    [self addBeacon:beacon shouldUpdate:NO];
}

- (void)updateValuesForBeacon:(MDCustomTransmitter *)customBeacon usingInfo:(id)transmitter
{
    if ([transmitter isKindOfClass:[GMBLBeacon class]]) {
        [customBeacon fillValuesFrom:transmitter];
    } else {
        // must be updating from API
        [customBeacon fillValuesFromAPI:transmitter];
    }
}

- (MDCustomTransmitter*)findBeacon:(NSString*)beaconID
{
    NSArray *currentBeacons = [NSArray arrayWithArray:self.allBeacons];
    
    NSInteger indexOfBeacon;
    NSIndexSet *foundBeacons = [currentBeacons indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj identifier].uppercaseString isEqualToString:beaconID.uppercaseString]) {
            return YES;
        } else {
            return NO;
        }
    }];
    
    if (foundBeacons.count == 1) {
        indexOfBeacon = [foundBeacons firstIndex];
        return [currentBeacons objectAtIndex:indexOfBeacon];
    } else {
        return nil;
    }
}

- (BOOL)updateRSSI:(NSNumber*)rssi forBeacon:(NSString*)beaconID {
    MDCustomTransmitter *beacon = [self findBeacon:beaconID];
    if (beacon)
    {
        beacon.RSSI = rssi;
        
        NSSet *seenBeacons = [NSSet setWithArray:self.seenBeacons];
        if ([seenBeacons containsObject:beacon] == NO)
        {
            NSMutableSet *seenBeaconsForType = [NSMutableSet setWithSet:self.beaconsByType[beacon.beaconType]];
            if (seenBeaconsForType == nil)
            {
                seenBeaconsForType = [NSMutableSet set];
            }
            [seenBeaconsForType addObject:beacon];
            self.beaconsByType[beacon.beaconType] = seenBeaconsForType;
        }
        return YES;
    }
    else
    {
//        DLog(@"\nbeacon not found");
        return NO;
    }
}

- (void)batchUpdateRSSIForBeacons:(NSDictionary*)beaconsWithRSSI
{
    NSArray *beaconIDs = [beaconsWithRSSI allKeys];
    __weak __typeof(&*self)weakSelf = self;
    [beaconIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         NSString *beaconName = obj;
         NSNumber *rssi = [beaconsWithRSSI objectForKey:beaconName];
         [weakSelf updateRSSI:rssi forBeacon:beaconName];
     }];
}

- (NSArray*)compareBeacons:(NSArray*)beaconCollection
{
    return [self compareBeacons:beaconCollection max:nil];
}

- (NSArray*)compareBeacons:(NSArray*)beaconCollection max:(NSNumber *)maxBeacons
{
    NSArray *collectionCopy = [NSArray arrayWithArray:beaconCollection];
    
    NSInteger defaultNilRSSI = [[[self.userDefaults objectForKey:MTP_BeaconOptions] objectForKey:MTP_DefaultNilRSSI] integerValue];
    NSInteger relevantBeaconCount = maxBeacons ? maxBeacons.integerValue : [[[self.userDefaults objectForKey:MTP_BeaconOptions] objectForKey:MTP_RelevantBeaconCount] integerValue];
    
    NSArray *sortedArray = [collectionCopy sortedArrayUsingComparator: ^(MDCustomTransmitter * obj1, MDCustomTransmitter * obj2) {
        if ([obj1 RSSI].intValue > [obj2 RSSI].intValue) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        
        if ([obj1 RSSI].intValue < [obj2 RSSI].intValue) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    NSDate *now = [NSDate date];

    __block NSMutableArray *relevantBeacons = [NSMutableArray new];
    [sortedArray enumerateObjectsUsingBlock:^(MDCustomTransmitter * obj, NSUInteger idx, BOOL *stop)
     {
         if (obj.lastSighted)
         {
             NSTimeInterval elapsedTime = [now timeIntervalSinceDate:obj.lastSighted];
             if (elapsedTime > 15)
             {
                 obj.lastSighted = nil;
                 obj.RSSI = @(defaultNilRSSI);
             }
             else
             {
                 if ([obj RSSI].integerValue < 0 &&
                     [obj RSSI].integerValue > defaultNilRSSI &&
                     relevantBeacons.count < MIN(sortedArray.count,relevantBeaconCount))
                 {
                     [relevantBeacons addObject:obj];
                 }
             }
         }
     }];
    
    return [NSArray arrayWithArray:relevantBeacons];
}

- (void)compareBeacons
{
    NSArray *relevantBeacons = [self compareBeacons:self.allBeacons];
    self.nearbyBeacons = [NSMutableArray arrayWithArray:relevantBeacons];
    self.activeBeacon = [self.nearbyBeacons firstObject];
}

- (BOOL)removeBeacon:(NSString*)beaconID {
    return false;
}

- (void)flushBeacons
{
    NSArray *currentBeacons = [NSArray arrayWithArray:self.allBeacons];
    
    NSMutableArray *beaconIDs = [NSMutableArray new];
    [currentBeacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         [beaconIDs addObject:[obj identifier]];
     }];
    
    [self.nearbyBeacons removeAllObjects];
    [self.allBeacons removeAllObjects];
}

- (void)resetBeaconTriggerState
{
    NSArray *currentBeacons = [NSArray arrayWithArray:self.allBeacons];
    
    [currentBeacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         [(MDCustomTransmitter *)obj setTriggeredEvent:false];
     }];
}

- (void)resetSeen
{
    NSArray *allBeacons = [NSArray arrayWithArray:self.allBeacons];
    [allBeacons enumerateObjectsUsingBlock:^(MDCustomTransmitter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         [obj setLastSighted:nil];
     }];
}

#pragma mark - API Pre-Request Processing

-(void)transmitBeaconData:(NSArray*)beaconCollection updateType:(NSString*)updateType {
    
    NSMutableArray *beaconIDs = [NSMutableArray new];
    NSDictionary *parameters;
    
    // search query validation checks
    if (beaconCollection)
    {
        [beaconCollection enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            [beaconIDs addObject:[obj identifier]];
        }];
    }
    else
    {
        DLog(@"\nno beacons in the data source");
        return;
    }
    
    if (!self.currentUser) {
        return;
    }
    
    // search query processing
    NSSet *beaconBasedEvents = [NSSet setWithObjects:kBeaconGetUsers,
                                kBeaconAddUser,
                                kBeaconDeleteUsers, nil];
    
    NSSet *userBasedEvents = [NSSet setWithObjects:kUserGetBeacons,
                              kUserAddBeacons,
                              kUserDeleteBeacons,nil];
    
    NSSet *beaconMemberEvents = [NSSet setWithObjects:kBeaconMemberAdd,
                                 kBeaconMemberUpdate,
                                 kBeaconMemberGet,
                                 kBeaconMemberDelete,nil];
    
    if ([beaconBasedEvents containsObject:updateType]) {
        [self processForBeacon:beaconIDs forUpdateType:updateType];
    }
    else if ([userBasedEvents containsObject:updateType]) {
        [self processForUser:beaconIDs forUpdateType:updateType];
    }
    else if ([beaconMemberEvents containsObject:updateType]) {
        NSString *apiURL = [NSString stringWithFormat:[NSString beaconMemberBaseURL],@"/%@"];
        NSString *beaconID = [beaconIDs firstObject];
        
        [self processForBeaconManagement:beaconID toAPIUrl:apiURL forUpdateType:updateType];
    } else if ([updateType isEqualToString:kBeaconEvents]) {
        // beacon event
        NSString *apiURL = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:[NSString beaconEvents],[[beaconIDs firstObject] uppercaseString]]];
        parameters = @{@"user_id":self.currentUser.user_id};
        [self sendGET:kBeaconEvents toAPIUrl:apiURL withParameters:parameters];
    } else {
        DLog(@"\nunknown request type in beacon manager - transmit beacon data");
    }
}

- (void)processForBeaconManagement:(NSString*)beaconID toAPIUrl:(NSString*)apiURL forUpdateType:(NSString*)updateType {
    NSDictionary *parameters;
    
    if (beaconID.length < 1) {
        DLog(@"\nno beacon id");
        return;
    }
    
    if ([updateType isEqualToString:kBeaconMemberGet]) {
        parameters = nil;
        [self sendGET:kBeaconMemberGet toAPIUrl:[NSString stringWithFormat:apiURL,beaconID] withParameters:parameters];
    } else if ([updateType isEqualToString:kBeaconMemberAdd]) {
        DLog(@"\nadd a beacon");
    } else if ([updateType isEqualToString:kBeaconMemberUpdate]) {
        DLog(@"\nupdate a beacon's information");
    } else {
        // must be delete
        [self sendDELETE:kBeaconMemberDelete toAPIUrl:[NSString stringWithFormat:apiURL,beaconID] withParameters:parameters];
    }
}

- (void)processForUser:(NSArray*)beaconIDs forUpdateType:(NSString*)updateType {
    NSDictionary *parameters;
    
    if ([updateType isEqualToString:kUserGetBeacons]) {
        DLog(@"\nGET command");
    } else {
        if (!beaconIDs.count) {
            return;
        }
        
        parameters = @{@"beacon_ids":beaconIDs};
        NSString *apiURL = [NSString stringWithFormat:[NSString userAddBeacons],self.currentUser.user_id];
        [self sendPUT:nil toAPIUrl:apiURL withParameters:parameters];
    }
}

- (void)processForBeacon:(NSArray*)beaconIDs forUpdateType:(NSString*)updateType {
    NSDictionary *parameters = @{@"user_id": self.currentUser.user_id};
    NSString *apiURL = [NSString stringWithFormat:[NSString beaconAddUser],[beaconIDs firstObject]];
    
    if ([updateType isEqualToString:kBeaconAddUser]) {
        [self sendPUT:nil toAPIUrl:apiURL withParameters:parameters];
    } else if ([updateType isEqualToString:kBeaconDeleteUsers]) {
        [self sendDELETE:nil toAPIUrl:apiURL withParameters:parameters];
    } else {
        // must be a get request
        [self sendGET:kBeaconGetUsers toAPIUrl:apiURL withParameters:parameters];
    }
}


#pragma mark - RESTful API Methods

- (void)sendPUT:(NSString*)beaconIDs toAPIUrl:(NSString*)apiURL withParameters:(NSDictionary*)parameters
{
    [[MTAPIClient sharedClient] PUT:apiURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([responseObject isKindOfClass:[NSDictionary class]])
         {
             DLog(@"\nresponse %@", responseObject);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         DLog(@"\noperationHttpMethod %@\nhttpHeaders %@\nhttpBody %@", [[operation request] HTTPMethod], [[operation request] allHTTPHeaderFields],[[NSString alloc] initWithData:[[operation request] HTTPBody] encoding:4]);
     }];
}

- (void)sendPOST:(id)objects toAPIUrl:(NSString*)apiURL withParameters:(NSDictionary*)parameters
{
    [[MTAPIClient sharedClient] POST:apiURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            DLog(@"\nresponse %@", responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DLog(@"\nerror %ld: %@",error.code,error.localizedDescription);
    }];
}

- (void)sendGET:(NSString*)requestType toAPIUrl:(NSString*)apiURL withParameters:(NSDictionary*)parameters
{
    [[MTAPIClient sharedClient] GET:apiURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([responseObject isKindOfClass:[NSDictionary class]])
         {
             if ([requestType isEqualToString:kBeaconEvents])
             {
                 NSArray *data = [responseObject objectForKey:@"data"];
                 __block NSString *beaconEventType;
                 [data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                  {
                      NSString *beaconType = [obj objectForKey:@"type"];
                      if ([beaconType isEqualToString:@"Sponsor Connection"])
                      {
                          DLog(@"\nfound a sponsor connection!");
                          beaconEventType = kEventTypeSponsorConnection;
                          [self processSilentRequest:obj];
                      }
                      else if ([beaconType isEqualToString:@"Session Check-in Connection"])
                      {
                          DLog(@"\nfound a session checkin station");
                          beaconEventType = kEventTypeSession;
                          [self processSilentRequest:obj];
                      }
                      else {
                          // must be a poll
                          beaconEventType = kEventTypePoll;
                          [self.alertManager showAlertForBeaconID:[[[responseObject objectForKey:@"input"] objectForKey:@"beacon_id"] uppercaseString]
                                                      withContent:[obj copy]
                                                         forEvent:beaconEventType];
                          return;
                      }
                  }];
             } else {
                 NSLog(@"\nDidn't succeed: %@",[responseObject objectForKey:@"message"]);
                 return;
             }
         } else {
             DLog(@"\ninvalid response object %@", responseObject);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         DLog(@"\n%@ error %@",requestType,@(error.code));
         DLog(@"\noperationHttpMethod %@\nhttpHeaders %@", [[operation request] HTTPMethod], [[operation request] allHTTPHeaderFields]);
     }];

}

- (void)sendDELETE:(NSString*)beaconIDs toAPIUrl:(NSString*)apiURL withParameters:(NSDictionary*)parameters
{
    [[MTAPIClient sharedClient] DELETE:apiURL parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([responseObject isKindOfClass:[NSDictionary class]])
         {
             DLog(@"\nresponseObject %@", responseObject);
         }
         else
         {
             DLog(@"\ninvalid response object %@", responseObject);
         }
         
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         DLog(@"\noperationHttpMethod %@\nhttpHeaders %@\nhttpBody %@", [[operation request] HTTPMethod], [[operation request] allHTTPHeaderFields],[[NSString alloc] initWithData:[[operation request] HTTPBody] encoding:4]);
     }];
}

- (void)processSilentRequest:(NSDictionary*)apiConnectionCheckinData {
    NSString *methodType;
    NSString *httpBody;
    NSString *endpoint;
    NSString *url;
    
    NSArray *allKeys = [apiConnectionCheckinData allKeys];
    if ([allKeys containsObject:@"action"])
    {
        if ([[apiConnectionCheckinData objectForKey:@"action"] isEqualToString:@"REST"])
        {
            if ([allKeys containsObject:@"url"]) {
                url = [apiConnectionCheckinData objectForKey:@"url"];
            } else {
                DLog(@"\nno key \"url\" found");
            }
            
            if ([allKeys containsObject:@"endpoint"]) {
                endpoint = [apiConnectionCheckinData objectForKey:@"endpoint"];
            } else {
                DLog(@"\nno key \"endpoint\" found");
            }
            
            if ([allKeys containsObject:@"request_body"]) {
                httpBody = [apiConnectionCheckinData objectForKey:@"request_body"];
            } else {
                DLog(@"\nno key \"request_body\" found");
            }
            
            if ([allKeys containsObject:@"request_method"])
            {
                methodType = [apiConnectionCheckinData objectForKey:@"request_method"];
                if ([methodType.lowercaseString isEqualToString:@"put"])
                {
                    NSURL *urlForPut = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url,endpoint]];
                    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:urlForPut];
                    [urlRequest setHTTPBody:[httpBody dataUsingEncoding:4]];
                    [urlRequest setHTTPMethod:@"PUT"];
                    [urlRequest setAllHTTPHeaderFields:@{@"accept": @"application/json",
                                                         @"content-type": @"application/json",
                                                         @"X-Authentication-Token": [[self.userDefaults objectForKey:MTP_NetworkOptions] objectForKey:MTP_XAuthToken]}];
                    
                    DLog(@"%@",apiConnectionCheckinData);
                    
                    __weak __typeof(&*self)weakSelf = self;
                    AFHTTPRequestOperation *operation = [[MTAPIClient sharedClient]
                                                         HTTPRequestOperationWithRequest:urlRequest
                                                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                             
                                                             DLog(@"\nresponse %@", responseObject);
                                                             NSDictionary *responseData = [responseObject objectForKey:@"data"];
                                                             NSNumber *checkinData = [weakSelf validateSessionCheckinResponse:responseData];
                                                             if (checkinData)
                                                             {
                                                                 BOOL alreadyCheckedIn = checkinData.boolValue;
                                                                 if (!alreadyCheckedIn)
                                                                 {
                                                                     [weakSelf processSilentRequestReturnData:[[responseObject objectForKey:@"input"] copy]];
                                                                 }
                                                                 else
                                                                 {
                                                                     DLog(@"\nuser was already checked into session");
                                                                     [weakSelf processSilentRequestReturnData:[[responseObject objectForKey:@"input"] copy]];
                                                                 }
                                                             }
                                                         }
                                                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                             
                                                             if (error.code == 409 || error.code == -1011) {
                                                                 DLog(@"\nalready checked-in to %@", endpoint);
                                                                 /*
                                                                  [self processSilentRequestReturnData:@{@"endpoint":@"/session/125/checkin",
                                                                  @"user_id": @(1),
                                                                  @"session_id": @(125)}];
                                                                  */
                                                             } else {
                                                                 DLog(@"\noperation %@\nerror %@",operation,error);
                                                             }
                                                         }];
                    
                    [[[MTAPIClient sharedClient] operationQueue] addOperation:operation];
                }
            } else {
                DLog(@"\nno key \"request_method\" found");
            }
        } else {
            DLog(@"\naction isnt a REST request");
        }
    } else {
        DLog(@"\ndoesn't contain action type");
    }
}

- (NSNumber *)validateSessionCheckinResponse:(id)responseData
{
    NSNumber *validCheckinData = nil;
    if ([responseData isKindOfClass:[NSDictionary class]])
    {
        id alreadyCheckedInNumber = [responseData objectForKey:@"already_checkedin"];
        if ([alreadyCheckedInNumber isKindOfClass:[NSNumber class]])
        {
            validCheckinData = alreadyCheckedInNumber;
        }
    }
    return validCheckinData;
}

- (void)processSilentRequestReturnData:(NSDictionary *)requestInput
{
    if (!requestInput)
    {
        NSLog(@"request input was nil");
        return;
    }
    
    /* request input
     {
     "endpoint": "/session/31/checkin",
     "user_id": 1,
     "session_id": 31
     }*/
    
    if ([requestInput objectForKey:@"session_id"])
    {
        [self checkForSessionPoll:[requestInput objectForKey:@"session_id"]];
    }
    else if ([requestInput objectForKey:@"sponsor_id"])
    {
        // sponsor creation
        NSNumber *sponsorID = [requestInput objectForKey:@"sponsor_id"];
        Sponsor *sponsor = [self.sponsorManager getSponsor:sponsorID];
        [self.alertManager showAlertForBeaconID:nil
                                    withContent:@{@"title": sponsor.sponsor_name}
                                       forEvent:kEventTypeSponsorConnection];
    }
    else
    {
        // other option
        NSLog(@"%@",[requestInput objectForKey:@"endpoint"]);
    }
}

- (void)checkForSessionPoll:(NSNumber *)sessionID {
    MTPSession *session = [self.sessionManager getSession:@(sessionID.integerValue)];
    if (!session) {
        return;
    }
    
    if (session.goto_session_details.boolValue)
    {
        NSMutableDictionary *pollDetailsDictionary = [NSMutableDictionary dictionaryWithDictionary:@{@"endpoint": [NSString stringWithFormat:@"/session/%@/poll",session.session_id]}];
        [pollDetailsDictionary setObject:[NSString stringWithFormat:@"%@/%@",[NSString agendaURL],self.currentUser.user_id] forKey:@"url"];
        [pollDetailsDictionary setObject:@"go to session was true, but we still need to pass along the sessionID to open the session details" forKey:@"goto_session_details"];
        [self.alertManager showAlertForBeaconID:nil
                                    withContent:pollDetailsDictionary
                                       forEvent:kEventTypeSession];
    }
    else
    {
        __weak __typeof(&*self)weakSelf = self;
        NSString *sessionPollURL = [NSString stringWithFormat:[NSString sessionPoll],sessionID];
        [[MTAPIClient sharedClient] GET:sessionPollURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            /*
             {
             "input": {
             "endpoint": "/session/31/poll",
             "session_id": 31
             },
             "success": true,
             "data": {
             "questions": [
             {
             "question_id": 2,
             "answers": [
             {
             "answer": true,
             "answer_id": 3
             },
             {
             "answer": false,
             "answer_id": 4
             }
             ],
             "question": "Are you on iOS?"
             }
             ],
             "schedule_id": 29,
             "title": "MikesTestSession",
             "session_id": 31,
             "poll_id": 2
             },
             "info": {
             "count": 1
             }
             }
             */
            
            if ([[responseObject objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
            {
                NSMutableDictionary *pollDetailsDictionary = [NSMutableDictionary dictionaryWithDictionary:[responseObject objectForKey:@"data"]];
                [pollDetailsDictionary setObject:[[responseObject objectForKey:@"input"] objectForKey:@"endpoint"]
                                          forKey:@"endpoint"];
                
                [pollDetailsDictionary setObject:[self pollURL:@{@"schedule_id": [pollDetailsDictionary objectForKey:@"schedule_id"],
                                                                 @"poll_id": [pollDetailsDictionary objectForKey:@"poll_id"],
                                                                 @"session_id": [pollDetailsDictionary objectForKey:@"session_id"]}]
                                          forKey:@"url"];
                //            /qr/3/{poll_id}/?sID={session_id}&scID={schedule_id}
                [weakSelf.alertManager showAlertForBeaconID:nil withContent:pollDetailsDictionary forEvent:kEventTypeSessionPoll];
            }
            else
            {
                DLog(@"\nNo poll found for session %@", sessionID);
                //                NSDictionary *sessionDetailsDictionary = [responseObject objectForKey:@"input"];
                //                [weakSelf.alertManager showAlertForBeaconID:nil withContent:sessionDetailsDictionary forEvent:kEventTypeSession];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             DLog(@"\nfailed attempt");
         }];
    }
}

- (NSString *)pollURL:(NSDictionary *)pollURLParameters
{
    // {poll_id}/?sID={session_id}&scID={schedule_id}&user_id={user_id}
    // append the id when the webview loads
    NSString *pollURL = [NSString stringWithFormat:@"%@/?sID=%@&scID=%@&",
                         [pollURLParameters objectForKey:@"poll_id"],
                         [pollURLParameters objectForKey:@"session_id"],
                         [pollURLParameters objectForKey:@"schedule_id"]];
    return [NSString stringWithFormat:[NSString pollWithIDURL],pollURL];
}

- (void)transmitBeaconData:(NSArray*)beaconCollection
{
    DLog(@"\nupload beacon data");
    [self transmitBeaconData:beaconCollection updateType:nil];
}

- (void)getEventBeacons
{
    __weak __typeof(&*self)weakSelf = self;
    NSMutableURLRequest *eventBeaconRequest = [NSURLSession defaultRequestMethod:@"GET" URL:[NSString eventBeacons] parameters:nil];
    [[[NSURLSession sharedSession] dataTaskWithRequest:eventBeaconRequest
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          id responseObject = [NSURLSession serializeJSONData:data response:response error:error];
          if (!responseObject) {
              return;
          }
          if ([responseObject isKindOfClass:[NSDictionary class]])
          {
              NSArray *eventBeacons = [responseObject objectForKey:@"data"];
              if (eventBeacons.count > 0)
              {
                  [eventBeacons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                   {
                       if (![obj isKindOfClass:[NSDictionary class]])
                       {
                           return;
                       }
                       
                       MDCustomTransmitter *beacon = [weakSelf findBeacon:[[obj objectForKey:@"beacon_id"] mtp_stringValue]];
                       BOOL foundNewBeacon = NO;
                       if (!beacon)
                       {
                           beacon = [[MDCustomTransmitter alloc] init];
                           foundNewBeacon = YES;
                       }
                       else
                       {
                           //                         DLog(@"\nfound old beacon %@", beacon);
                       }
                       
                       [weakSelf updateValuesForBeacon:beacon usingInfo:obj];
                       beacon.RSSI = [[self.userDefaults objectForKey:MTP_BeaconOptions] objectForKey:MTP_DefaultNilRSSI];
                       
                       if (foundNewBeacon)
                       {
                           [weakSelf.allBeacons addObject:beacon];
                       }
                   }];
                  //                DLog(@"\nself.allBeacon %@", weakSelf.allBeacons);
                  
                  if ([self archiveBeacons:weakSelf.allBeacons])
                  {
                      DLog(@"\narchived beacons");
                  }
                  else
                  {
                      DLog(@"\ndid not archive beacons");
                  }
              }
              else
              {
                  DLog(@"\nNo Data from webservice");
              }
          }
      }] resume];
}

- (BOOL)archiveBeacons:(NSArray *)beacons
{
    NSString *savePath = [self beaconsSavePath];
    BOOL saved = [NSKeyedArchiver archiveRootObject:beacons toFile:savePath];
    return saved;
}

- (NSString *)beaconsSavePath
{
    NSString *beaconSavePath = [[[[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject] URLByAppendingPathComponent:@"beadons.data"] path];
    return beaconSavePath;
}

@end
