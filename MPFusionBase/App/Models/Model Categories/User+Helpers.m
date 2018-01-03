//
//  User+Helpers.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/7/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "User+Helpers.h"
#import "EventKeys.h"
#import <UIKit/UIKit.h> 
#import "NSObject+EventDefaultsHelpers.h"
//#import "MTPAPIAddresses.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSURLSession+MTPCategory.h"
#import "NSObject+MTPModelValidation.h"

@implementation User (Helpers)

+ (User *)findUser:(NSNumber *)userID context:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchUser = [User fetchRequest:[NSPredicate predicateWithFormat:@"%K = %@",@"user_id",userID]
                                             limit:1];

    __block User *fetchResult;
    __block NSError *fetchError = nil;
    
    [managedObjectContext performBlockAndWait:
     ^{
        NSArray *results = [managedObjectContext executeFetchRequest:fetchUser error:&fetchError];
        fetchResult = [results firstObject];
        
        if (fetchError) {
            NSLog(@"%s [%s]: Line %i]\n"
                  "Error fetching user by ID: %@",
                  __FILE__,__PRETTY_FUNCTION__,__LINE__,
                  fetchError);
        }
    }];
    
    return fetchResult;
}

+ (NSArray *)findUsers:(NSArray *)userIDs context:(NSManagedObjectContext *)managedObjectContext
{
    NSPredicate *userIDSearchPredicate = [NSPredicate predicateWithFormat:@"user_id IN $userIDs"];

    NSFetchRequest *fetchUsersByID = [User fetchRequest:[userIDSearchPredicate
                                                         predicateWithSubstitutionVariables:@{@"userIDs": userIDs}]
                                                  limit:0];
    
    __block NSArray *fetchResults;
    __block NSError *fetchError = nil;
    
    [managedObjectContext performBlockAndWait:
     ^{
        fetchResults = [managedObjectContext executeFetchRequest:fetchUsersByID error:&fetchError];
        if (fetchError)
        {
            NSLog(@"%s [%s]: Line %i]\n"
                  "Error fetching user by ID: %@",
                  __FILE__,__PRETTY_FUNCTION__,__LINE__,
                  fetchError);
        }
    }];
    return fetchResults;
}

+ (NSArray *)allUsersInContext:(NSManagedObjectContext *)managedObjectContext
{
    NSFetchRequest *fetchUsers = [User fetchRequest:nil limit:0];
    
    __block NSArray *fetchResults;
    __block NSError *fetchError = nil;
    
    [managedObjectContext performBlockAndWait:^{
        fetchResults = [managedObjectContext executeFetchRequest:fetchUsers error:&fetchError];
        
        if (fetchError) {
            NSLog(@"%s [%s]: Line %i]\n"
                  "Error fetching user by ID: %@",
                  __FILE__,__PRETTY_FUNCTION__,__LINE__,
                  fetchError);
        }
    }];
    
    return fetchResults;
}

+ (User *)createInContext:(NSManagedObjectContext *)managedObjectContext
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([User class])
                                         inManagedObjectContext:managedObjectContext];
}

+ (NSArray *)allUserIDsInContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[@"user_id"]];
    
    // Execute the fetch.
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        // Handle the error.
        DLog(@"\ndebugging message %@",error);
    }
    
    return objects;
}

+ (NSArray *)createUsers:(NSArray *)jsonData context:(NSManagedObjectContext *)managedObjectContext
{
    NSMutableSet *userIDCollection = [NSMutableSet new];
    NSArray *existingUserIDs = [self allUserIDsInContext:managedObjectContext];
    for (NSDictionary *userIDInfo in existingUserIDs)
    {
        NSNumber *userID = userIDInfo[@"user_id"];
        [userIDCollection addObject:userID];
    }
    
    __block NSMutableArray *usersCreatedFromJsonData = [NSMutableArray new];
    
    NSFetchRequest *allUsersRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([User class])];
    [allUsersRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"user_id" ascending:true]]];
    
    NSError *fetchError = nil;
    NSArray *existingUsers = [managedObjectContext executeFetchRequest:allUsersRequest error:&fetchError];
    if (fetchError)
    {
        DLog(@"\nfetch error %@", fetchError);
    }
    
    [jsonData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        __block User *user;
        
        NSUInteger objUserID = [obj[@"user_id"] integerValue];
        
        for (User *existingUser in existingUsers)
        {
            if ([existingUser user_id].integerValue == objUserID)
            {
                user = existingUser;
                break;
            }
        }
        
        if (!user)
        {
            user = [self createInContext:managedObjectContext];
        }
        
        [user updateUser:obj];
        
        [usersCreatedFromJsonData addObject:user];
        
        [userIDCollection removeObject:obj];
    }];
    
    BOOL deleteUsersEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"MTPDeleteUsersEnabled"];
    if (deleteUsersEnabled)
    {
        [self deleteUsers:[userIDCollection allObjects] context:managedObjectContext];
    }
    
    [managedObjectContext unlock];
    
    return usersCreatedFromJsonData;
}

- (void)updateUser:(NSDictionary*)jsonData
{
    // required values
    self.email = [[jsonData objectForKey:kEmail] mtp_stringValue];
    self.first_name = [[jsonData objectForKey:kFirstName] mtp_stringValue];
    self.last_name = [[jsonData objectForKey:kLastName] mtp_stringValue];
    self.region = [[jsonData objectForKey:kRegion] mtp_stringValue];
    self.jobtitle = [[jsonData objectForKey:kTitle] mtp_stringValue];
    self.user_id = [[jsonData objectForKey:kUserID] mtp_numberValue];
    self.user_type = [[jsonData objectForKey:kUserType] mtp_stringValue];
    
    // optional values
    self.address1 = [[jsonData objectForKey:kAddress1] mtp_stringValue];
    self.address2 = [[jsonData objectForKey:kAddress2] mtp_stringValue];
    self.cell = [[jsonData objectForKey:kCell] mtp_stringValue];
    self.phone = [[jsonData objectForKey:kPhone] mtp_stringValue];
    self.work = [[jsonData objectForKey:kWork] mtp_stringValue];
    
    self.bio = [[jsonData objectForKey:kBio] mtp_stringValue];
    self.city = [[jsonData objectForKey:kCity] mtp_stringValue];
    self.country = [[jsonData objectForKey:kCountry] mtp_stringValue];
    self.photo = [[jsonData objectForKey:kPhoto] mtp_stringValue];
    self.state = [[jsonData objectForKey:kStateProvince] mtp_stringValue];
    
    self.attendeetypeid = [[jsonData objectForKey:@"attendeetypeid"] mtp_numberValue];
    self.beaconid = [[jsonData objectForKey:@"beaconid"] mtp_stringValue];
    
    self.showmylocation = [[jsonData objectForKey:@"showmylocation"] mtp_numberValue];
}

- (void)fetchUpdatedInfo:(void (^)(User *))completionHandler
{
    if (self.user_id)
    {
        NSString *updateCurrentUserURL = [NSString stringWithFormat:@"%@/%@",[NSString userInfo],self.user_id];
        NSMutableURLRequest *updateUserRequest = [NSURLSession defaultRequestMethod:@"GET" URL:updateCurrentUserURL parameters:nil];
        
        __weak __typeof(&*self)weakSelf = self;
        [[[NSURLSession sharedSession] dataTaskWithRequest:updateUserRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
          {
              id responseObject = [NSURLSession serializeJSONData:data response:response error:error];
              if ([responseObject isKindOfClass:[NSDictionary class]])
              {
                  [weakSelf updateUser:[responseObject objectForKey:@"data"]];
                  [weakSelf saveToPersistentStore:weakSelf.managedObjectContext];
                  if (completionHandler) {
                      completionHandler(weakSelf);
                  }
              }
          }] resume];
    }
}

+ (User *)currentUser:(NSManagedObjectContext *)managedObjectContext
{
    __block User *fetchResult;
    __block NSError *fetchError = nil;
    
    if (managedObjectContext)
    {
        NSPredicate *loggedInPredicate = [NSPredicate predicateWithFormat:@"%K = 1",@"loggedIn"];
        
        [managedObjectContext performBlockAndWait:^
         {
             NSArray *results = [managedObjectContext executeFetchRequest:[User fetchRequest:loggedInPredicate
                                                                                       limit:1]
                                                                    error:&fetchError];
             fetchResult = [results firstObject];
             
             if (fetchError) {
                 NSLog(@"%s [%s]: Line %i]\n"
                       "Error fetching user by ID: %@",
                       __FILE__,__PRETTY_FUNCTION__,__LINE__,
                       fetchError);
             }
         }];
    }
    
    return fetchResult;
}

+ (void)deleteUsers:(NSArray *)userIDsForDeletion context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"user_id IN %@",userIDsForDeletion]];
    
    // Execute the fetch.
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        // Handle the error.
        DLog(@"\ndebugging message %@",error);
    }
    
    for (NSManagedObject *user in objects)
    {
        [context deleteObject:user];
    }
}

+ (NSFetchRequest *)fetchRequest:(NSPredicate *)fetchPredicate limit:(NSInteger)fetchLimit
{
    NSFetchRequest *newFetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([User class])];
    [newFetchRequest setPredicate:fetchPredicate];
    if (fetchLimit > 0)
    {
        [newFetchRequest setFetchLimit:fetchLimit];
    }
    
    return newFetchRequest;
}

+ (NSArray *)requiredKeys {
    return @[@"company",
             @"country",
             @"state",
             @"phone",
             @"zip_code",
             @"address2",
             @"first_name",
             @"cell",
             @"address1",
             @"bio",
             @"user_type",
             @"work",
             @"email",
             @"attendee_type",
             @"city",
             @"region",
             @"photo",
             @"user_id",
             @"last_name",
             @"jobtitle",
             @"drawing",
             @"attendeetypeid",
             @"beaconid",
             @"showmylocation"];
}

#pragma mark - Protocol Conformance
- (NSString *)displayMainTitle
{
    NSString *firstname = self.first_name.length > 0 ? self.first_name : @"";
    NSString *lastname = self.last_name.length > 0 ? self.last_name : @"";
    
    return [NSString stringWithFormat:@"%@ %@",firstname,lastname];
}

- (NSString *)displaySubtitle
{
    return self.jobtitle.length > 0 ? self.jobtitle : @"";
}

- (NSURL *)displayImageURL
{
    NSString *photoBaseURL = [self.userDefaults objectForKey:kProfileImageUrl];
    NSString *userProfileImage = self.photo;
    
    if (photoBaseURL.length > 0 && userProfileImage.length > 0)
    {
        photoBaseURL = [photoBaseURL stringByAppendingString:userProfileImage];
        photoBaseURL = [photoBaseURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        return [NSURL URLWithString:photoBaseURL];
    }
    else
    {
        return nil;
    }
}

- (NSNumber *)connectionID
{
    return self.user_id;
}
@end
