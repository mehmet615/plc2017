//
//  MTPDocumentViewerCoordinator.h
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 5/10/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface MTPDocumentViewerCoordinator : NSObject <QLPreviewControllerDataSource>

@property (strong, nonatomic) NSArray *previewItems;
@property (strong, nonatomic) UIColor *titleTextColor;


- (void)openDocument:(NSURL *)localFileUrl presenter:(UIViewController *)presenationTarget;

- (void)fetchDocument:(NSURL *)remoteFileUrl completion:(void(^)(NSURL *documentLocalUrl,NSError *fetchError))completionHandler;

- (BOOL)saveDocument:(NSData *)documentData location:(NSURL *)localSaveLocation;

- (BOOL)shouldFetchDocument:(NSURL *)remoteFileUrl;
- (BOOL)fileExists:(NSURL *)remoteFileUrl;
- (NSURL *)localSaveLocation:(NSString *)filename;

@end
