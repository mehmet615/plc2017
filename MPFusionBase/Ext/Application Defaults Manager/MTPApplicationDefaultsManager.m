//
//  MTPApplicationDefaultsManager.m
//
//  Created by MeetingPlay on 4/3/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPApplicationDefaultsManager.h"
#import "AppDelegate.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "SIAlertView.h"
#import "EventKeys.h"
#import "MTPAppSettingsKeys.h"
#import "UIColor+AppColors.h"
#import "MTPThemeOptionsUpdater.h"
#import "MTPNavigationMenuLoader.h"

#import "MTPMenuItemManager.h"
#import "MTPThemeOptionsManager.h"

@interface MTPApplicationDefaultsManager ()
@property (strong, nonatomic) MTPThemeOptionsUpdater *optionsUpdater;
@end

@implementation MTPApplicationDefaultsManager

+ (instancetype)defaultsManager:(AppDelegate *)appDelegate
{
    return [[MTPApplicationDefaultsManager alloc] initWithAppDelegate:appDelegate];
}

- (instancetype)initWithAppDelegate:(AppDelegate *)appDelegate
{
    self = [super init];
    if (self)
    {
        _optionsUpdater = [MTPThemeOptionsUpdater new];
        
        _appDelegate = appDelegate;
        _eventDefaults = [self retrieveEventDefaults];
        
        [self setupDefaults:_eventDefaults];
        [self setupAppearanceDefaults];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSDictionary *)retrieveEventDefaults
{
    NSMutableDictionary *eventDefaults = [NSMutableDictionary dictionaryWithDictionary:[self loadDefaults:@"EventDefaults"]];
    
    NSDictionary *networkOptions = [self networkOptions];
    if (networkOptions.allKeys.count)
    {
        [eventDefaults addEntriesFromDictionary:networkOptions];
    }
    
    MTPNavigationMenuLoader *menuLoader = [MTPNavigationMenuLoader new];
    NSURL *updatedMainMenuURL = [menuLoader updatedMenuSaveURL];
    NSDictionary *menuItems = [NSDictionary dictionaryWithContentsOfURL:updatedMainMenuURL];
    if (menuItems.allKeys.count == 0)
    {
        menuItems = [self loadDefaults:@"MenuItems"];
    }
    
    if (menuItems)
    {
        [eventDefaults addEntriesFromDictionary:menuItems];
    }
    
    /*
     *  convenient create JSON menu that lives on the ftp
     */
//    [self outputJSON:menuItems];
    
    if (eventDefaults.allKeys.count > 0)
    {
        return eventDefaults;
    }
    else
    {
        return nil;
    }
}

- (NSDictionary *)loadDefaults:(NSString *)defaultsFile
{
    NSURL *defaultThemeOptionsURL = [[NSBundle mainBundle] URLForResource:@"EventDefaults" withExtension:@"plist"];
    NSDictionary *defaultThemeOptions = [[NSDictionary alloc] initWithContentsOfURL:defaultThemeOptionsURL];
    return defaultThemeOptions;
}

- (NSDictionary *)networkOptions
{
    return @{MTP_NetworkOptions: @{MTP_EventBaseHTTPURL: @"http://plc2017.mpeventapps.com",
                                   MTP_EventBaseAPIURL: @"http://plc2017api.mpeventapps.com",
                                   MTP_URLRequestDefaultTimeoutInterval: @"30",
                                   MTP_XAuthToken: @"Sm9lLCBkb24ndCByZWJvb3QgdGhlIHNlcnZlciE=",
                                   MTP_ParseApplicationID: @"",
                                   MTP_ParseClientKey: @""}};
}

- (void)setupDefaults:(NSDictionary *)eventDefaults
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:eventDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (MTPMenuItemManager *)menuItemManager
{
    MTPMenuItemManager *menuItemManager = [MTPMenuItemManager new];
    NSDictionary *menuItems = [menuItemManager loadMenuItems];
    if (menuItems)
    {
        [menuItemManager parseMenuItems:menuItems];
    }
    
    /*
     *  convenient create JSON menu that lives on the ftp
     */
    //    [self outputJSON:menuItems];
    
    return menuItemManager;
}

- (MTPThemeOptionsManager *)themeOptionsManager
{
    MTPThemeOptionsManager *themeOptionsManager = [MTPThemeOptionsManager new];
    NSDictionary *themeOptions = [themeOptionsManager loadThemeOptions];
    UIColor *navigationBarColor = [UIColor mtp_colorFromString:[themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color1]];
    if (navigationBarColor)
    {
        [[UINavigationBar appearance] setBarTintColor:navigationBarColor];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    }
    
    UIColor *navigationBarTintColor = [UIColor mtp_colorFromString:[themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color25]];
    if (navigationBarTintColor)
    {
        [[UINavigationBar appearance] setTintColor:navigationBarTintColor];
    }
    
    return themeOptionsManager;
}

- (void)setupAppearanceDefaults
{
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[SIAlertView appearance] setDestructiveButtonColor:kDarkBlue];
    [[SIAlertView appearance] setCancelButtonColor:[UIColor darkGrayColor]];
    
    [[SIAlertView appearance] setTitleFont:[UIFont fontWithName:@"RobotoCondensed-Bold" size:25.f]];
    [[SIAlertView appearance] setTitleColor:[UIColor darkGrayColor]];
    
    [[SIAlertView appearance] setMessageColor:[UIColor darkGrayColor]];
    [[SIAlertView appearance] setMessageFont:[UIFont fontWithName:@"Roboto" size:17.f]];
    
    [[SIAlertView appearance] setButtonFont:[UIFont fontWithName:@"RobotoCondensed-Bold" size:20.f]];
}

@end
