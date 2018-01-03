//
//  MTPThemeOptionsManager.h
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/17/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MTPThemeOptionsUpdater.h" // import for network manager delegate

typedef NS_ENUM(NSUInteger, MTPHomePageDisplayStyle) {
    MTPHomePageDisplayCircle,
    MTPHomePageDisplaySquare,
    MTPHomePageDisplayList,
};


@class MTPThemeOptionsUpdater,UIImage,UIView;

@interface MTPThemeOptionsManager : NSObject

@property (strong, nonatomic) NSDictionary *themeOptions;

@property (strong, nonatomic) MTPThemeOptionsUpdater *optionsUpdater;

- (NSDictionary *)loadThemeOptions;
- (void)fetchThemeOptions:(void(^)(NSDictionary *,NSError *))completionHandler;
- (void)fetchImage:(NSString *)imageRemoteURL saveURL:(NSURL *)saveURL completion:(void (^)(UIImage *, NSError *))completionHandler;

- (void)loadRemoteTexture:(NSString *)textureURL forView:(UIView *)targetView;

- (NSURL *)themeOptionsSaveURL;
+ (NSURL *)saveURLForImage:(NSString *)imageRemoteURL;

- (NSString *)backgroundTexture;
- (NSString *)homepageBackground;

- (void)setAssetDownloadDelegate:(id<MTPThemeOptionsNetworkDelegate>)downloadDelegate;

+ (MTPHomePageDisplayStyle)displayStyleForKey:(NSString *)displayStyle;

- (void)checkVersion;

@end
