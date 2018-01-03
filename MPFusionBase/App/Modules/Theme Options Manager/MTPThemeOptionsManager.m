//
//  MTPThemeOptionsManager.m
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/17/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "MTPThemeOptionsManager.h"
#import "MTPThemeOptionsUpdater.h"
#import <UIKit/UIImage.h>
#import <UIKit/UIView.h>
#import "MTPDLogDefine.h"
#import "MTPAppSettingsKeys.h"
#import "UIColor+AppColors.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSObject+MTPModelValidation.h"
#import "SIAlertView.h"

@implementation MTPThemeOptionsManager

- (NSDictionary *)loadThemeOptions
{
    // check for saved or load default theme options
    NSDictionary *themeOptions = [NSDictionary dictionaryWithContentsOfURL:[self themeOptionsSaveURL]];
    
    if (themeOptions.allKeys.count == 0)
    {
        themeOptions = [self loadDefaultThemeOptions];
    }
    
    self.themeOptions = themeOptions;
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:themeOptions];
    
    return themeOptions;
}

- (void)fetchThemeOptions:(void(^)(NSDictionary *,NSError *))completionHandler
{
    __weak typeof(&*self)weakSelf = self;
    [self.optionsUpdater fetchThemeOptions:^(NSDictionary *themeOptions, NSError *error)
    {
        if (error)
        {
            DLog(@"\ntheme options fetch error %@",error);
        }
        else
        {            
            weakSelf.themeOptions = themeOptions;
        }
        
        if (completionHandler)
        {
            completionHandler(themeOptions,error);
        }
    }];
}


- (void)fetchImage:(NSString *)imageRemoteURL saveURL:(NSURL *)saveURL completion:(void (^)(UIImage *, NSError *))completionHandler
{
    [self.optionsUpdater fetchImage:imageRemoteURL saveURL:saveURL completion:completionHandler];
}

- (void)loadRemoteTexture:(NSString *)textureURL forView:(UIView *)targetView
{
    if (textureURL.length == 0)
    {
        return;
    }
    
    NSURL *imageSaveURL = [MTPThemeOptionsManager saveURLForImage:textureURL];
    if (imageSaveURL.path.length)
    {
        [self.optionsUpdater fetchImage:textureURL saveURL:imageSaveURL completion:^(UIImage *fetchedImage, NSError *error) {
            if (error)
            {
                DLog(@"\nremote texture fetch error %@",error);
            }
            else
            {
                [targetView setBackgroundColor:[UIColor colorWithPatternImage:fetchedImage]];
            }
        }];
    }
    else
    {
        DLog(@"\nsave path was nil %@",imageSaveURL);
    }
}

- (NSString *)backgroundTexture
{
    return [self.themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageBackgroundTexture];
}

- (NSString *)homepageBackground
{
    return [self.themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageBackgroundImage];
}

#pragma mark - Utility Methods
- (NSDictionary *)loadDefaultThemeOptions
{
    NSURL *defaultThemeOptionsURL = [[NSBundle mainBundle] URLForResource:@"ThemeOptions" withExtension:@"json"];
    NSError *serializationError = nil;
    NSDictionary *defaultThemeOptions = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:defaultThemeOptionsURL] options:NSJSONReadingAllowFragments error:&serializationError];
    if (serializationError)
    {
        DLog(@"\ndefault serialization error %@",serializationError);
    }
    return defaultThemeOptions;
}

- (NSURL *)themeOptionsSaveURL
{
    NSURL *themeLocationURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    themeLocationURL = [themeLocationURL URLByAppendingPathComponent:@"UpdatedThemeUptions.mtparchive"];
    return themeLocationURL;
}

+ (NSURL *)saveURLForImage:(NSString *)imageRemoteURL
{
    if (imageRemoteURL.length == 0)
    {
        NSLog(@"no image filename found");
        return nil;
    }
    // get the full remote image URL
    NSURL *imageFullURL = [NSURL URLWithString:[imageRemoteURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    // get the name of the image
    NSString *filename = imageFullURL.lastPathComponent;
    // create the local save path for the image
    NSURL *imageSaveURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    imageSaveURL = [imageSaveURL URLByAppendingPathComponent:filename];
    return imageSaveURL;
}

- (MTPThemeOptionsUpdater *)optionsUpdater
{
    if (_optionsUpdater == nil)
    {
        _optionsUpdater = [MTPThemeOptionsUpdater new];
    }
    
    return _optionsUpdater;
}

+ (MTPHomePageDisplayStyle)displayStyleForKey:(NSString *)displayStyle
{
    if ([displayStyle caseInsensitiveCompare:@"square"] == NSOrderedSame) {
        return MTPHomePageDisplaySquare;
    }
    else if ([displayStyle caseInsensitiveCompare:@"list"] == NSOrderedSame) {
        return MTPHomePageDisplayList;
    }
    else {
        return MTPHomePageDisplayCircle;
    }
}

- (void)setAssetDownloadDelegate:(id<MTPThemeOptionsNetworkDelegate>)downloadDelegate
{
    [self.optionsUpdater.themeNetworkManager setDelegate:downloadDelegate];
}

- (void)checkVersion
{
    NSString *baseAPI = [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL];
    NSURL *baseAPIURL = [NSURL URLWithString:baseAPI];
    NSArray *baseAPIParts = [baseAPIURL.host componentsSeparatedByString:@"."];
    NSString *conferenceName = [baseAPIParts.firstObject uppercaseString];
    
    NSString *versionJSON = [NSString version:conferenceName];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:versionJSON] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error)
        {
            DLog(@"\nerror %@",error);
        }
        else
        {
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (responseObject)
            {
                NSString *versionNewest = [responseObject[@"version"] mtp_stringValue];
                if (versionNewest.length == 0)
                {
                    return;
                }
                NSString *url = [responseObject[@"url"] mtp_stringValue];
                NSNumber *showAlert = [responseObject[@"showAlert"] mtp_numberValue];
                
                NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                if ([currentVersion compare:versionNewest] == NSOrderedAscending)
                {
                    // show update alert
                    SIAlertView *versionAlert = [[SIAlertView alloc] initWithTitle:@"New Version Available" andMessage:@"A newer version of the application is available. Please select update to upgrade your version now."];
                    [versionAlert addButtonWithTitle:@"Update" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                    }];
                    [versionAlert addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeCancel handler:nil];
                    if (showAlert.boolValue)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [versionAlert show];
                        });
                    }
                }
                else
                {
                    DLog(@"\nversion is ok");
                }
            }
            else
            {
                DLog(@"\ndebugging message %@",error);
            }
        }
    }] resume];
}
@end
