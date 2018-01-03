//
//  MTPMenuItem.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/9/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPMenuItem.h"

@implementation MTPMenuItem

- (instancetype)init
{
    if (self = [super init])
    {
        _contentType = MTPContentTypeWebView;
    }
    
    return self;
}

+ (instancetype)createMenuItems:(NSDictionary *)itemDictionary
{
    MTPMenuItem *menuItem = [MTPMenuItem new];
    
    menuItem.title = [NSString stringWithFormat:@"%@",itemDictionary[@"title"]];
    menuItem.icon = [NSString stringWithFormat:@"%@",itemDictionary[@"icon"]];
    menuItem.webviewURL = [NSString stringWithFormat:@"%@",itemDictionary[@"webviewURL"]];
    menuItem.contentType = [self contentTypeForIdentifier:[NSString stringWithFormat:@"%@",itemDictionary[@"contentType"]]];
    menuItem.fontAwesome = [NSString stringWithFormat:@"%@",itemDictionary[@"fontAwesome"]];

    return menuItem;
}

+ (MTPContentType)contentTypeForIdentifier:(NSString *)identifier
{
    MTPContentType contentType = MTPContentTypeWebView;
    
    if ([identifier isEqualToString:@"MTPContentTypeHome"])
    {
        contentType = MTPContentTypeHome;
    }
    else if ([identifier isEqualToString:@"MTPContentTypeWebViewLegacy"])
    {
        contentType = MTPContentTypeWebViewLegacy;
    }
    else if ([identifier isEqualToString:@"MTPContentTypeAgenda"])
    {
        contentType = MTPContentTypeAgenda;
    }
    else if ([identifier isEqualToString:@"MTPContentTypeQRReader"])
    {
        contentType = MTPContentTypeQRReader;
    }
    else if ([identifier isEqualToString:@"MTPContentTypePhotoUpload"])
    {
        contentType = MTPContentTypePhotoUpload;
    }
    else if ([identifier isEqualToString:@"MTPContentTypeAttendees"])
    {
        contentType = MTPContentTypeAttendees;
    }
    else if ([identifier isEqualToString:@"MTPContentTypePassKit"])
    {
        contentType = MTPContentTypePassKit;
    }
    else if ([identifier isEqualToString:@"MTPContentTypeSpeakers"])
    {
        contentType = MTPContentTypeSpeakers;
    }
    else if ([identifier isEqualToString:@"MTPContentTypeGeneralInfo"])
    {
        contentType = MTPContentTypeGeneralInfo;
    }
    else if ([identifier isEqualToString:@"MTPContentTypeLogout"])
    {
        contentType = MTPContentTypeLogout;
    }
    else
    {
        contentType = MTPContentTypeWebView;
    }
    
    return contentType;
}

@end
