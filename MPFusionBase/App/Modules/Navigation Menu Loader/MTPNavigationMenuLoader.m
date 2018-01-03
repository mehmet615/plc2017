//
//  MTPNavigationMenuLoader.m
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 1/21/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "MTPNavigationMenuLoader.h"
#import "AFNetworkReachabilityManager.h"
#import "NSObject+EventDefaultsHelpers.h"

#import "MTPMenuItem.h"

#import "NSString+MTPAPIAddresses.h"
#import "NSURLSession+MTPCategory.h"
#import "MTPAppSettingsKeys.h"

@implementation MTPNavigationMenuLoader

NSString *const MTP_ErrorDomain = @"com.MeetingPlay.MPEvents.MainMenuUpdateError";

- (BOOL)verifyNetworkConnection
{
    return YES;
    
    if ([[AFNetworkReachabilityManager sharedManager] isReachable])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)availableMeeting:(NSString *)meetingName navigationMenu:(NSString *)navigationMenuName lastUpdate:(NSDate *)lastMenuUpdate completionHandler:(void (^)(BOOL, NSError *))completionHandler
{
    if (completionHandler)
    {
        completionHandler(YES,nil);
    }
}


- (void)fetchMeeting:(NSString *)meetingName updatedMenu:(NSString *)navigationMenuName completionHandler:(void (^)(id responseObject,NSError *updateError))completionHandler
{
    if ([self verifyNetworkConnection] == NO)
    {
        if (completionHandler)
        {
            NSError *updateMenuError = [NSError errorWithDomain:MTP_ErrorDomain
                                                           code:1111
                                                       userInfo:@{NSLocalizedDescriptionKey:@"No Network Connection Available"}];
            completionHandler(nil,updateMenuError);
        }
        return;
    }
    else if (navigationMenuName.length == 0 || meetingName.length == 0)
    {
        if (completionHandler)
        {
            NSError *updateMenuError = [NSError errorWithDomain:MTP_ErrorDomain
                                                           code:1112
                                                       userInfo:@{NSLocalizedDescriptionKey:@"No Menu Name Supplied"}];
            completionHandler(nil,updateMenuError);
        }
        return;
    }
    else
    {
        NSString *navigationMenuURL = [NSString navigationMenuItems:meetingName menuName:navigationMenuName];
        
        NSMutableURLRequest *updateMenuRequest = [NSURLSession defaultRequestMethod:@"GET"
                                                                                URL:navigationMenuURL
                                                                         parameters:nil];
        
        updateMenuRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:updateMenuRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
          {
              if (error)
              {
                  if (completionHandler)
                  {
                      completionHandler(nil,error);
                  }
                  return;
              }
              
              NSError *serializationError = nil;
              id responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&serializationError];
              
              if (responseObject)
              {
                  if ([responseObject writeToFile:[[self updatedMenuSaveURL] path] atomically:NO])
                  {
                      DLog(@"\nsaved to url %@",[self updatedMenuSaveURL]);
                  }
                  
                  if (completionHandler)
                  {
                      completionHandler(responseObject,error);
                  }
              }
              else
              {
                  NSError *menuUpdateError = [NSError errorWithDomain:MTP_ErrorDomain
                                                                 code:1113
                                                             userInfo:@{NSLocalizedDescriptionKey: @"Error loading remote navigation menu file."}];
                  
                  if (completionHandler)
                  {
#ifdef DEBUG
                      NSHTTPURLResponse *navigationUpdateResponse = (NSHTTPURLResponse *)response;
                      DLog(@"\nResponse object was nil! HTTP Status Code %@",@(navigationUpdateResponse.statusCode));
                      completionHandler(nil,menuUpdateError);
#else
                      completionHandler(nil,nil);
#endif
                  }
              }
              
          }] resume];
    }
}

- (NSURL *)updatedMenuSaveURL
{
    NSURL *menuUpdateSaveURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    menuUpdateSaveURL = [menuUpdateSaveURL URLByAppendingPathComponent:@"UpdatedMenuItems.mtparchive"];
    return menuUpdateSaveURL;
}

@end
