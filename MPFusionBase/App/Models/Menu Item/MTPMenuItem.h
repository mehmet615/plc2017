//
//  MTPMenuItem.h
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/9/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, MTPContentType)
{
    MTPContentTypeHome,
    MTPContentTypeAgenda,
    MTPContentTypeWebView,
    MTPContentTypeWebViewLegacy,
    MTPContentTypeQRReader,
    MTPContentTypePhotoUpload,
    MTPContentTypeAttendees,
    MTPContentTypePassKit,
    MTPContentTypeSpeakers,
    MTPContentTypeGeneralInfo,
    MTPContentTypeLogout,
};

@interface MTPMenuItem : NSObject

@property (nonatomic, strong) NSString *title;
@property (assign, nonatomic) MTPContentType contentType;
@property (nonatomic, strong) NSString *icon;
@property (strong, nonatomic) NSString *webviewURL;
@property (strong, nonatomic) NSString *fontAwesome;

+ (instancetype)createMenuItems:(NSDictionary *)itemDictionary;

@end

