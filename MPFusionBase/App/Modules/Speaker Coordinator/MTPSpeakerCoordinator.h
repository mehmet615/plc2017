//
//  MTPSpeakerCoordinator.h
//
//  Created by MeetingPlay on 8/16/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTPSpeaker, MTPSession;

@interface MTPSpeakerCoordinator : NSObject

/*
 *  List of speakers sorted by speakerSortOrder
 */
@property (strong, nonatomic, readonly) NSArray *speakers;

- (void)fetchSpeakers:(BOOL)forceFetch completion:(void(^)(NSArray *speakers,NSError *error))completionHandler;
- (void)fetchSpeakerWithSpeakerId:(NSNumber *)speakerId completion:(void (^)(NSArray<MTPSession *> * , NSError *))completionHandler;

- (MTPSpeaker *)speakerWithID:(NSNumber *)speakerID;
- (MTPSpeaker *)speakerWithFirstName:(NSString *)speakerFirstName;
- (MTPSpeaker *)speakerWithLastName:(NSString *)speakerLastName;

- (BOOL)archiveSpeakers:(NSArray *)speakers;
+ (NSURL *)archivePath;
+ (NSString *)speakersFilename;
@end
