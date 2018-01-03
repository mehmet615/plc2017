//
//  MTPThemeOptionsUpdater.m
//  PTC16
//
//  Created by Michael Thongvanh on 2/29/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "MTPThemeOptionsUpdater.h"
#import "SIAlertView.h"
#import "UINavigationBar+MTPHelper.h"
#import "MTPAppSettingsKeys.h"
#import "UIColor+AppColors.h"
#import <UIKit/UIImage.h>
#import "MTPDLogDefine.h"

@implementation MTPThemeOptionsUpdater

- (instancetype)init
{
    if (self = [super init])
    {
        _themeNetworkManager = [MTPThemeOptionsNetworkManager new];
    }
    return self;
}

- (NSError *)errorWithMessage:(NSString *)localizedDescriptionMessage code:(NSInteger)errorCode
{
    if (localizedDescriptionMessage.length) 
    {
        return [NSError errorWithDomain:@"com.MeetingPlay.MPFusion" code:errorCode userInfo:@{NSLocalizedDescriptionKey: localizedDescriptionMessage}];
    }
    
    return nil;
}

- (void)fetchThemeOptions
{
    [self fetchThemeOptions:nil];
}

- (void)fetchThemeOptions:(void (^)(NSDictionary *, NSError *))completionHandler
{
    NSString *themeOptionsUpdateURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"MTP_ThemeOptionsURL"];
    if (themeOptionsUpdateURL.length == 0)
    {
        NSLog(@"\ntheme options url was empty %@",themeOptionsUpdateURL);
        
        if (completionHandler)
        {
            NSError *error = [self errorWithMessage:@"Theme options url was empty." code:3010];
            completionHandler(nil,error);
        }
        return;
    }
    
    NSMutableURLRequest *themeOptionsRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:themeOptionsUpdateURL]];
    themeOptionsRequest.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    __weak typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:themeOptionsRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if (error)
          {
              NSLog(@"error %@",error);
              if (completionHandler)
              {
                  completionHandler(nil,error);
              }
              return;
          }
          
          NSError *serializationError = nil;
          id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
          if (responseObject)
          {
              if ([responseObject writeToURL:[weakSelf themeOptionsSaveURL] atomically:YES])
              {
                  NSLog(@"saved theme options to url %@",[weakSelf themeOptionsSaveURL]);
              }
              
              NSTimeInterval lastUpdate = [[NSUserDefaults standardUserDefaults] integerForKey:@"MTP_ThemeLastUpdated"];
              NSTimeInterval menuUpdate = [responseObject[@"themeUpdated"] integerValue];

              if (menuUpdate > lastUpdate)
              {
                  [[NSUserDefaults standardUserDefaults] setInteger:menuUpdate forKey:@"MTP_ThemeLastUpdated"];
                  [[NSUserDefaults standardUserDefaults] synchronize];
                  
                  UIColor *navigationBarColor = [UIColor mtp_colorFromString:[responseObject[MPFUSION_colors] objectForKey:MPFUSION_color1]];
                  if (navigationBarColor)
                  {
                      [[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
                      [[UINavigationBar appearance] setShadowImage:[UIImage new]];

                      [[UINavigationBar appearance] setBarTintColor:navigationBarColor];
                  }
                  
                  UIColor *navigationBarTintColor = [UIColor mtp_colorFromString:[responseObject[MPFUSION_colors] objectForKey:MPFUSION_color25]];
                  if (navigationBarTintColor)
                  {
                      [[UINavigationBar appearance] setTintColor:navigationBarTintColor];
                  }
                  
                  [weakSelf setupDefaults:responseObject];
                  
                  [weakSelf fetchImagesForTheme:responseObject];
                  
                  if (completionHandler)
                  {
                      completionHandler(responseObject,nil);
                  }
                  
                  [[NSNotificationCenter defaultCenter] postNotificationName:@"MTP_ThemeOptionsDidUpdateNotification" object:nil userInfo:nil];
              }
              else
              {
                  if (completionHandler)
                  {
                      completionHandler(responseObject,nil);
                  }
              }
          }
          else
          {
              if (completionHandler)
              {
                  completionHandler(nil,serializationError);
              }
          }
      }] resume];
}

- (void)setupDefaults:(NSDictionary *)eventDefaults
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:eventDefaults];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIImage *)backgroundImage:(NSString *)baseColorString
{
    CGFloat red = 1;
    CGFloat green = 1;
    CGFloat blue = 1;
    CGFloat alpha = 1;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIVector *point1 = [CIVector vectorWithX:0 Y:-30];
    CIVector *point2 = [CIVector vectorWithX:0 Y:34];
    
    UIColor *baseColor = [UIColor mtp_colorFromString:baseColorString];
    [baseColor getRed:&red green:&green blue:&blue alpha:&alpha];
    CIColor *startColor = [CIColor colorWithRed:red green:green blue:blue];
    
    baseColor = [UIColor mtp_colorFromString:@"000000"];
    [baseColor getRed:&red green:&green blue:&blue alpha:&alpha];
    CIColor *endColor = [CIColor colorWithRed:red green:green blue:blue];
    
    
    CIFilter *linearGradient = [CIFilter filterWithName:@"CILinearGradient"
                                          keysAndValues:
                                @"inputPoint0", point1,
                                @"inputPoint1", point2,
                                @"inputColor0", endColor,
                                @"inputColor1", startColor,
                                nil];
    
    CIImage *result = [linearGradient valueForKey:kCIOutputImageKey];
    CGRect extent = CGRectMake(0, 0, 1242, 44);
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    
    UIImage *backgroundImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return backgroundImage;
}

- (NSURL *)themeOptionsSaveURL
{
    NSURL *themeLocationURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    themeLocationURL = [themeLocationURL URLByAppendingPathComponent:@"UpdatedThemeUptions.mtparchive"];
    return themeLocationURL;
}

- (NSURL *)themeBackgroundImageSaveURL
{
    NSString *backgroundImageFilename = [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_QuickLinksAppearanceOptions] objectForKey:MTP_QuickLinksAppearanceBackgroundImage];
    NSURL *backgroundImageURL = [NSURL URLWithString:backgroundImageFilename];
    
    NSString *filename = [backgroundImageURL lastPathComponent];
    if (filename.length == 0)
    {
        filename = @"backgroundImage.jpg";
    }
    
    NSURL *themeLocationURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    themeLocationURL = [themeLocationURL URLByAppendingPathComponent:filename];
    return themeLocationURL;
}

- (NSURL *)themeHeroImageSaveURL
{
    NSString *backgroundImageFilename = [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_QuickLinksAppearanceOptions] objectForKey:MTP_QuickLinksAppearanceHeroHeader];
    NSURL *backgroundImageURL = [NSURL URLWithString:backgroundImageFilename];
    
    NSString *filename = [backgroundImageURL lastPathComponent];
    if (filename.length == 0)
    {
        filename = @"heroImage.jpg";
    }
    
    NSURL *themeLocationURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:YES error:nil];
    themeLocationURL = [themeLocationURL URLByAppendingPathComponent:filename];
    return themeLocationURL;
}

#pragma mark - Image Fetching
- (void)fetchImagesForTheme:(NSDictionary *)themeOptions
{
    NSMutableArray *assetsToDownload = [NSMutableArray new];
    
    NSString *sideBarImageLogo = [themeOptions[MPFUSION_sideBar] objectForKey:MPFUSION_sideBarImage];
    NSString *backgroundTexture = [themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageBackgroundTexture];
    NSString *backgroundImage = [themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageBackgroundImage];
    NSString *featuredImage = [themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageFeaturedImage];
    
    if (sideBarImageLogo.length)
    {
        [assetsToDownload addObject:sideBarImageLogo];
    }
    
    if (backgroundTexture.length)
    {
        [assetsToDownload addObject:backgroundTexture];
    }
    
    if (backgroundImage.length)
    {
        [assetsToDownload addObject:backgroundImage];
    }
    
    if (featuredImage.length)
    {
        [assetsToDownload addObject:featuredImage];
    }
    
    [self.themeNetworkManager downloadAssets:assetsToDownload];
}

- (void)fetchImage:(NSString *)imageRemoteURL saveURL:(NSURL *)saveURL completion:(void (^)(UIImage *, NSError *))completionHandler
{
    if (imageRemoteURL.length && saveURL.path.length)
    {
        __block UIImage *fetchedImage = [UIImage imageWithContentsOfFile:[saveURL path]];
        if (fetchedImage == nil)
        {
            NSURLRequest *remoteImageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageRemoteURL] cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:30];
            [[[NSURLSession sharedSession] downloadTaskWithRequest:remoteImageRequest completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error)
              {
                  if (error)
                  {
                      DLog(@"image download error %@",error);
                  }
                  else
                  {
                      NSError *copyError = nil;
                      if (![[NSFileManager defaultManager] copyItemAtURL:location toURL:saveURL error:&copyError])
                      {
                          DLog(@"image copy error %@",copyError);
                      }
                      else
                      {
                          DLog(@"file saved to %@",saveURL);
                      }
                  }
                  
                  if (completionHandler)
                  {
                      fetchedImage = [UIImage imageWithContentsOfFile:[saveURL path]];
                      completionHandler(fetchedImage,nil);
                  }
              }] resume];
        }
        else
        {
            if (completionHandler)
            {
                completionHandler(fetchedImage,nil);
            }
        }
    }
    else
    {
        if (completionHandler)
        {
            completionHandler(nil,[NSError errorWithDomain:@"com.MeetingPlay.MPFusion.ImageFetchError" code:3001 userInfo:@{NSLocalizedDescriptionKey:@"No image url found"}]);
        }
    }

}

@end


#import "MTPThemeOptionsManager.h"
@interface MTPThemeOptionsNetworkManager () <NSURLSessionDelegate,NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSURLSession *themOptionsURLSession;
@end

@implementation MTPThemeOptionsNetworkManager

- (instancetype)init
{
    if (self = [super init])
    {
        _themOptionsURLSession = [NSURLSession sessionWithConfiguration:[[NSURLSession sharedSession] configuration] delegate:self delegateQueue:nil];
        _currentRequests = [NSDictionary new];
    }
    
    return self;
}

- (void)dealloc
{
    [self.themOptionsURLSession invalidateAndCancel];
}

- (void)downloadAssets:(NSArray *)assets
{
    for (id possibleAssetPath in assets)
    {
        if ([possibleAssetPath isKindOfClass:[NSString class]])
        {
            NSString *assetPath = (NSString *)possibleAssetPath;
            NSURL *assetURL = [NSURL URLWithString:[assetPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            [self downloadAsset:assetURL];
        }
    }
}

- (void)downloadAsset:(NSURL *)assetURL
{
    if ([self currentDownload:assetURL])
    {
        DLog(@"\ndownload in progress for asset %@",assetURL);
        return;
    }
    
    NSURLRequest *assetRequest = [NSURLRequest requestWithURL:assetURL];
    
    if (assetRequest)
    {
        [self addAsset:assetURL request:assetRequest];
    }
    
    [self beginDownloadTask:assetRequest];
}

- (void)beginDownloadTask:(NSURLRequest *)request
{
    NSURLSessionDownloadTask *assetDownloadTask = [self.themOptionsURLSession downloadTaskWithRequest:request];
    [assetDownloadTask resume];
}

- (BOOL)currentDownload:(NSURL *)assetURL
{
    NSDictionary *currentRequests = [self.currentRequests copy];
    return [currentRequests objectForKey:assetURL];
}

- (BOOL)downloading
{
    return self.currentRequests.allKeys.count;
}

- (void)addAsset:(NSURL *)assetURL request:(NSURLRequest *)assetRequest
{
    NSMutableDictionary *updatedCurrentRequests = [NSMutableDictionary dictionaryWithDictionary:self.currentRequests];
    [updatedCurrentRequests setObject:assetRequest forKey:assetURL];
    self.currentRequests = [NSDictionary dictionaryWithDictionary:updatedCurrentRequests];
}

- (void)removeRequest:(NSURL *)assetURL
{
    NSMutableDictionary *updatedCurrentRequests = [NSMutableDictionary dictionaryWithDictionary:self.currentRequests];
    [updatedCurrentRequests removeObjectForKey:assetURL];
    self.currentRequests = [NSDictionary dictionaryWithDictionary:updatedCurrentRequests];
}

- (void)restartDownload:(NSURL *)assetURL
{
    [self downloadAsset:assetURL];
}

- (void)restartDownloads
{
    __weak typeof(&*self)weakSelf = self;
    [self.currentRequests enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([obj isKindOfClass:[NSURLRequest class]])
        {
            [weakSelf beginDownloadTask:obj];
        }
    }];
}

#pragma mark - Image Fetching


#pragma mark - Protocol Conformance
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSString *assetFilename = [downloadTask.originalRequest.URL lastPathComponent];
    if (assetFilename.length == 0)
    {
        DLog(@"\nerror with asset filename %@",assetFilename);
    }
    
    NSURL *assetSaveURL = [MTPThemeOptionsManager saveURLForImage:assetFilename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:assetSaveURL.path])
    {
        NSError *removalError = nil;
        if ([fileManager removeItemAtURL:assetSaveURL error:&removalError])
        {
            DLog(@"\nfile removed %@",assetSaveURL);
        }
        else
        {
            DLog(@"\nfile removal error %@",removalError);
        }
    }
    
    NSError *copyError = nil;
    if ([fileManager copyItemAtURL:location toURL:assetSaveURL error:&copyError])
    {
        DLog(@"\nfile copied successfully %@",assetSaveURL);
        [self removeRequest:downloadTask.originalRequest.URL];
    }
    else
    {
        if (copyError)
        {
            DLog(@"\ncopy error %@",copyError);
            [self URLSession:session task:downloadTask didCompleteWithError:copyError];
        }
    }
    
    BOOL downloading = [self downloading];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(themeNetworkManager:didDownloadAsset:queueFinished:)])
    {
        [self.delegate themeNetworkManager:self didDownloadAsset:downloadTask.originalRequest.URL queueFinished:downloading];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(themeNetworkManager:failedRemoteAsset:error:queueFinished:)])
    {
        BOOL downloading = [self downloading];
        [self.delegate themeNetworkManager:self failedRemoteAsset:task.originalRequest.URL error:error queueFinished:downloading];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}


@end

















