//
//  MAMQRReaderViewController.m
//  PrudentialIIC
//
//  Created by Michael Thongvanh on 5/26/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMQRReaderViewController.h"
#import "UIButton+MTPNavigationBar.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "UIView+AutoLayoutHelper.h"
#import <AVFoundation/AVFoundation.h>
#import "UIColor+AppColors.h"
#import "MTPMenuItem.h"
#import "UIViewController+NavigationItemSetup.h"
#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"
#import "MTPAppSettingsKeys.h"

@interface MAMQRReaderViewController ()

@end

@implementation MAMQRReaderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    self.previewLayerContainer = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view insertSubview:self.previewLayerContainer atIndex:0];
    
    [self setupQRScanner];
    [self registerForNotifications];
    
    [self configureScanButton];
    self.beginScanButton.translatesAutoresizingMaskIntoConstraints = false;
    
    if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined || [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized)
    {
        [self startSession];
    }
    else
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Problem Accessing Camera" andMessage:@"Please select \'Settings\' to enter the Settings app and ensure \'Camera\' is enabled (green), or \'Cancel\' to continue."];
        [alertView addButtonWithTitle:@"Settings" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alertView addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeCancel handler:nil];
        [alertView show];
    }
    
    [self setupNavigationItem:[[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];
    
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupButtonConstraints];
    
    if (self.isSessionRunning == false)
    {
        self.beginScanButton.enabled = true;
    }
    
//    [self.beginScanButton setBackgroundColor:[UIColor appTintColor]];
    self.beginScanButton.backgroundColor = [UIColor mtp_colorFromString:[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color25]];
    NSString *performScanButtonText = @"\uf029";
    [self.beginScanButton setTitle:performScanButtonText forState:UIControlStateNormal];
    [self.beginScanButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:27]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self stopSession];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma NSNotification Registration

- (void)registerForNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

#pragma mark - Helper Methods
- (void)toggleMenu:(id)sender
{
    if (self.menuToggleDelegate && [self.menuToggleDelegate respondsToSelector:@selector(topViewControllerShouldToggleMenu:)])
    {
        [self.menuToggleDelegate topViewControllerShouldToggleMenu:nil];
    }
    else
    {
        DLog(@"no delegate found");
    }
    
    if (self.isSessionRunning)
    {
        [self stopSession];
    }
    else
    {
        [self startSession];
    }
}

#pragma mark QR Setup
- (void)setupQRScanner
{
    if (self.qrCaptureSession)
    {
        return;
    }
    
    self.qrCaptureSession = [[AVCaptureSession alloc] init];
    self.qrCaptureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    AVCaptureDeviceInput *cameraBackFacing;
    NSArray *possibleCaptureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    if (!possibleCaptureDevices)
    {
        SIAlertView *noCameraAlert = [[SIAlertView alloc] initWithTitle:@"No Camera Found!"
                                                             andMessage:@"We couldn't access your camera in order to scan the QR Code"];
        [noCameraAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
        [noCameraAlert show];
        return;
    }
    
    for (AVCaptureDevice *device in possibleCaptureDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            NSError *deviceInputSettingError = nil;
            cameraBackFacing = [AVCaptureDeviceInput deviceInputWithDevice:device error:&deviceInputSettingError];
            
            if (!cameraBackFacing || deviceInputSettingError) {
                DLog(@"\nCamera error %@", deviceInputSettingError.localizedDescription);
            }
        }
    }
    
    if ([self.qrCaptureSession canAddInput:cameraBackFacing])
    {
        [self.qrCaptureSession addInput:cameraBackFacing];
    }
    else
    {
        DLog(@"\ncant add the camera to the session");
    }
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.qrCaptureSession];
    self.previewLayer.frame = self.view.bounds;
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.previewLayerContainer.layer addSublayer:self.previewLayer];
    
    self.captureMetadata = [[AVCaptureMetadataOutput alloc] init];
    dispatch_queue_t metadataCaptureQueue = dispatch_queue_create("com.MeetingPlay.QRCodeReader", 0);
    [self.captureMetadata setMetadataObjectsDelegate:self queue:metadataCaptureQueue];
    
    if ([self.qrCaptureSession canAddOutput:self.captureMetadata])
    {
        [self.qrCaptureSession addOutput:self.captureMetadata];
    }
    else
    {
        DLog(@"\ncan't add metadata output");
    }
}

#pragma mark Starting and Stopping QR Session

- (void)startSession
{
    if (self.isSessionRunning)
    {
        return;
    }
    else
    {
        self.sessionRunning = true;
        self.beginScanButton.enabled = false;
    }
    
    [self.qrCaptureSession startRunning];
    self.captureMetadata.metadataObjectTypes = self.captureMetadata.availableMetadataObjectTypes;
}

- (void)stopSession
{
    if (self.isSessionRunning == false)
    {
        return;
    }
    
    [self.qrCaptureSession stopRunning];
    self.sessionRunning = false;
    self.beginScanButton.enabled = true;
}

#pragma mark AVCaptureMetadataOutputObjectsDelegate Conformance

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataObject *metadataObject in metadataObjects)
    {
        if ([metadataObject isKindOfClass:[AVMetadataMachineReadableCodeObject class]])
        {
            AVMetadataMachineReadableCodeObject *codeObject = (AVMetadataMachineReadableCodeObject *)[self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
            if ([codeObject.type isEqualToString:@"org.iso.QRCode"])
            {
                [self showQRFound:codeObject];
            }
        }
    }
}

- (void)showQRFound:(AVMetadataMachineReadableCodeObject *)codeObject
{
    if (codeObject.stringValue)
    {
        NSURL *qrLink = [NSURL URLWithString:[codeObject.stringValue stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        if (qrLink == nil)
        {
            return;
        }
        
        NSString *foundQRCodeTitle = foundQRCodeTitle = @"Found a QR Code";
        NSString *foundQRCodeMessage = @"You've discovered a QR Code.\nWould you like to view the link?";
        NSString *foundQRCodeViewLinkText = @"View Link";
        NSString *foundQRCodeCancelText = @"Cancel";
        
        SIAlertView *foundQRAlert = [[SIAlertView alloc] initWithTitle:foundQRCodeTitle
                                                            andMessage:[NSString stringWithFormat:@"%@\n\n%@",qrLink.host,foundQRCodeMessage]];
        [foundQRAlert addButtonWithTitle:foundQRCodeViewLinkText type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
            if ([codeObject.stringValue rangeOfString:@"http://"].location != NSNotFound ||
                [codeObject.stringValue rangeOfString:@"https://"].location != NSNotFound)
            {
                [self openLink:codeObject.stringValue];
            }
        }];
        [foundQRAlert addButtonWithTitle:foundQRCodeCancelText type:SIAlertViewButtonTypeDefault handler:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self stopSession];
            [self openLink:codeObject.stringValue];
        });
    }
}

- (void)openLink:(NSString *)urlString
{
    MTPMenuItem *menuItem = [MTPMenuItem new];
    menuItem.title = @"Scanned Item";
    menuItem.webviewURL = urlString;
    menuItem.contentType = MTPContentTypeWebView;
    
    if (self.navigationRouter && menuItem.webviewURL.length)
    {
        [self.navigationRouter loadViewController:menuItem animated:NO];
    }
    else
    {
        DLog(@"\nerror opening scanned item %@ -- urlString %@",self.navigationRouter,urlString);
    }
}

#pragma mark - UI Setup
- (void)configureScanButton
{
    self.beginScanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.beginScanButton.layer.cornerRadius = 3.f;
    self.beginScanButton.layer.masksToBounds = true;
    
    [self.beginScanButton setBackgroundImage:[UIImage new] forState:UIControlStateDisabled];
    
    [self.beginScanButton addTarget:self action:@selector(didPressBeginScan:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *performScanButtonText = @"\uf029";
    [self.beginScanButton setTitle:performScanButtonText forState:UIControlStateNormal];
    [self.beginScanButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:27]];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.beginScanButton
                                                                        attribute:NSLayoutAttributeHeight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:nil
                                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                                       multiplier:1.0
                                                                         constant:60];
    
    
    [self.beginScanButton addConstraints:@[heightConstraint]];
    
    [self.view addSubview:self.beginScanButton];
}

- (void)setupButtonConstraints
{
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.beginScanButton
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.bottomLayoutGuide
                                                                        attribute:NSLayoutAttributeTop
                                                                       multiplier:1.0
                                                                         constant:-20];
    
    NSLayoutConstraint *leadingConstraint = [NSLayoutConstraint constraintWithItem:self.beginScanButton
                                                                         attribute:NSLayoutAttributeLeading
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view
                                                                         attribute:NSLayoutAttributeLeading
                                                                        multiplier:1.0
                                                                          constant:20];
    
    NSLayoutConstraint *trailingConstraint = [NSLayoutConstraint constraintWithItem:self.beginScanButton
                                                                          attribute:NSLayoutAttributeTrailing
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.view
                                                                          attribute:NSLayoutAttributeTrailing
                                                                         multiplier:1.0
                                                                           constant:-20];
    
    [self.view addConstraints:@[bottomConstraint,leadingConstraint,trailingConstraint]];
}

- (IBAction)didPressBeginScan:(id)sender
{
    [self startSession];
}

#pragma NSNotification Handlers

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self stopSession];
}

@end
