//
//  MTPDocumentViewerCoordinator.m
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 5/10/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPDocumentViewerCoordinator.h"

#import "MTPDLogDefine.h"

@implementation MTPDocumentViewerCoordinator

- (void)fetchDocument:(NSURL *)remoteFileUrl completion:(void (^)(NSURL *, NSError *))completionHandler
{
    __weak typeof(&*self)weakSelf = self;
    
    [[[NSURLSession sharedSession] dataTaskWithURL:remoteFileUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSURL *saveLocation = nil;
          NSError *fetchError = nil;
          
          if (error)
          {
              DLog(@"\nerror %@",error);
              fetchError = error;
          }
          else
          {
              NSString *filename = [remoteFileUrl.lastPathComponent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
              NSURL *localSaveLocation = [weakSelf localSaveLocation:filename];
              
              if ([weakSelf saveDocument:data location:localSaveLocation])
              {
                  DLog(@"\nsaved %@",localSaveLocation);
              }
              else
              {
                  fetchError = [NSError errorWithDomain:@"com.MeetingPlay.MPFusionBase.DocumentSave" code:10001 userInfo:@{NSLocalizedDescriptionKey: @"Document save error - Document was not saved"}];
              }
              
              saveLocation = localSaveLocation;
          }
          
          if (completionHandler)
          {
              completionHandler(saveLocation,fetchError);
          }
      }] resume];
}

- (void)openDocument:(NSURL *)localFileUrl presenter:(UIViewController *)presenationTarget
{
    if ([QLPreviewController canPreviewItem:localFileUrl])
    {
        self.previewItems = @[localFileUrl];
        
        QLPreviewController *documentPreviewer = [QLPreviewController new];
        documentPreviewer.extendedLayoutIncludesOpaqueBars = NO;
        documentPreviewer.edgesForExtendedLayout = UIRectEdgeNone;
        documentPreviewer.dataSource = self;
        
        if (self.titleTextColor == nil) {
            self.titleTextColor = [UIColor whiteColor];
        }
        
        [[UINavigationBar appearanceWhenContainedIn:[QLPreviewController class], nil] setTitleTextAttributes:@{NSForegroundColorAttributeName: self.titleTextColor}];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [presenationTarget presentViewController:documentPreviewer animated:NO completion:nil];
        });
    }
}

- (BOOL)saveDocument:(NSData *)documentData location:(NSURL *)localSaveLocation
{
    NSError *writeError = nil;
    BOOL saved = [documentData writeToURL:localSaveLocation options:NSDataWritingAtomic error:&writeError];
    if (saved)
    {
        DLog(@"\nsaved %@",localSaveLocation);
    }
    else
    {
        DLog(@"\ndebugging message : failed %@",writeError);
    }
    
    return saved;
}

- (BOOL)shouldFetchDocument:(NSURL *)remoteFileUrl
{
    return ![self fileExists:remoteFileUrl];
}

- (BOOL)fileExists:(NSURL *)remoteFileUrl
{
    NSString *filename = [remoteFileUrl.lastPathComponent stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *localSave = [self localSaveLocation:filename];
    
    NSFileManager *filemanager = [NSFileManager defaultManager];
    
    return [filemanager fileExistsAtPath:localSave.path];
}

- (NSURL *)localSaveLocation:(NSString *)filename
{
    if (filename.length == 0) {
        return nil;
    }
    
    NSURL *documentsSaveDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    
    NSURL *savedDocument = [documentsSaveDirectory URLByAppendingPathComponent:[filename stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    return savedDocument;
}

#pragma mark - Protocol Conformance

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return self.previewItems.count;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    return self.previewItems[index];
}

@end
