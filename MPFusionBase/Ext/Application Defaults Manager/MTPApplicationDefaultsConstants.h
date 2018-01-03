//
//  MTPApplicationDefaultsConstants.h
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 4/28/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CGGeometry.h>

@interface MTPApplicationDefaultsConstants : NSObject

#pragma mark App Level Settings
extern NSString *const MTP_GIMBAL_API_KEY;
extern NSString *const MTP_ONESIGNAL_APP_ID;

extern BOOL const MTP_ATTENDEES_NEAR_ME_ENABLED;
extern BOOL const MTP_FIVE_STAR_MATCHES_ENABLED;
extern BOOL const MTP_SPONSOR_MATCHES_ENABLED;

#pragma mark Login Section
extern BOOL const MTP_SSO_ENABLED;

#pragma mark Quick Links Section
extern CGFloat const MTP_QUICKLINKS_BELLY_HEIGHT;
extern BOOL const MTP_QUICKLINKSCELL_SHOWBORDER;

#pragma mark Main Menu Section
extern BOOL const MTP_MAINMENUHEADER_SHOW_SEARCH_CLEAR_BACKGROUND;
extern BOOL const MTP_MAINMENUHEADER_DARK_SEARCH_BACKGROUND;

extern CGFloat const MTP_MAINMENUHEADER_DIVIDER_HEIGHT;

@end
