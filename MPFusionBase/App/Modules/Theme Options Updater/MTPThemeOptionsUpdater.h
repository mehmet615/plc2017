//
//  MTPThemeOptionsUpdater.h
//  PTC16
//
//  Created by Michael Thongvanh on 2/29/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage,MTPThemeOptionsNetworkManager;

@interface MTPThemeOptionsUpdater : NSObject

@property (strong, nonatomic) MTPThemeOptionsNetworkManager *themeNetworkManager;

@property (strong, nonatomic) NSDictionary *themeOptions;

- (void)fetchThemeOptions;

- (void)fetchThemeOptions:(void(^)(NSDictionary *,NSError *))completionHandler;

- (void)fetchImagesForTheme:(NSDictionary *)themeOptions;

- (void)fetchImage:(NSString *)imageRemoteURL saveURL:(NSURL *)saveURL completion:(void (^)(UIImage *, NSError *))completionHandler;

- (NSURL *)themeOptionsSaveURL;

@end






@class MTPThemeOptionsNetworkManager;

@protocol MTPThemeOptionsNetworkDelegate <NSObject>
- (void)themeNetworkManager:(MTPThemeOptionsNetworkManager *)networkManager didDownloadAsset:(NSURL *)assetRemoteURL queueFinished:(BOOL)finished;
- (void)themeNetworkManager:(MTPThemeOptionsNetworkManager *)networkManager failedRemoteAsset:(NSURL *)assetRemoteURL error:(NSError *)error queueFinished:(BOOL)finished;
@end

@interface MTPThemeOptionsNetworkManager : NSObject
@property (weak, nonatomic) id <MTPThemeOptionsNetworkDelegate> delegate;
@property (strong, nonatomic) NSDictionary *currentRequests;

// download an array of assets via NSString paths
- (void)downloadAssets:(NSArray *)assets;
- (void)downloadAsset:(NSURL *)assetURL;

- (void)addAsset:(NSURL *)assetURL request:(NSURLRequest *)assetRequest;
- (void)removeRequest:(NSURL *)assetURL;

- (void)restartDownload:(NSURL *)assetURL;
- (void)restartDownloads;

- (BOOL)currentDownload:(NSURL *)assetURL;

- (BOOL)downloading;
@end