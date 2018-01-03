//
//  NSString+MTPWebViewURL.m
//  MarriottTPC
//
//  Created by Michael Thongvanh on 5/13/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "NSString+MTPWebViewURL.h"
#import "MTPAppSettingsKeys.h"

@implementation NSString (MTPWebViewURL)

+ (NSString *)websiteBaseURL
{
    NSString *baseURL = [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL];
    NSAssert(baseURL.length > 0, @"No Base API URL was found. Please enter an address in your EventDefaults.plist");
    return baseURL;
    
//    return @"http://tpc15.meetingplay.com";
}

+ (NSString *)websiteLoginURL
{
    return [NSString stringWithFormat:@"%@/login/",[self websiteBaseURL]];
}

+ (NSString *)ssoURL
{
    return [NSString stringWithFormat:@"%@/sso-redirect/",[self websiteBaseURL]];
}

+ (NSString *)agendaURL
{
    return [NSString stringWithFormat:@"%@/agenda/?",[self websiteBaseURL]];
}

+ (NSString *)sessionDetailsURL
{
    return [NSString stringWithFormat:@"%@/session/%@/?",[self websiteBaseURL],@"%@"];
}

+ (NSString *)pollWithIDURL
{
    return [NSString stringWithFormat:@"%@/qr/5/%@",[self websiteBaseURL],@"%@"];
}

+ (NSString *)sponsorsURL
{
    return [NSString stringWithFormat:@"%@/sponsor-list/?",[self websiteBaseURL]];
}

+ (NSString *)gameConnectionURL
{
    return [NSString stringWithFormat:@"%@/game/%@",[self websiteBaseURL],@"complete-connection.cfm?user_id=%@&connection_user_id=%@"];
}

+ (NSString *)photoGalleryURL
{
    return [NSString stringWithFormat:@"%@/photo-gallery/?",[self websiteBaseURL]];
}

+ (NSString *)conversationWallURL
{
    return [NSString stringWithFormat:@"%@/conversation-wall/?",[self websiteBaseURL]];
}

+ (NSString *)editProfile
{
    return [NSString stringWithFormat:@"%@/edit-profile/?",[self websiteBaseURL]];
}

+ (NSString *)searchResults
{
    return [NSString stringWithFormat:@"%@/search-results/?",[self websiteBaseURL]];
}

+ (NSString *)pulseProfile:(NSNumber *)userID
{
    return [NSString stringWithFormat:@"%@/right-panel-webview/?userID=%@",[self websiteBaseURL],userID];
}

+ (NSString *)pulseFeedWebView
{
    return [NSString stringWithFormat:@"%@/pulse-feed-webview/",[self websiteBaseURL]];
}

+ (NSString *)mediaPostComment
{
    return [NSString stringWithFormat:@"%@/post-comment/",[self websiteBaseURL]];
}

+ (NSString *)sharedInterests:(NSNumber *)attendeeID
{
    return [NSString stringWithFormat:@"%@/shared-interests/%@/",[self websiteBaseURL],attendeeID];
}

+ (NSString *)attendeeProfile:(NSNumber *)attendeeID
{
    return [NSString stringWithFormat:@"%@/profile/%@/",[self websiteBaseURL],attendeeID];
}

+ (NSString *)chat:(NSNumber *)attendeeID
{
    return [NSString stringWithFormat:@"%@/profile/%@/",[self websiteBaseURL],attendeeID];
}

@end
