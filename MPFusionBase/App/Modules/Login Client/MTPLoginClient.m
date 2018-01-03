//
//  MTPLoginClient.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/8/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPLoginClient.h"
#import "NSObject+EventDefaultsHelpers.h"
//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"
#import "EventKeys.h"
#import "User+Helpers.h"
#import "NSURLSession+MTPCategory.h"
#import "MTPAppSettingsKeys.h"

#import "NSMutableURLRequest+MTPHelper.h"

@interface MTPLoginClient ()
@property (nonatomic, strong) NSManagedObjectContext *scratchContext;
@end

@implementation MTPLoginClient

+ (instancetype)loginClient:(NSManagedObjectContext *)rootObjectContext
{
    return [[MTPLoginClient alloc] init:rootObjectContext];
}

- (instancetype)init:(NSManagedObjectContext *)rootObjectContext
{
    self = [super init];
    if (self) {
        _scratchContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _scratchContext.parentContext = rootObjectContext;
    }
    return self;
}

- (void)login:(NSString *)username
     password:(NSString *)password
successHandler:(void (^)(id responseObject, User *currentUser))successHandler
failureHandler:(void (^)(NSError *))failureHandler
validationError:(NSError *)validationError
{
    validationError = [self validate:username password:password];
    if (validationError) {
        if (failureHandler) {
            failureHandler(validationError);
        }
        return;
    }
    
    NSNumber *languageID = [[NSUserDefaults standardUserDefaults] objectForKey:@"languageID"];
    if (languageID == nil)
    {
        languageID = @1;
    }
    
    NSString *requestURL = [NSString loginURL];
    
    NSMutableURLRequest *URLRequest = [NSURLSession defaultRequestMethod:@"POST" URL:requestURL parameters:@{kLoginEmail: [NSString stringWithFormat:@"%@",username],
                                                                                                             @"languageid": languageID}];
    
    __weak __typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:URLRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            if (failureHandler)
            {
                failureHandler(error);
            }
            else
            {
                DLog(@"\nNo login failure handler found");
            }
        }
        else
        {
            NSError *serializationError = nil;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
            if (serializationError)
            {
                if (failureHandler)
                {
                    failureHandler(serializationError);
                }
            }
            else
            {
                if (![[responseObject objectForKey:@"success"] boolValue])
                {
                    if (failureHandler)
                    {
                        NSDictionary *errors = [[responseObject objectForKey:@"errors"] firstObject];
                        NSString *errorMessage = [errors objectForKey:@"message"] ? [errors objectForKey:@"message"] : @"Login Error";
                        failureHandler([NSError errorWithDomain:[self bundleIdentifier]
                                                           code:10002
                                                       userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"loginFailedUsername", nil),
                                                                  NSLocalizedFailureReasonErrorKey: errorMessage}]);
                    }
                    else
                    {
                        DLog(@"\nNo login failure handler found");
                    }
                }
                else
                {
                    NSNumber *userID = [[responseObject objectForKey:@"data"] objectForKey:kUserID];
                    
                    if (userID)
                    {
                        User *loggedInUser = [User findUser:userID context:weakSelf.scratchContext];
                        if (!loggedInUser)
                        {
                            loggedInUser = [User createInContext:weakSelf.scratchContext];
                        }
                        
                        loggedInUser.loggedIn = @(true);
                        loggedInUser.user_id = userID;
                        NSString *emailIdentifier = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"input"] objectForKey:kEmail]];
                        loggedInUser.email = emailIdentifier;
                        
                        [weakSelf.scratchContext performBlock:^
                         {
                             NSError *saveError = nil;
                             if (![weakSelf.scratchContext save:&saveError])
                             {
                                 DLog(@"\nlogin user save error %@", saveError);
                             }
                             else
                             {
                                 [self.userDefaults setObject:userID forKey:kUserID];
                                 [self.userDefaults synchronize];
                                 
                                 [[NSNotificationCenter defaultCenter] postNotificationName:MTP_LoginNotification
                                                                                     object:nil
                                                                                   userInfo:@{@"user_id":userID}];

                                 if (successHandler)
                                 {
                                     successHandler(responseObject,loggedInUser);
                                 }
                                 else
                                 {
                                     DLog(@"\nNo success handler");
                                 }
                                 
                                 [weakSelf clearWebCaches];
                             }
                         }];
                    }
                    else
                    {
                        NSLog(@"\nNo user id found %@", [responseObject objectForKey:@"data"]);
                        
                        if (failureHandler)
                        {
                            NSString *errorMessage = @"There was an error logging in. Please contact an administrator";
                            failureHandler([NSError errorWithDomain:[self bundleIdentifier]
                                                               code:10002
                                                           userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"loginFailedUsername", nil),
                                                                      NSLocalizedFailureReasonErrorKey: errorMessage}]);
                        }
                        else
                        {
                            DLog(@"\nNO login failure handler found");
                        }
                    }
                }
            }
        }
    }] resume];
}

- (void)createUser:(NSString *)firstName lastName:(NSString *)lastName email:(NSString *)email attendeeTypeID:(NSNumber *)attendeeTypeID completion:(void(^)(BOOL createdUser, User *attendee, NSDictionary *response,NSError *error))completionHandler
{
    NSString *userCreationEndpoint = [NSString stringWithFormat:@"%@/?first_name=%@&last_name=%@&email=%@&attendeeTypeID=%@",[NSString userCreation],firstName,lastName,email,attendeeTypeID];
    
    NSMutableURLRequest *userCreation = [NSMutableURLRequest mtp_defaultRequestMethod:@"PUT" URL:userCreationEndpoint parameters:nil];
    [[[NSURLSession sharedSession] dataTaskWithRequest:userCreation completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSNumber *userID = nil;
          BOOL createdUser = NO;
          NSDictionary *apiResponse = nil;
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
                  apiResponse = responseObject;
                  
                  BOOL success = [responseObject[@"success"] boolValue];
                  if (success)
                  {
                      createdUser = success;
                      userID = [[responseObject objectForKey:@"data"] objectForKey:kUserID];
                      [self updateAttendee:userID response:responseObject completion:^(id responseObject, User *currentUser) {
                          if (completionHandler)
                          {
                              completionHandler(createdUser,currentUser,responseObject,requestError);
                          }
                      }];
                      return;
                  }
                  else
                  {
                      NSString *failureMessage = [[responseObject[@"errors"] firstObject] objectForKey:@"message"];
                      if (failureMessage.length == 0)
                      {
                          failureMessage = @"The system failed to create your account. Please check your e-mail and try again";
                      }
                      requestError = [NSError errorWithDomain:@"com.MeetingPlay.MPFusionBase.Login" code:1000 userInfo:@{NSLocalizedDescriptionKey: failureMessage}];
                  }
              }
              else
              {
                  requestError = [NSError errorWithDomain:@"com.MeetingPlay.MPFusionBase.Login" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"There was an error contacting the server. Please try again or contact the help desk."}];
              }
          }
          
          if (completionHandler)
          {
              completionHandler(createdUser,nil,apiResponse,requestError);
          }
      }] resume];
}

- (void)updateAttendee:(NSNumber *)userID response:(NSDictionary *)responseObject completion:(void (^)(id responseObject, User *currentUser))completionHandler
{
    User *loggedInUser = [User findUser:userID context:self.scratchContext];
    if (!loggedInUser)
    {
        loggedInUser = [User createInContext:self.scratchContext];
    }
    
    loggedInUser.loggedIn = @(true);
    loggedInUser.user_id = userID;
    NSString *emailIdentifier = [NSString stringWithFormat:@"%@",[[responseObject objectForKey:@"input"] objectForKey:kEmail]];
    loggedInUser.email = emailIdentifier;
    
    __weak typeof(&*self)weakSelf = self;
    [self.scratchContext performBlock:^
     {
         NSError *saveError = nil;
         if (![weakSelf.scratchContext save:&saveError])
         {
             DLog(@"\nlogin user save error %@", saveError);
         }
         else
         {
             [weakSelf.userDefaults setObject:userID forKey:kUserID];
             [weakSelf.userDefaults synchronize];
             
             [[NSNotificationCenter defaultCenter] postNotificationName:MTP_LoginNotification
                                                                 object:nil
                                                               userInfo:@{@"user_id":userID}];
             
             
             if (completionHandler)
             {
                 completionHandler(responseObject,loggedInUser);
             }
             else
             {
                 DLog(@"\nNo success handler");
             }
             
             [weakSelf clearWebCaches];
         }
     }];
}

- (NSError *)validate:(NSString *)username password:(NSString *)password
{
    NSMutableDictionary *errorDictionary =
    [NSMutableDictionary dictionaryWithDictionary:@{NSLocalizedDescriptionKey: @"Login Attempt Failed"}];
    
    
    NSDictionary *validationErrorDictionary;
    // validate the username
    if ((validationErrorDictionary = [self validUsername:username])) {
        [errorDictionary addEntriesFromDictionary:validationErrorDictionary];
        return [NSError errorWithDomain:[self bundleIdentifier]
                                   code:10001
                               userInfo:errorDictionary];;
    }
    
    // validate the password
    if ([[[self.userDefaults objectForKey:MTP_BaseOptions] objectForKey:MTP_LoginPasswordRequired] boolValue]) {
        if ((validationErrorDictionary = [self validPassword:password])) {
            [errorDictionary addEntriesFromDictionary:validationErrorDictionary];
            return [NSError errorWithDomain:[self bundleIdentifier]
                                       code:10001
                                   userInfo:errorDictionary];;
        }
    }
    
    return nil;
}

- (NSDictionary *)validUsername:(NSString *)username
{
    if (username.length == 0) return @{NSLocalizedFailureReasonErrorKey: @"Username was empty"};
    if ([username rangeOfString:@" "].location != NSNotFound) return @{NSLocalizedFailureReasonErrorKey: @"Username contained spaces"};

    return nil;
}

- (NSDictionary *)validPassword:(NSString *)password
{
    if (password.length == 0) return @{NSLocalizedFailureReasonErrorKey: @"Password was empty"};
    if ([password rangeOfString:@" "].location != NSNotFound) return @{NSLocalizedFailureReasonErrorKey: @"Password contained spaces"};
    
    return nil;
}


- (NSString *)bundleIdentifier
{
    return (__bridge_transfer NSString *)CFBundleGetIdentifier(CFBundleGetMainBundle());
}

- (void)clearWebCaches
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie *cookie in cookies)
    {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}
@end
