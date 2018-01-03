//
//  MTPOneSignalInterface.m
//  MeetingPlay
//
//  Created by MeetingPlay on 12/12/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPOneSignalInterface.h"
#import "MTPAppSettingsKeys.h"
#import "EventKeys.h"
#import "OneSignal.h"
#import "MTPDLogDefine.h"
#import "OneSignal.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSMutableURLRequest+MTPHelper.h"
#import "NSObject+MTPModelValidation.h"
#import "MTPApplicationDefaultsConstants.h"

@implementation MTPOneSignalInterface

+ (void)signUpForNotifications:(NSNumber *)userID attendeeTypeID:(NSNumber *)attendeeTypeID
{
    [self fetchUserInfo:userID completion:^(NSNumber *fetchedUserID, NSNumber *fetchedAttendeeTypeID, NSURLResponse *response, NSError *error)
     {
         [self transmitUserDataToOneSignal:fetchedUserID attendeeTypeID:fetchedAttendeeTypeID];
     }];
}

+ (void)transmitUserDataToOneSignal:(NSNumber *)userID attendeeTypeID:(NSNumber *)attendeeTypeID
{
    NSString *baseAPI = [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL];
    NSURL *baseAPIURL = [NSURL URLWithString:baseAPI];
    NSArray *baseAPIParts = [baseAPIURL.host componentsSeparatedByString:@"."];
    NSString *conferenceName = baseAPIParts.firstObject;
    
    // Store the deviceToken in the current Installation and save it to Parse
    if (userID)
    {
        if (conferenceName.length)
        {
            [OneSignal sendTag:[NSString stringWithFormat:@"%@_userID",conferenceName]
                         value:[NSString stringWithFormat:@"%@",userID]];
        }
    }
    else if ([[NSUserDefaults standardUserDefaults] objectForKey:kUserID])
    {
        if (conferenceName.length)
        {
            [OneSignal sendTag:[NSString stringWithFormat:@"%@_userID",conferenceName]
                         value:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kUserID]]];
        }
    }
    else
    {
        DLog(@"\nno user id found registering for remote notifications");
    }
    
    if (attendeeTypeID && conferenceName.length)
    {
        [OneSignal sendTag:[NSString stringWithFormat:@"%@_attendeeTypeID",conferenceName]
                     value:[NSString stringWithFormat:@"%@",attendeeTypeID]];
    }
    
    [OneSignal IdsAvailable:^(NSString *userId, NSString *pushToken) {
        [self sendPlayerID:userId forUser:userID];
    }];
}


+ (void)fetchUserInfo:(NSNumber *)userID completion:(void(^)(NSNumber *userID, NSNumber *attendeeTypeID,NSURLResponse *response,NSError *error))completionHandler
{
    NSMutableURLRequest *userInfoRequest = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:[NSString stringWithFormat:@"%@/%@",[NSString userInfo],userID] parameters:nil];
    [[[NSURLSession sharedSession] dataTaskWithRequest:userInfoRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
    {
        NSError *requestError = nil;
        NSNumber *fetchedUserID = userID;
        NSNumber *fetchedAttendeeTypeID = nil;
        
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
                NSMutableDictionary *userInfoData = responseObject[@"data"];
                NSNumber *remoteAttendeeTypeID = [userInfoData[@"attendeetypeid"] mtp_numberValue];
                if (remoteAttendeeTypeID)
                {
                    fetchedAttendeeTypeID = remoteAttendeeTypeID;
                }
                
                NSNumber *remoteUserID = [userInfoData[@"user_id"] mtp_numberValue];
                if (remoteUserID)
                {
                    fetchedUserID = remoteUserID;
                }
            }
            else
            {
                DLog(@"\nrequest error %@",requestError);
            }
        }
        
        if (completionHandler)
        {
            completionHandler(fetchedUserID,fetchedAttendeeTypeID,response,requestError);
        }
    }] resume];
}

+ (void)sendPlayerID:(NSString *)playerID forUser:(NSNumber *)userID
{
    if (playerID.length && userID)
    {
        NSMutableURLRequest *playerIDRequest = [NSMutableURLRequest mtp_defaultRequestMethod:@"PUT" URL:[NSString stringWithFormat:[NSString userPlayerID],userID] parameters:@{@"player_id":playerID}];
        [[[NSURLSession sharedSession] dataTaskWithRequest:playerIDRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            NSError *requestError = nil;
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
                    DLog(@"\nresponse object %@",responseObject);
                }
                else
                {
                    DLog(@"\nrequest error %@",requestError);
                }
            }
            
        }] resume];
    }
    
}

@end
