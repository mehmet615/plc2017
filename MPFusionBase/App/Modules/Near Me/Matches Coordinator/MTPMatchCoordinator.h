//
//  MTPMatchCoordinator.h
//  CPC2016
//
//  Created by Michael Thongvanh on 11/30/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTPMatchProfile;

@interface MTPMatchCoordinator : NSObject

@property (readonly, copy, nonatomic) NSArray *matches;
@property (readonly, copy, nonatomic) NSArray *sponsorMatches;

- (void)checkMatchesEnabled:(void(^)(BOOL enabled))completionHandler;
- (void)checkCompanyEnabled:(void(^)(BOOL enabled))completionHandler;
/*
 *  Returns an array of MTPMatchProfile objects for a user
 */
- (void)matches:(NSNumber *)userID completion:(void (^)(NSArray *matches, NSError *error))completionHandler;
- (NSArray *)matchingUserIDsForCompany:(NSString *)matchingCompany attendees:(NSArray *)attendees;
/*
 *  Returns the MTPMatchProfile object for the matched user with the potentialMatchID or nil if not a match
 */
- (MTPMatchProfile *)matchProile:(NSNumber *)potentialMatchID;
- (BOOL)isMatch:(NSNumber *)potentialMatchID;

- (BOOL)showedMatchAlert:(NSNumber *)userID;
- (void)addMatchAlertID:(NSNumber *)userID;

- (BOOL)showedCompanyAlert:(NSNumber *)userID;
- (void)addCompanyAlertID:(NSNumber *)userID;
/*
 *  Returns an array of sponsor MTPMatchProfile objects for a user
 */
- (void)sponsorMatches:(NSNumber *)userID completion:(void(^)(NSArray *sponsorMatches,NSError *error))completionHandler;
- (MTPMatchProfile *)sponsorMatchProile:(NSString *)potentialBeaconMatch;
- (BOOL)isSponsorMatch:(NSString *)potentialBeaconMatch;

- (BOOL)showedSponsorMatchAlert:(NSString *)potentialBeaconMatch;
- (void)addSponsorMatchAlertID:(NSString *)potentialBeaconMatch;

- (void)resetMatches;

@end
