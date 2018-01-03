//
//  MAMQRReaderViewController.h
//  PrudentialIIC
//
//  Created by Michael Thongvanh on 5/26/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

@class AVCaptureSession, AVCaptureVideoPreviewLayer, AVCaptureMetadataOutput, MTPNavigationRouter;

@interface MAMQRReaderViewController : UIViewController <MTPNavigationItemCustomizable>

@property (nonatomic, strong) MTPNavigationRouter *navigationRouter;

@property (nonatomic, strong) AVCaptureSession *qrCaptureSession;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureMetadataOutput *captureMetadata;
@property (nonatomic, assign, getter=isSessionRunning) BOOL sessionRunning;
@property (nonatomic, strong) UIView *previewLayerContainer;

@property (nonatomic, strong) UIButton *beginScanButton;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;

@property (weak, nonatomic) id<MTPMainMenuTogglable> menuToggleDelegate;

- (void)startSession;
- (void)stopSession;
@end
