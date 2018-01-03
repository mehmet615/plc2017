//
//  MTPSpeakerCoordinator.m
//
//  Created by MeetingPlay on 8/16/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPSpeakerCoordinator.h"
#import "MTPSpeaker.h"

#import "NSMutableURLRequest+MTPHelper.h"
#import "NSString+MTPAPIAddresses.h"

#import "NSObject+MTPModelValidation.h"
#import "MTPDLogDefine.h"

@interface MTPSpeakerCoordinator ()
@property (strong, nonatomic, readwrite) NSArray *speakers;
@end

@implementation MTPSpeakerCoordinator

NSString *const MTPL_SpeakersLastFetch = @"MTPL_SpeakersLastFetch";

- (instancetype)init
{
    if (self = [super init])
    {
        _speakers = [NSKeyedUnarchiver unarchiveObjectWithFile:[MTPSpeakerCoordinator archivePath].path];
    }
    return self;
}

- (void)fetchSpeakers:(BOOL)forceFetch completion:(void (^)(NSArray *, NSError *))completionHandler
{
    NSDate *lastFetch = [[NSUserDefaults standardUserDefaults] objectForKey:MTPL_SpeakersLastFetch];
    if (forceFetch || lastFetch.timeIntervalSinceNow > 24 * 60 * 60 || self.speakers.count == 0)
    {
        NSMutableURLRequest *request = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:[NSString mtp_speakers] parameters:nil];
        
        __weak typeof(&*self)weakSelf = self;
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
        {
            NSError *requestError = nil;
            NSArray *speakers = nil;
            
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
                        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:MTPL_SpeakersLastFetch];
                        NSMutableArray *speakersTemp = [NSMutableArray new];
                        
                        NSArray *speakersData = responseObject[@"data"];
                        for (NSDictionary *speakerData in speakersData)
                        {
                            NSNumber *speakerID = speakerData[@"speakerID"];
                            MTPSpeaker *speaker = [weakSelf speakerWithID:speakerID];
                            if (speaker == nil)
                            {
                                speaker = [MTPSpeaker new];
                            }
                            [speaker updateWithData:speakerData];
                            [speakersTemp addObject:speaker];
                        }
                        
                        speakers = [speakersTemp copy];
                        
                        BOOL saved = [weakSelf archiveSpeakers:speakers];
                        if (!saved)
                        {
                            DLog(@"\nfailed to archive speakers");
                        }
                        
                        NSString *speakersProfileURL = responseObject[@"profile_url"];
                        if (speakersProfileURL.length)
                        {
                            [[NSUserDefaults standardUserDefaults] setObject:speakersProfileURL forKey:@"MTPL_SpeakersProfileURL"];
                        }
                        
                        weakSelf.speakers = speakers;
                    }
                    else
                    {
                        if (errorMessage.length == 0)
                        {
                            errorMessage = @"There was a problem fetching the speakers";
                        }
                        requestError = [NSError errorWithDomain:@"com.MeetinPlay.SpeakersFetch" code:10001 userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
                    }
                }
                else
                {
                    if (errorMessage.length == 0)
                    {
                        errorMessage = @"There was a problem fetching the speakers";
                    }
                    requestError = [NSError errorWithDomain:@"com.MeetinPlay.SpeakersFetch" code:10001 userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
                }
            }
            
            if (completionHandler)
            {
                completionHandler(speakers,requestError);
            }
        }] resume];
    }
    else
    {
        if (completionHandler)
        {
            completionHandler(self.speakers,nil);
        }
    }
}

- (void)fetchSpeakerWithSpeakerId:(NSNumber *)speakerId completion:(void (^)(NSArray<MTPSession *> * , NSError *))completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:[NSString mtp_speaker:speakerId] parameters:nil];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSError *requestError = nil;
          NSMutableArray *sessionArray = [[NSMutableArray alloc] init];
          
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
                      NSArray *sessionDatas = responseObject[@"sessionData"];
                      
                      for (NSDictionary *sessionData in sessionDatas)
                      {
                          MTPSession *session = [MTPSession new];
                          [session fillValuesFromResponseObject:sessionData];
                          [sessionArray addObject:session];
                      }
                  }
                  else
                  {
                      if (errorMessage.length == 0)
                      {
                          errorMessage = @"There was a problem fetching the speakers";
                      }
                      requestError = [NSError errorWithDomain:@"com.MeetinPlay.SpeakersFetch" code:10001 userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
                  }
              }
              else
              {
                  if (errorMessage.length == 0)
                  {
                      errorMessage = @"There was a problem fetching the speakers";
                  }
                  requestError = [NSError errorWithDomain:@"com.MeetinPlay.SpeakersFetch" code:10001 userInfo:@{NSLocalizedDescriptionKey:errorMessage}];
              }
          }
          
          if (completionHandler)
          {
              completionHandler(sessionArray,requestError);
          }
          
      }] resume];
}

- (MTPSpeaker *)speakerWithID:(NSNumber *)speakerID
{
    MTPSpeaker *matchingSpeaker = nil;
    
    NSArray *speakers = [NSArray arrayWithArray:self.speakers];
    for (MTPSpeaker *speaker in speakers)
    {
        if ([speakerID isEqual:speaker.speakerID])
        {
            matchingSpeaker = speaker;
            break;
        }
    }
    
    return matchingSpeaker;
}

- (MTPSpeaker *)speakerWithFirstName:(NSString *)speakerFirstName
{
    MTPSpeaker *matchingSpeaker = nil;
    
    NSArray *speakers = [NSArray arrayWithArray:self.speakers];
    for (MTPSpeaker *speaker in speakers)
    {
        if ([speakerFirstName.lowercaseString isEqual:speaker.firstname.lowercaseString])
        {
            matchingSpeaker = speaker;
            break;
        }
    }
    
    return matchingSpeaker;
}

- (MTPSpeaker *)speakerWithLastName:(NSString *)speakerLastName
{
    MTPSpeaker *matchingSpeaker = nil;
    
    NSArray *speakers = [NSArray arrayWithArray:self.speakers];
    for (MTPSpeaker *speaker in speakers)
    {
        if ([speakerLastName.lowercaseString isEqual:speaker.lastname.lowercaseString])
        {
            matchingSpeaker = speaker;
            break;
        }
    }
    
    return matchingSpeaker;
}

- (BOOL)archiveSpeakers:(NSArray *)speakers
{
    NSURL *savePath = [MTPSpeakerCoordinator archivePath];
    BOOL saved = [NSKeyedArchiver archiveRootObject:speakers toFile:savePath.path];
    return saved;
}

+ (NSURL *)archivePath
{
    NSURL *speakersSavePath = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
    speakersSavePath = [speakersSavePath URLByAppendingPathComponent:[self speakersFilename]];
    return speakersSavePath;
}

+ (NSString *)speakersFilename
{
    return @"speakers.data";
}
@end
