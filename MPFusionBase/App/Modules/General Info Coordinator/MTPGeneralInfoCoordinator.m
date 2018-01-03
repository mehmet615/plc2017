//
//  MTPGeneralInfoCoordinator.m
//  MPFusionBaseProject
//
//  Created by Admin on 8/19/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPGeneralInfoCoordinator.h"
#import "MTPGeneralInformation.h"
#import "MTPAssetData.h"

#import "NSMutableURLRequest+MTPHelper.h"
#import "NSString+MTPAPIAddresses.h"

#import "MTPDLogDefine.h"

NSString *const MTPL_GeneralInfoLastFetch = @"MTPL_GeneralInfoLastFetch";

@interface MTPGeneralInfoCoordinator()

@property (strong, nonatomic, readwrite) NSArray *generalInfos;

@end

@implementation MTPGeneralInfoCoordinator

- (void)fetchGeneralInfo:(BOOL)forceFetch completion:(void(^)(NSArray *generalInfos, NSError *error))completionHandler {
    
    NSDate *lastFetch = [[NSUserDefaults standardUserDefaults] objectForKey:MTPL_GeneralInfoLastFetch];
    if (forceFetch || lastFetch.timeIntervalSinceNow > 24 * 60 * 60 || self.generalInfos.count == 0)
    {
        NSMutableURLRequest *request = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:[NSString mtp_generalInfos] parameters:nil];

        __weak typeof(&*self)weakSelf = self;
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
          {
              
              NSError *requestError = nil;
              NSArray *generalInfos = nil;
              
              if (error)
              {
                  DLog(@"\nerror %@",error);
                  requestError = error;
              }
              else
              {
                  NSString *errorMessage = nil;
                  id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&requestError];
                  if ([responseObject isKindOfClass:[NSDictionary class]])
                  {
                      BOOL success = [responseObject[@"success"] boolValue];
                      errorMessage = responseObject[@"message"];
                      
                      if (success)
                      {
                          [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:MTPL_GeneralInfoLastFetch];
                          NSMutableArray *generalInfoTemp = [NSMutableArray new];
                          
                          NSArray *generalInfoDatas = responseObject[@"data"];
                          for (NSDictionary *genderalInfoData in generalInfoDatas) {
                              NSNumber *generalInfoID = genderalInfoData[@"contentID"];
                              MTPGeneralInformation *generalInfo = [weakSelf generalInfoWithID:generalInfoID];
                              if (generalInfo == nil)
                              {
                                  generalInfo = [MTPGeneralInformation new];
                              }
                              
                              [generalInfo updateWithData:genderalInfoData];
                              [generalInfoTemp addObject:generalInfo];
                          }
                          
                          generalInfos = [generalInfoTemp copy];
                          
                          BOOL saved = [weakSelf archiveGeneralInfos:generalInfos];
                          if (!saved)
                          {
                              DLog(@"\nfailed to archive GeneralInfos");
                          }
                          
                          NSString *generalInfosImageURL = responseObject[@"image_url"];
                          if (generalInfosImageURL.length)
                          {
                              [[NSUserDefaults standardUserDefaults] setObject:generalInfosImageURL forKey:@"MTPL_GeneralInfosPhotoURL"];
                          }
                          
                          weakSelf.generalInfos = generalInfos;
                      }
                      else
                      {
                          if (errorMessage.length == 0)
                          {
                              errorMessage = @"There was a problem fetching the general inforamtion.";
                          }
                          requestError = [NSError errorWithDomain:@"com.MeetinPlay.GeneralInformationFetch" code:10001 userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
                      }
                  }
                  else
                  {
                      if (errorMessage.length == 0)
                      {
                          errorMessage = @"There was a problem fetching the general inforamtion.";
                      }
                      requestError = [NSError errorWithDomain:@"com.MeetinPlay.GeneralInformationsFetch" code:10001 userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
                  }
              }
              
              if (completionHandler)
              {
                  completionHandler(generalInfos,requestError);
              }
          }] resume];
    }
    else
    {
        if (completionHandler)
        {
            completionHandler(self.generalInfos,nil);
        }
    }
}

- (void)fetchGeneralInfoWithId:(NSNumber *)generalInfoId completion:(void(^)(NSArray <MTPAssetData *> *files, NSError *error))completionHandler {
    
    NSMutableURLRequest *request = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:[NSString mtp_generalInfos:generalInfoId] parameters:nil];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          BOOL success = NO;
          NSError *requestError = nil;
          NSMutableArray <MTPAssetData *> *files = nil;
          
          if (error)
          {
              DLog(@"\nerror %@",error);
              requestError = error;
          }
          else
          {
              NSString *errorMessage = nil;
              id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&requestError];
              if ([responseObject isKindOfClass:[NSDictionary class]])
              {
                  success = [responseObject[@"success"] boolValue];
                  errorMessage = responseObject[@"message"];
                  
                  if (success)
                  {
                      NSDictionary *infoDictionary = responseObject[@"info"];
                      NSString *generalInfosImageURL = infoDictionary[@"photo_url"];
                      if (generalInfosImageURL.length)
                      {
                          [[NSUserDefaults standardUserDefaults] setObject:generalInfosImageURL forKey:@"MTPL_GeneralInfoPhotoURL"];
                      }
                      
                      NSString *generalInfosAssetURL = infoDictionary[@"asset_url"];
                      if (generalInfosAssetURL.length) {
                          [[NSUserDefaults standardUserDefaults] setObject:generalInfosAssetURL forKey:@"MTPL_GeneralInfoAssetURL"];
                      }
                      
                      files = [[NSMutableArray alloc] init];
                      
                      NSArray<NSDictionary *> *assetsDatas = responseObject[@"assetData"];
                      for (NSDictionary *asset in assetsDatas) {
                          MTPAssetData *assetData = [MTPAssetData new];
                          [assetData updateWithData:asset];
                          [files addObject:assetData];
                      }
                      
                  }
                  else
                  {
                      if (errorMessage.length == 0)
                      {
                          errorMessage = @"There was a problem fetching the general inforamtion.";
                      }
                      requestError = [NSError errorWithDomain:@"com.MeetinPlay.GeneralInformationFetch" code:10001 userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
                  }
              }
              else
              {
                  if (errorMessage.length == 0)
                  {
                      errorMessage = @"There was a problem fetching the general inforamtion.";
                  }
                  requestError = [NSError errorWithDomain:@"com.MeetinPlay.GeneralInformationsFetch" code:10001 userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
              }
          }
          
          if (completionHandler)
          {
              completionHandler(files,requestError);
          }
      }] resume];
}



- (MTPGeneralInformation *)generalInfoWithID:(NSNumber *)generalInfoID
{
    MTPGeneralInformation *matchingGeneralInfo = nil;
    
    NSArray *generalInfos = [NSArray arrayWithArray:self.generalInfos];
    for (MTPGeneralInformation *generalInfo in generalInfos)
    {
        if ([generalInfoID isEqual:generalInfo.contentID])
        {
            matchingGeneralInfo = generalInfo;
            break;
        }
    }
    
    return matchingGeneralInfo;
}

- (BOOL)archiveGeneralInfos:(NSArray *)generalInfos
{
    NSURL *savePath = [MTPGeneralInfoCoordinator archivePath];
    BOOL saved = [NSKeyedArchiver archiveRootObject:generalInfos toFile:savePath.path];
    return saved;
}

+ (NSURL *)archivePath
{
    NSURL *generalInfosSavePath = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    generalInfosSavePath = [generalInfosSavePath URLByAppendingPathComponent:[self generalInfosFilename]];
    return generalInfosSavePath;
}

+ (NSString *)generalInfosFilename
{
    return @"generalInfos.data";
}

@end
