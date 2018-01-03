//
//  MTPAppSettingsKeys.m
//  RS West Coast 2015
//
//  Created by Michael Thongvanh on 7/24/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPAppSettingsKeys.h"

@implementation MTPAppSettingsKeys

#pragma mark - Base Options
NSString *const MTP_BaseOptions                         = @"MTP_BaseOptions";
NSString *const MTP_AppTintColor                        = @"MTP_AppTintColor";
NSString *const MTP_NamePreference                      = @"name_preference";
NSString *const MTP_LoginPasswordRequired               = @"MTP_LoginPasswordRequired";
NSString *const MTP_EventConnectionGame                 = @"MTP_EventConnectionGame";
NSString *const MTP_LoginPINRequired                    = @"MTP_LoginPINRequired";
NSString *const MTP_MapCenterX                          = @"MTP_MapCenterX";
NSString *const MTP_MapCenterY                          = @"MTP_MapCenterY";
NSString *const MTP_QREnabled                           = @"MTP_QREnabled";
NSString *const MTP_APNSDeviceToken                     = @"MTP_APNSDeviceToken";
NSString *const MTP_ViewControllerConfigurationData     = @"MTP_ViewControllerConfigurationData";

#pragma mark - iBeacon Options
NSString *const MTP_BeaconOptions                       = @"MTP_BeaconOptions";
NSString *const MTP_GimbalAPIKey                        = @"MTP_GimbalAPIKey";
NSString *const MTP_RelevantBeaconCount                 = @"relevantBeaconCount";
NSString *const MTP_DefaultNilRSSI                      = @"defaultNilRSSI";

#pragma mark - Network Options
NSString *const MTP_NetworkOptions                      = @"MTP_NetworkOptions";
NSString *const MTP_EventBaseHTTPURL                    = @"MTP_EventBaseHTTPURL";
NSString *const MTP_EventBaseAPIURL                     = @"MTP_EventBaseAPIURL";
NSString *const MTP_URLRequestDefaultTimeoutInterval    = @"MTP_RequestDefaultTimeoutInterval";
NSString *const MTP_XAuthToken                          = @"MTP_XAuthToken";
NSString *const MTP_ParseApplicationID                  = @"MTP_ParseApplicationID";
NSString *const MTP_ParseClientKey                      = @"MTP_ParseClientKey";

#pragma mark - Quick Links Apperance Options
NSString *const MTP_QuickLinksItems                     = @"homePageMenuItems";
NSString *const MTP_QuickLinksAppearanceOptions         = @"MTP_QuickLinksAppearanceOptions";

NSString *const MTP_QuickLinkIconColor                  = @"MTP_QuickLinkIconColor";
NSString *const MTP_QuickLinkTextColor                  = @"MTP_QuickLinkTextColor";
NSString *const MTP_QuickLinkCircleColor                = @"MTP_QuickLinkCircleColor";
NSString *const MTP_QuickLinksBackgroundColor           = @"MTP_QuickLinksBackgroundColor";

NSString *const MTP_QuickLinksAppearanceBackgroundImage = @"MTP_QuickLinksAppearanceBackgroundImage";
NSString *const MTP_QuickLinksAppearanceHeroHeader      = @"MTP_QuickLinksAppearanceHeroHeader";

#pragma mark - Main Menu Appearance Options
NSString *const MTP_MainMenuItems                       = @"sideNavigationItems";
NSString *const MTP_MainMenuOptions                     = @"MTP_MainMenuOptions";
NSString *const MTP_MainMenuBackgroundColor             = @"MTP_MainMenuBackgroundColor";

NSString *const MTP_MainMenuFontDescription             = @"MTP_MainMenuFontDescription";
NSString *const MTP_MainMenuDefaultFontName             = @"defaultFontName";
NSString *const MTP_MainMenuDefaultFontSize             = @"defaultFontSize";
NSString *const MTP_MainMenuDefaultFontColor            = @"defaultFontColor";
NSString *const MTP_MainMenuDefaultIconFontSize         = @"defaultIconFontSize";

#pragma mark Main Menu Header
NSString *const MTP_MainMenuHeader                      = @"MTP_MainMenuHeader";
NSString *const MTP_MainMenuHeaderImage                 = @"image";
NSString *const MTP_MainMenuHeaderBackgroundColor       = @"MTP_HeaderBackgroundColor";
NSString *const MTP_MainMenuHeaderFontName              = @"headerFontName";
NSString *const MTP_MainMenuHeaderFontSize              = @"headerFontSize";
NSString *const MTP_MainMenuHeaderFontDefaultSize       = @"headerFontDefaultSize";
NSString *const MTP_MainMenuHeaderFontColor             = @"MTP_HeaderFontColor";
NSString *const MTP_MainMenuHeaderSubtitleFontName      = @"headerSubtitleFontName";
NSString *const MTP_MainMenuHeaderSubtitleFontSize      = @"headerSubtitleFontSize";

NSString *const MTP_RoundedProfileButton                = @"MTP_RoundedProfileButton";
NSString *const MTP_EditProfileButtonColor              = @"editProfileButtonBackgroundColor";
NSString *const MTP_EditProfileButtonTextColor          = @"editProfileButtonTextColor";
NSString *const MTP_EditProfileButtonIconColor          = @"editProfileButtonIconColor";
NSString *const MTP_EditProfileBorderColor              = @"MTP_EditProfileBorderColor";

#pragma mark Main Menu Body
NSString *const MTP_MainMenuFontName                    = @"fontName";
NSString *const MTP_MainMenuFontSize                    = @"fontSize";
NSString *const MTP_MainMenuFontColor                   = @"fontColor";
NSString *const MTP_MainMenuIconColor                   = @"iconColor";
NSString *const MTP_MainMenuIconSize                    = @"iconFontSize";
NSString *const MTP_MainMenuTextShadowAlpha             = @"fontTextShadowAlpha";

#pragma mark Main Menu Section Dividers
NSString *const MTP_MainMenuSectionFontDescription      = @"MTP_MainMenuSectionFontDescription";
NSString *const MTP_MainMenuSectionFontName             = @"fontName";
NSString *const MTP_MainMenuSectionFontSize             = @"fontSize";
NSString *const MTP_MainMenuSectionFontColor            = @"fontColor";
NSString *const MTP_MainMenuSectionBackgroundColor      = @"sectionBackgroundColor";
NSString *const MTP_MainMenuSectionShowBackgroundGradient  = @"MTP_ShowGradientSectionBackgroundColor";
NSString *const MTP_MainMenuSectionShowBackgroundImage  = @"MTP_ShowSectionBackgroundImage";

NSString *const MTP_MainMenuSectionDefaultFontSize      = @"defaultFontSize";
NSString *const MTP_MainMenuSectionDefaultFontName      = @"defaultFontName";
NSString *const MTP_MainMenuSectionDefaultFontColor 	= @"defaultFontColor";
NSString *const MTP_MainMenuSectionTextShadowAlpha      = @"fontTextShadowAlpha";

#pragma mark Main Menu Footer
NSString *const MTP_MainMenuFooter                      = @"MTP_MainMenuFooter";
NSString *const MTP_MainMenuFooterTextColor             = @"MTP_MainMenuFooterTextColor";
NSString *const MTP_MainMenuFooterLogoColor             = @"MTP_MainMenuFooterLogoColor";

#pragma mark - Login Screen Options
NSString *const MTP_LoginScreenOptions                  = @"MTP_LoginScreenOptions";
NSString *const MTP_LoginButtonBackgroundColor          = @"MTP_LoginButtonBackgroundColor";
NSString *const MTP_LoginButtonTextColor                = @"MTP_LoginButtonTextColor";
NSString *const MTP_LoginButtonBorderColor              = @"MTP_LoginButtonBorderColor";
NSString *const MTP_AcceptTermsCheckmarkColor           = @"MTP_AcceptTermsCheckmarkColor";

#pragma mark - Other
NSString *const MTP_CustomFonts                         = @"MTP_CustomFonts";
NSString *const MTP_NavigationBarFont                   = @"navigationBarFont";
NSString *const MTP_SessionItem                         = @"MTP_SessionItem";
NSString *const MTP_PollItem                            = @"MTP_PollItem";
NSString *const MTP_ProfileEditing                      = @"MTP_ProfileEditing";
NSString *const MTP_QRCode                              = @"MTP_QRCode";
NSString *const MTP_PhotoUpload                         = @"MTP_PhotoUpload";

#pragma mark - Menu Item Additional Data
NSString *const MTP_MenuItemAdditionalDataPageTitle         = @"pageTitle";
NSString *const MTP_MenuItemAdditionalDataContentType       = @"contentType";
NSString *const MTP_MenuItemAdditionalDataPageHeaderText    = @"pageHeaderText";
NSString *const MTP_MenuItemAdditionalDataPageSubtitleDescriptionText = @"pageSubtitleDescriptionText";
NSString *const MTP_MenuItemAdditionalDataPageHeaderBackgroundImage = @"pageHeaderBackgroundImage";
NSString *const MTP_MenuItemAdditionalDataPageContentBackgroundImage = @"pageContentBackgroundImage";
NSString *const MTP_MenuItemAdditionalDataWebviewBaseURL    = @"webviewBaseURL";
NSString *const MTP_MenuItemAdditionalDataAdditionalData    = @"additionalData";

#pragma mark - Remote Navigation Updates
NSString *const MTP_NavigationMenuDidUpdate = @"MTP_NavigationMenuDidUpdate";
#pragma mark Conference Remote Menu Details
NSString *const MTP_ConferenceMenuDetails            = @"MTP_ConferenceMenuDetails";
NSString *const MTP_ConferenceMenuRemoteFolder       = @"MTP_ConferenceMenuRemoteFolder";
NSString *const MTP_ConferenceMenuRemoteFilename     = @"MTP_ConferenceMenuRemoteFilename";

#pragma mark - Main Appearance
NSString *const MTP_MainApperance                       = @"MTP_MainApperance";
NSString *const MTP_NavigationBarColor                  = @"MTP_NavigationBarColor";
NSString *const MTP_NavigationBarButtonColor            = @"MTP_NavigationBarButtonColor";

#pragma mark - Theme Options
NSString *const MPFUSION_eventInformation           = @"eventInformation";
NSString *const MPFUSION_eventName                  = @"eventName";
NSString *const MPFUSION_eventLocation              = @"eventLocation";
NSString *const MPFUSION_eventDate                  = @"eventDate";
NSString *const MPFUSION_eventQREnabled             = @"qrEnabled";

NSString *const MPFUSION_sideBar                    = @"sidebar";
NSString *const MPFUSION_sideBarImage               = @"imageLogo";
NSString *const MPFUSION_sideBarDividerTitle        = @"navDividerTitle";

NSString *const MPFUSION_colors                     = @"colors";
NSString *const MPFUSION_color1 = @"color1";
NSString *const MPFUSION_color2 = @"color2";
NSString *const MPFUSION_color3 = @"color3";
NSString *const MPFUSION_color4 = @"color4";
NSString *const MPFUSION_color5 = @"color5";
NSString *const MPFUSION_color6 = @"color6";
NSString *const MPFUSION_color7 = @"color7";
NSString *const MPFUSION_color8 = @"color8";
NSString *const MPFUSION_color9 = @"color9";
NSString *const MPFUSION_color10 = @"color10";
NSString *const MPFUSION_color11 = @"color11";
NSString *const MPFUSION_color12 = @"color12";
NSString *const MPFUSION_color13 = @"color13";
NSString *const MPFUSION_color14 = @"color14";
NSString *const MPFUSION_color15 = @"color15";
NSString *const MPFUSION_color16 = @"color16";
NSString *const MPFUSION_color17 = @"color17";
NSString *const MPFUSION_color18 = @"color18";
NSString *const MPFUSION_color19 = @"color19";
NSString *const MPFUSION_color20 = @"color20";
NSString *const MPFUSION_color21 = @"color21";
NSString *const MPFUSION_color22 = @"color22";
NSString *const MPFUSION_color23 = @"color23";
NSString *const MPFUSION_color24 = @"color24";
NSString *const MPFUSION_color25 = @"color25";
NSString *const MPFUSION_color26 = @"color26";
NSString *const MPFUSION_color27 = @"color27";
NSString *const MPFUSION_color28 = @"color28";
NSString *const MPFUSION_color29 = @"color29";
NSString *const MPFUSION_color30 = @"color30";

NSString *const MPFUSION_homePageAppearance         = @"homePageAppearance";
NSString *const MPFUSION_homePageMenuDisplayStyle   = @"menuDisplayStyle";
NSString *const MPFUSION_homePageBackgroundTexture  = @"backgroundTexture";
NSString *const MPFUSION_homePageBackgroundImage    = @"backgroundImage";
NSString *const MPFUSION_homePageFeaturedImage      = @"featuredImage";
NSString *const MPFUSION_homePageBellyImage         = @"bellyImage";

@end
