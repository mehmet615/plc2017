//
//  NSString+MTPWebViewURL.h
//  MarriottTPC
//
//  Created by Michael Thongvanh on 5/13/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MTPWebViewURL)

+ (NSString *)websiteBaseURL;

+ (NSString *)websiteLoginURL;
+ (NSString *)ssoURL;
+ (NSString *)agendaURL;
+ (NSString *)sessionDetailsURL;
+ (NSString *)pollWithIDURL;

+ (NSString *)sponsorsURL;
+ (NSString *)gameConnectionURL;

+ (NSString *)photoGalleryURL;
+ (NSString *)conversationWallURL;

+ (NSString *)editProfile;
+ (NSString *)searchResults;

+ (NSString *)pulseProfile:(NSNumber *)userID;
+ (NSString *)pulseFeedWebView;
+ (NSString *)mediaPostComment;

+ (NSString *)sharedInterests:(NSNumber *)attendeeID;
+ (NSString *)attendeeProfile:(NSNumber *)attendeeID;
+ (NSString *)chat:(NSNumber *)attendeeID;

@end
