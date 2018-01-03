//
//  MTPNearbyCoordinator.m
//  MeetingPlay
//
//  Created by MeetingPlay on 4/3/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPNearbyCoordinator.h"
#import "MDCustomTransmitter.h"
#import "MDBeaconManager.h"
#import "User.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSMutableURLRequest+MTPHelper.h"

#import "MTPDLogDefine.h"
#import "NSObject+MTPModelValidation.h"

#import <CoreData/CoreData.h>

@implementation MTPNearbyCoordinator

- (void)updateNearbyAttendees:(void(^)(BOOL enabled,NSString *message))completionHandler
{    
    [self checkNearbyEnabled:^(BOOL enabled,NSString *message){
        if (completionHandler)
        {
            completionHandler(enabled,message);
        }
    }];
}

- (void)checkNearbyEnabled:(void(^)(BOOL enabled,NSString *message))completionHandler
{
    NSString *featureEnabled = [NSString apiSettings];
    NSMutableURLRequest *nearbyCheck = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:featureEnabled parameters:nil];
    [[[NSURLSession sharedSession] dataTaskWithRequest:nearbyCheck completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *requestError = nil;
        BOOL enabled = NO;
        NSString *message = nil;
        if (error)
        {
            DLog(@"\nerror %@",error);
            requestError = error;
        }
        else
        {
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&requestError];
            if (responseObject && [responseObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dataDictionary = [responseObject[@"data"] firstObject];
                
                enabled = [[dataDictionary[@"displayshowmylocation"] mtp_numberValue] boolValue];
                message = [dataDictionary[@"apinoattendeesmessage"] mtp_stringValue];
            }
            else
            {
                DLog(@"\nrequest error %@",requestError);
            }
        }
        
        if (completionHandler)
        {
            completionHandler(enabled,message);
        }
    }] resume];
}

- (NSArray *)nearbyUsers:(NSNumber *)userID
{
    if (userID == nil)
    {
        return nil;
    }
    
    NSArray *nearbyUsers = [NSArray new];
    NSMutableArray *beacons = [NSMutableArray new];
    
    NSArray *beaconTypes = @[@"User",@"Hotel Representative"];
    for (NSString *beaconType in beaconTypes)
    {
        id nearbyUserBeacons = self.beaconManager.beaconsByType[beaconType];
        if ([nearbyUserBeacons isKindOfClass:[NSSet class]])
        {
            [beacons addObjectsFromArray:[nearbyUserBeacons allObjects]];
        }
    }
    
    NSMutableArray *beaconIDsByProximity = [NSMutableArray new];
    NSMutableArray *sortedUserBeacons = [[self.beaconManager compareBeacons:beacons max:@20] mutableCopy];
    for (MDCustomTransmitter *beacon in sortedUserBeacons)
    {
        [beaconIDsByProximity addObject:beacon.identifier];
    }
#ifdef DEBUG
    // for testing NEAR YOU

    beaconIDsByProximity = @[@"40270",
                             @"36808"];

#endif
    NSArray *attendees = [self attendeesForBeaconIDs:beaconIDsByProximity userID:userID];
    
    __block NSMutableArray *attendeesSortedByBeaconStrength = [NSMutableArray new];
    [sortedUserBeacons enumerateObjectsUsingBlock:^(MDCustomTransmitter * _Nonnull beacon, NSUInteger idx, BOOL * _Nonnull stop)
     {
         [attendees enumerateObjectsUsingBlock:^(User * _Nonnull attendee, NSUInteger idx, BOOL * _Nonnull stop)
          {
              if ([beacon.identifier isEqual:attendee.beaconid] && attendee.showmylocation.boolValue == YES)
              {
                  [attendeesSortedByBeaconStrength addObject:attendee];
                  *stop = YES;
              }
          }];
     }];
    
    nearbyUsers = [attendeesSortedByBeaconStrength copy];
#ifdef DEBUG
    // for testing NEAR YOU
    nearbyUsers = attendees;
#endif
    return nearbyUsers;
}

- (NSArray *)attendeesForBeaconIDs:(NSArray *)beaconIDs userID:(NSNumber *)currentUserID
{
    if (beaconIDs.count == 0 || currentUserID == nil)
    {
        return nil;
    }
    //    currentUserID = @2;
    NSFetchRequest *beaconIDFetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    beaconIDFetchRequest.predicate = [NSPredicate predicateWithFormat:@"beaconid IN %@ AND user_id != %@",beaconIDs,currentUserID];
    NSError *fetchError = nil;
    NSArray *matchingAttendees = [self.rootObjectContext executeFetchRequest:beaconIDFetchRequest error:&fetchError];
    if (fetchError)
    {
        DLog(@"\nfetchError %@",fetchError);
    }
    return matchingAttendees;
}
@end
