//
//  MTPMatchCoordinator.m
//  CPC2016
//
//  Created by Michael Thongvanh on 11/30/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPMatchCoordinator.h"
#import "MTPMatchProfile.h"
#import "NSMutableURLRequest+MTPHelper.h"
#import "NSString+MTPAPIAddresses.h"
#import "MTPDLogDefine.h"
#import "NSObject+MTPModelValidation.h"
#import "User.h"

@interface MTPMatchCoordinator ()
@property (readwrite, nonatomic, copy) NSArray *matches;
@property (strong, nonatomic) NSMutableSet *matchIDAlerts;
@property (strong, nonatomic) NSMutableSet *companyIDAlerts;
@property (readwrite, nonatomic, copy) NSArray *sponsorMatches;
@property (strong, nonatomic) NSMutableSet *sponsorMatchIDAlerts;
@end

@implementation MTPMatchCoordinator

- (instancetype)init
{
    if (self = [super init])
    {
        _matchIDAlerts = [NSMutableSet new];
        _sponsorMatchIDAlerts = [NSMutableSet new];
        _companyIDAlerts = [NSMutableSet new];
    }
    return self;
}

- (void)matches:(NSNumber *)userID completion:(void (^)(NSArray *, NSError *))completionHandler
{
    NSString *matches = [NSString mtp_matches:userID];
    NSMutableURLRequest *matchesRequest = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:matches parameters:nil];
    
    __weak typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:matchesRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *requestError = nil;
        NSArray *matchProfiles = nil;
        if (error)
        {
            DLog(@"\nerror %@",error);
            requestError = error;
        }
        else
        {
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&requestError];
            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                NSMutableArray *temporaryMatches = [NSMutableArray new];
                NSDictionary *responseData = responseObject[@"data"];
                
                for (NSDictionary *matchData in  responseData)
                {
                    MTPMatchProfile *matchProfile = [MTPMatchProfile profile:matchData];
                    if (matchProfile)
                    {
                        [temporaryMatches addObject:matchProfile];
                    }
                }

                matchProfiles = [NSArray arrayWithArray:temporaryMatches];
                weakSelf.matches = [NSArray arrayWithArray:matchProfiles];
            }
            else
            {
                DLog(@"\nrequest error %@",requestError);
            }
        }
        
        if (completionHandler)
        {
            completionHandler(matchProfiles,requestError);
        }
    }] resume];
}

- (NSArray *)matchingUserIDsForCompany:(NSString *)matchingCompany attendees:(NSArray *)attendees
{
    NSMutableArray *matchingUserIDs = [NSMutableArray new];
    for (User *attendee in attendees)
    {
        if (attendee.company.length)
        {
            if ([matchingCompany compare:attendee.company options:NSCaseInsensitiveSearch] == NSOrderedSame)
            {
                NSNumber *userID = attendee.user_id;
                if (userID)
                {
                    [matchingUserIDs addObject:userID];
                }
            }
        }
        else
        {
            NSLog(@"%@",attendee.user_id);
        }
    }
    return matchingUserIDs;
}

- (void)sponsorMatches:(NSNumber *)userID completion:(void(^)(NSArray *sponsorMatches,NSError *error))completionHandler
{
    NSString *matches = [NSString mtp_sponsorMatches:userID];
    NSMutableURLRequest *matchesRequest = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:matches parameters:nil];
    
    __weak typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:matchesRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSError *requestError = nil;
        NSArray *matchProfiles = nil;
        if (error)
        {
            DLog(@"\nerror %@",error);
            requestError = error;
        }
        else
        {
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&requestError];
            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                NSMutableArray *temporaryMatches = [NSMutableArray new];
                NSDictionary *responseData = responseObject[@"data"];
                
                for (NSDictionary *matchData in  responseData)
                {
                    MTPMatchProfile *matchProfile = [MTPMatchProfile profile:matchData];
                    if (matchProfile)
                    {
                        [temporaryMatches addObject:matchProfile];
                    }
                }
                
                matchProfiles = [NSArray arrayWithArray:temporaryMatches];
                weakSelf.sponsorMatches = [NSArray arrayWithArray:matchProfiles];
            }
            else
            {
                DLog(@"\nrequest error %@",requestError);
            }
        }
        
        if (completionHandler)
        {
            completionHandler(matchProfiles,requestError);
        }
    }] resume];
}

#pragma mark Attendee Section
- (MTPMatchProfile *)matchProile:(NSNumber *)potentialMatchID
{
    MTPMatchProfile *matchProfile = nil;
    for (MTPMatchProfile *profile in self.matches)
    {
        if ([profile.userID isEqual:potentialMatchID])
        {
            matchProfile = profile;
            break;
        }
    }
    
    return matchProfile;
}

- (BOOL)isMatch:(NSNumber *)potentialMatchID
{
    for (MTPMatchProfile *profile in self.matches)
    {
        if ([profile.userID isEqual:potentialMatchID])
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)showedMatchAlert:(NSNumber *)userID
{
    return [self.matchIDAlerts containsObject:userID];
}

- (void)addMatchAlertID:(NSNumber *)userID
{
    if (userID)
    {
        [self.matchIDAlerts addObject:userID];
    }
}

- (BOOL)showedCompanyAlert:(NSNumber *)userID
{
    return [self.companyIDAlerts containsObject:userID];
}

- (void)addCompanyAlertID:(NSNumber *)userID
{
    if (userID)
    {
        [self.companyIDAlerts addObject:userID];
    }
}

- (void)checkMatchesEnabled:(void(^)(BOOL enabled))completionHandler
{
    NSString *featureEnabled = @"http://deploy.meetingplay.com/app-navigation/masters2017/nearbyFeature.json";
    NSMutableURLRequest *nearbyCheck = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:featureEnabled]];
    [[[NSURLSession sharedSession] dataTaskWithRequest:nearbyCheck completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *requestError = nil;
        BOOL enabled = NO;
        
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
                enabled = [[responseObject[@"matchesEnabled"] mtp_numberValue] boolValue];
            }
            else
            {
                DLog(@"\nrequest error %@",requestError);
            }
        }
        
        if (completionHandler)
        {
            completionHandler(enabled);
        }
    }] resume];
}

- (void)checkCompanyEnabled:(void(^)(BOOL enabled))completionHandler
{
    NSString *featureEnabled = @"http://deploy.meetingplay.com/app-navigation/masters2017/nearbyFeature.json";
    NSMutableURLRequest *nearbyCheck = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:featureEnabled] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15];
    [[[NSURLSession sharedSession] dataTaskWithRequest:nearbyCheck completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSError *requestError = nil;
        BOOL enabled = NO;
        
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
                enabled = [[responseObject[@"companyEnabled"] mtp_numberValue] boolValue];
            }
            else
            {
                DLog(@"\nrequest error %@",requestError);
            }
        }
        
        if (completionHandler)
        {
            completionHandler(enabled);
        }
    }] resume];
}

#pragma mark Sponsor Section
- (MTPMatchProfile *)sponsorMatchProile:(NSString *)potentialBeaconMatch
{
    MTPMatchProfile *matchProfile = nil;
    for (MTPMatchProfile *profile in self.sponsorMatches)
    {
        if ([profile.beaconID isEqual:potentialBeaconMatch])
        {
            matchProfile = profile;
            break;
        }
    }
    
    return matchProfile;
}

- (BOOL)isSponsorMatch:(NSString *)potentialBeaconMatch
{
    for (MTPMatchProfile *profile in self.sponsorMatches)
    {
        if ([profile.beaconID isEqual:potentialBeaconMatch])
        {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)showedSponsorMatchAlert:(NSString *)potentialBeaconMatch
{
    return [self.sponsorMatchIDAlerts containsObject:potentialBeaconMatch];
}

- (void)addSponsorMatchAlertID:(NSString *)potentialBeaconMatch
{
    if (potentialBeaconMatch)
    {
        [self.sponsorMatchIDAlerts addObject:potentialBeaconMatch];
    }
}

- (void)resetMatches
{
    self.matches = [NSArray new];
    self.matchIDAlerts = [NSMutableSet new];
    
    self.sponsorMatches = [NSArray new];
    self.sponsorMatchIDAlerts = [NSMutableSet new];
}

- (void)setMatches:(NSArray *)matches
{
    _matches = matches;
}
@end
