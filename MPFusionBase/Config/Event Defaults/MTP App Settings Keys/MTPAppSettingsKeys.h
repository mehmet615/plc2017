//
//  MTPAppSettingsKeys.h
//  RS West Coast 2015
//
//  Created by Michael Thongvanh on 7/24/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTPAppSettingsKeys : NSObject

#pragma mark - Base Options
extern NSString *const MTP_BaseOptions;
extern NSString *const MTP_AppTintColor;
extern NSString *const MTP_NamePreference;
extern NSString *const MTP_LoginPasswordRequired;
extern NSString *const MTP_EventConnectionGame;
extern NSString *const MTP_LoginPINRequired;
extern NSString *const MTP_MapCenterX;
extern NSString *const MTP_MapCenterY;
extern NSString *const MTP_QREnabled;
extern NSString *const MTP_APNSDeviceToken;
extern NSString *const MTP_ViewControllerConfigurationData;

#pragma mark - iBeacon Options
extern NSString *const MTP_BeaconOptions;
extern NSString *const MTP_GimbalAPIKey;
extern NSString *const MTP_RelevantBeaconCount;
extern NSString *const MTP_DefaultNilRSSI;

#pragma mark - Network Options
extern NSString *const MTP_NetworkOptions;
extern NSString *const MTP_EventBaseHTTPURL;
extern NSString *const MTP_EventBaseAPIURL;
extern NSString *const MTP_URLRequestDefaultTimeoutInterval;
extern NSString *const MTP_XAuthToken;
extern NSString *const MTP_ParseApplicationID;
extern NSString *const MTP_ParseClientKey;

#pragma mark - Quick Links Apperance Options
extern NSString *const MTP_QuickLinksItems;
extern NSString *const MTP_QuickLinksAppearanceOptions;

extern NSString *const MTP_QuickLinkIconColor;
extern NSString *const MTP_QuickLinkTextColor;
extern NSString *const MTP_QuickLinkCircleColor;
extern NSString *const MTP_QuickLinksBackgroundColor;

extern NSString *const MTP_QuickLinksAppearanceBackgroundImage;
extern NSString *const MTP_QuickLinksAppearanceHeroHeader;

#pragma mark - Main Menu Appearance Options
extern NSString *const MTP_MainMenuItems;
extern NSString *const MTP_MainMenuOptions;
extern NSString *const MTP_MainMenuBackgroundColor;

extern NSString *const MTP_MainMenuFontDescription;
extern NSString *const MTP_MainMenuDefaultFontName;
extern NSString *const MTP_MainMenuDefaultFontSize;
extern NSString *const MTP_MainMenuDefaultFontColor;

extern NSString *const MTP_MainMenuDefaultIconFontSize;

#pragma mark Main Menu Header
extern NSString *const MTP_MainMenuHeader;
extern NSString *const MTP_MainMenuHeaderImage;
extern NSString *const MTP_MainMenuHeaderBackgroundColor;
extern NSString *const MTP_MainMenuHeaderFontName;
extern NSString *const MTP_MainMenuHeaderFontSize;
extern NSString *const MTP_MainMenuHeaderFontDefaultSize;
extern NSString *const MTP_MainMenuHeaderFontColor;
extern NSString *const MTP_MainMenuHeaderSubtitleFontName;
extern NSString *const MTP_MainMenuHeaderSubtitleFontSize;

extern NSString *const MTP_RoundedProfileButton;
extern NSString *const MTP_EditProfileButtonColor;
extern NSString *const MTP_EditProfileButtonTextColor;
extern NSString *const MTP_EditProfileButtonIconColor;
extern NSString *const MTP_EditProfileBorderColor;

#pragma mark Main Menu Body
extern NSString *const MTP_MainMenuFontName;
extern NSString *const MTP_MainMenuFontSize;
extern NSString *const MTP_MainMenuFontColor;
extern NSString *const MTP_MainMenuIconColor;
extern NSString *const MTP_MainMenuIconSize;
extern NSString *const MTP_MainMenuTextShadowAlpha;

#pragma mark Main Menu Section Dividers
extern NSString *const MTP_MainMenuSectionFontDescription;
extern NSString *const MTP_MainMenuSectionFontName;
extern NSString *const MTP_MainMenuSectionFontSize;
extern NSString *const MTP_MainMenuSectionFontColor;
extern NSString *const MTP_MainMenuSectionBackgroundColor;
extern NSString *const MTP_MainMenuSectionShowBackgroundGradient;
extern NSString *const MTP_MainMenuSectionShowBackgroundImage;

extern NSString *const MTP_MainMenuSectionDefaultFontSize;
extern NSString *const MTP_MainMenuSectionDefaultFontName;
extern NSString *const MTP_MainMenuSectionDefaultFontColor;
extern NSString *const MTP_MainMenuSectionTextShadowAlpha;

#pragma mark Main Menu Footer
extern NSString *const MTP_MainMenuFooter;
extern NSString *const MTP_MainMenuFooterTextColor;
extern NSString *const MTP_MainMenuFooterLogoColor;

#pragma mark - Login Screen Options
extern NSString *const MTP_LoginScreenOptions;
extern NSString *const MTP_LoginButtonBackgroundColor;
extern NSString *const MTP_LoginButtonTextColor;
extern NSString *const MTP_LoginButtonBorderColor;
extern NSString *const MTP_AcceptTermsCheckmarkColor;

#pragma mark - new
extern NSString *const MTP_CustomFonts;
extern NSString *const MTP_NavigationBarFont;
extern NSString *const MTP_SessionItem;
extern NSString *const MTP_PollItem;
extern NSString *const MTP_ProfileEditing;
extern NSString *const MTP_QRCode;
extern NSString *const MTP_PhotoUpload;

#pragma mark - Menu Item Additional Data
extern NSString *const MTP_MenuItemAdditionalDataPageTitle;
extern NSString *const MTP_MenuItemAdditionalDataContentType;
extern NSString *const MTP_MenuItemAdditionalDataPageHeaderText;
extern NSString *const MTP_MenuItemAdditionalDataPageSubtitleDescriptionText;
extern NSString *const MTP_MenuItemAdditionalDataPageHeaderBackgroundImage;
extern NSString *const MTP_MenuItemAdditionalDataPageContentBackgroundImage;
extern NSString *const MTP_MenuItemAdditionalDataWebviewBaseURL;
extern NSString *const MTP_MenuItemAdditionalDataAdditionalData;

#pragma mark - Remote Navigation Updates
extern NSString *const MTP_NavigationMenuDidUpdate;
#pragma mark Conference Remote Menu Details
extern NSString *const MTP_ConferenceMenuDetails;
extern NSString *const MTP_ConferenceMenuRemoteFolder;
extern NSString *const MTP_ConferenceMenuRemoteFilename;


#pragma mark - Main Appearance
extern NSString *const MTP_MainApperance;
extern NSString *const MTP_NavigationBarColor;
extern NSString *const MTP_NavigationBarButtonColor;

#pragma mark - Theme Options
extern NSString *const MPFUSION_eventInformation;
extern NSString *const MPFUSION_eventName;
extern NSString *const MPFUSION_eventLocation;
extern NSString *const MPFUSION_eventDate;
extern NSString *const MPFUSION_eventQREnabled;

extern NSString *const MPFUSION_sideBar;
extern NSString *const MPFUSION_sideBarImage;
extern NSString *const MPFUSION_sideBarDividerTitle;

extern NSString *const MPFUSION_colors;
extern NSString *const MPFUSION_color1;
extern NSString *const MPFUSION_color2;
extern NSString *const MPFUSION_color3;
extern NSString *const MPFUSION_color4;
extern NSString *const MPFUSION_color5;
extern NSString *const MPFUSION_color6;
extern NSString *const MPFUSION_color7;
extern NSString *const MPFUSION_color8;
extern NSString *const MPFUSION_color9;
extern NSString *const MPFUSION_color10;
extern NSString *const MPFUSION_color11;
extern NSString *const MPFUSION_color12;
extern NSString *const MPFUSION_color13;
extern NSString *const MPFUSION_color14;
extern NSString *const MPFUSION_color15;
extern NSString *const MPFUSION_color16;
extern NSString *const MPFUSION_color17;
extern NSString *const MPFUSION_color18;
extern NSString *const MPFUSION_color19;
extern NSString *const MPFUSION_color20;
extern NSString *const MPFUSION_color21;
extern NSString *const MPFUSION_color22;
extern NSString *const MPFUSION_color23;
extern NSString *const MPFUSION_color24;
extern NSString *const MPFUSION_color25;
extern NSString *const MPFUSION_color26;
extern NSString *const MPFUSION_color27;
extern NSString *const MPFUSION_color28;
extern NSString *const MPFUSION_color29;
extern NSString *const MPFUSION_color30;

extern NSString *const MPFUSION_homePageAppearance;
extern NSString *const MPFUSION_homePageMenuDisplayStyle;
extern NSString *const MPFUSION_homePageBackgroundTexture;
extern NSString *const MPFUSION_homePageBackgroundImage;
extern NSString *const MPFUSION_homePageFeaturedImage;
extern NSString *const MPFUSION_homePageBellyImage;

@end
