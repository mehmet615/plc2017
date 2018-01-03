//
//  MTPOneSignalInterface.h
//  MeetingPlay
//
//  Created by MeetingPlay on 12/12/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTPOneSignalInterface : NSObject

+ (void)signUpForNotifications:(NSNumber *)userID attendeeTypeID:(NSNumber *)attendeeTypeID;

@end
