//
//  MAMCustomPhotoUploadViewController.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/21/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMCustomPhotoUploadViewController.h"
#import "MAMCustomPhotoPickerViewController.h"
#import "MAMCustomPhotoFiltersViewController.h"
#import "MAMWebViewController.h"
#import "MTPWebViewController.h"

#import "User+Helpers.h"

#import "SIAlertView.h"
#import "AFNetworking.h"

#import "NSObject+EventDefaultsHelpers.h"
#import "UIView+AutoLayoutHelper.h"
#import "MAMStoryboardIdentifiers.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSString+MTPWebViewURL.h"
#import "UIColor+AppColors.h"

#import "MBProgressHUD.h"
#import "UIButton+MTPNavigationBar.h"
#import "NSURLSession+MTPCategory.h"
#import "UIViewController+NavigationItemSetup.h"
#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"
#import "MTPAppSettingsKeys.h"
#import "CHAFontAwesome.h"
#import "NSObject+MTPModelValidation.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MAMCustomPhotoUploadViewController () <MTPPhotoPickerDelegate, NSURLSessionTaskDelegate, UITextFieldDelegate>
@property (assign, nonatomic, getter = isUploading) BOOL uploading;

@property (weak, nonatomic) IBOutlet UILabel *choosePhotoLabel;
@property (weak, nonatomic) IBOutlet UILabel *choosePhotoInstruction;

@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, assign) NSUInteger uploadFileSize;

@property (strong, nonatomic) AVPlayer *audioVideoPlayer;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) UIButton *playButton;
@property (strong, nonatomic) AVAsset *selectedVideo;
@property (strong, nonatomic) NSURL *videoURL;
@property (strong, nonatomic) AVAssetExportSession *exportSession;
@end

@implementation MAMCustomPhotoUploadViewController

BOOL MTPPhotoTaggingEnabled = YES;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.uploading = NO;
    
    [self setupPhotoInstructionText];
    
    [self setupNavigationItem:[[self.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];
    [self configureWithThemeOptions:self.themeOptionsManager];
    
    [self setupPreviewPlayer];
}

- (void)setupPhotoInstructionText
{
    self.choosePhotoLabel.font = [UIFont fontWithName:@"FontAwesome" size:100.f];
    self.choosePhotoLabel.textColor = [UIColor blackColor];
    self.choosePhotoLabel.text = self.videoUpload ? [CHAFontAwesome icon:@"fa-video-camera"] : @"\uf083";
    
    NSString *instructionLabel = self.videoUpload ? @"Video" : @"Photo";
    NSString *title = [NSString stringWithFormat:@"Tap to Select %@\n",instructionLabel];
    NSString *details = @"\nAfter you select and upload your media file, you will be required to create a caption for it.";
    
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Lato-Bold" size:17]}];
    NSMutableAttributedString *mainText = [[NSMutableAttributedString alloc] initWithAttributedString:attributedTitle];
    
    if (self.profile == NO)
    {
        NSAttributedString *attributedDetails = [[NSAttributedString alloc] initWithString:details attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Lato-Regular" size:15]}];
        [mainText appendAttributedString:attributedDetails];
    }

    self.choosePhotoInstruction.attributedText = mainText;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
}

- (void)configureWithThemeOptions:(MTPThemeOptionsManager *)themeOptionsManager
{
    NSDictionary *themeOptions = themeOptionsManager.themeOptions;
    
    NSDictionary *colors = themeOptions[MPFUSION_colors];
    
    UIColor *color1 = [UIColor mtp_colorFromString:colors[MPFUSION_color25]];
    
    self.uploadButton.backgroundColor = color1 ? color1 : [UIColor lightGrayColor];
    
    for (UIButton *button in @[self.uploadButton,self.cancelButton])
    {
        button.layer.cornerRadius = 3.f;
        button.layer.masksToBounds = YES;
    }
    
    [self.themeOptionsManager loadRemoteTexture:[themeOptionsManager backgroundTexture] forView:self.view];
}

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
}

- (void)returnPrevious:(id)sender
{
    NSInteger indexOfCurrentViewController = [[self.navigationController viewControllers] indexOfObject:self];
    
    NSInteger index = MAX(indexOfCurrentViewController - 1,0);
    
    id possiblePhotoGallery = [[self.navigationController viewControllers] objectAtIndex:index];
    if ([possiblePhotoGallery isKindOfClass:[MAMWebViewController class]])
    {
        MAMWebViewController *photoGallery = (MAMWebViewController *)possiblePhotoGallery;
        [photoGallery refreshWebView:nil];
    }
    else if ([possiblePhotoGallery conformsToProtocol:@protocol(MTPWebViewRefreshable)] && [possiblePhotoGallery respondsToSelector:@selector(refreshWebView:)])
    {
        id <MTPWebViewRefreshable> webViewController = possiblePhotoGallery;
        [webViewController refreshWebView:nil];
    }
    
    [self.navigationController popViewControllerAnimated:true];
}

- (void)setupPreviewPlayer
{
    AVPlayer *avPlayer = [[AVPlayer alloc] init];
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:avPlayer];
    CGRect playerRect = CGRectMake(0, 0, CGRectGetWidth(self.selectedImageView.layer.frame), CGRectGetHeight(self.selectedImageView.layer.frame));
    playerLayer.frame = playerRect;
    [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [self.selectedImageView.layer addSublayer:playerLayer];
    
    self.audioVideoPlayer = avPlayer;
    self.playerLayer = playerLayer;
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    playButton.titleLabel.font = [UIFont fontWithName:@"FontAwesome" size:45];
    [playButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.7] forState:UIControlStateNormal];
    [playButton setTitle:[CHAFontAwesome icon:@"fa-play-circle-o"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(togglePlayerState:) forControlEvents:UIControlEventTouchUpInside];
    
    playButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.imagePostContainer addSubview:playButton];
    [self.imagePostContainer.superview addConstraint:[NSLayoutConstraint constraintWithItem:playButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.selectedImageView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.imagePostContainer.superview addConstraint:[NSLayoutConstraint constraintWithItem:playButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.selectedImageView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    playButton.hidden = YES;
    
    self.playButton = playButton;
}

#pragma mark - UI Event Methods
- (IBAction)pressedChoosePhoto:(UIButton *)sender
{
    MAMCustomPhotoPickerViewController *photoPicker = [self.storyboard instantiateViewControllerWithIdentifier:MAMCustomPhotoPickerViewControllerIdentifier];
    photoPicker.delegate = self;
    photoPicker.photoPickerCollectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundTexture"]];
    photoPicker.themeOptionsManager = self.themeOptionsManager;
    photoPicker.videoUpload = self.videoUpload;
    [self.navigationController pushViewController:photoPicker animated:YES];
}


- (IBAction)pressedUpload:(UIButton *)sender
{
    [self shouldUploadData:self.videoUpload];
}

- (void)shouldUploadData:(BOOL)videoUpload
{
    if (videoUpload)
    {
        if (self.audioVideoPlayer.rate)
        {
            [self togglePlayerState:nil];
        }
        [self prepareVideo];
    }
    else
    {
        NSData *imageData = UIImageJPEGRepresentation(self.selectedImageView.image, 0.65);
        DLog(@"\nimage dimensions %@\nimage filesize %@", NSStringFromCGSize(self.selectedImageView.image.size),@(imageData.length));
        
        NSNumber *userID = self.currentUser.user_id;
        NSString *imageUpload = nil;
        if (self.profile)
        {
            imageUpload = [NSString stringWithFormat:[NSString userProfile],userID];
        }
        else
        {
            imageUpload = [NSString stringWithFormat:[NSString userImage],userID];
        }
        [self uploadData:imageData url:imageUpload video:videoUpload];
    }
}

- (void)uploadData:(NSData *)uploadData url:(NSString *)url video:(BOOL)videoUpload
{
    if (self.isUploading)
    {
        SIAlertView *uploadInProgress = [[SIAlertView alloc] initWithTitle:@"Please wait a moment"
                                                                andMessage:@"Your last upload is still in process. Please wait a moment before uploading the next image!"];
        [uploadInProgress addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
        [uploadInProgress show];
    }
    else
    {
        self.uploading = YES;
        self.uploadFileSize = 0;
        
        self.progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:true];
        self.progressHUD.mode = MBProgressHUDModeAnnularDeterminate;
        self.progressHUD.label.text = @"Uploading";
        
        NSData *imageData = UIImageJPEGRepresentation(self.selectedImageView.image, 0.65);
        self.uploadFileSize = imageData.length;

        NSMutableURLRequest *imageUploadRequest = [NSURLSession defaultRequestMethod:@"POST" URL:url parameters:nil];
        [imageUploadRequest setHTTPBody:[self createUploadRequestData:imageData]];
        [imageUploadRequest setValue:@"multipart/form-data; boundary=-----------comMPBoundaryMarker" forHTTPHeaderField:@"Content-Type"];
        
        __weak __typeof(&*self)weakSelf = self;
        NSURLSessionConfiguration *imageUploadConfiguration = [[NSURLSession sharedSession] configuration];
        NSURLSession *uploadSession = [NSURLSession sessionWithConfiguration:imageUploadConfiguration
                                                                    delegate:self
                                                               delegateQueue:nil];
        
        [[uploadSession dataTaskWithRequest:imageUploadRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            id responseObject = [NSURLSession serializeJSONData:data response:response error:error];
            if ([responseObject isKindOfClass:[NSDictionary class]])
            {
                if ([[responseObject objectForKey:@"success"] boolValue])
                {
                    SIAlertView *successAlert = [[SIAlertView alloc] initWithTitle:@"Successful Upload" andMessage:@"Nice Pic - Thanks for sharing!"];
                    [successAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
                        [MBProgressHUD hideHUDForView:weakSelf.view animated:true];
                    }];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UILabel *checkMark = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
                        checkMark.font = [UIFont fontWithName:@"FontAwesome" size:45.f];
                        checkMark.textAlignment = NSTextAlignmentCenter;
                        checkMark.textColor = [UIColor greenColor];
                        checkMark.text = @"";
                        
                        weakSelf.progressHUD.customView = checkMark;
                        weakSelf.progressHUD.mode = MBProgressHUDModeCustomView;
                        NSString *uploadSuccessText;
                        if (MTPPhotoTaggingEnabled)
                        {
                            if (self.profile)
                            {
                                uploadSuccessText = @"Great profile picture!";
                            }
                            else
                            {
                                uploadSuccessText = @"Proceed to caption and tagging";
                            }
                        }
                        else
                        {
                            uploadSuccessText = @"Completed. Nice Pic!";
                        }
                        weakSelf.progressHUD.label.text = uploadSuccessText;
                        [weakSelf.progressHUD hideAnimated:true afterDelay:2.f];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            if (MTPPhotoTaggingEnabled)
                            {
                                NSNumber *uploadID = self.videoUpload ? [responseObject[@"videoID"] mtp_numberValue] : [responseObject[@"imageID"] mtp_numberValue];
                                [weakSelf loadTaggingWithUploadID:uploadID profile:self.profile];
                            }
                            else
                            {
                                [weakSelf returnPrevious:nil]; // used for NON-tagging situations
                            }
                        });
                    });
                    
                    DLog(@"\nupload response object %@", responseObject);
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showFailedUpload];
                        DLog(@"\nupload response object %@", responseObject);
                    });
                }
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf showFailedUpload];
                    DLog(@"\nupload response object %@", responseObject);
                });
            }
            
            weakSelf.uploading = NO;
        }] resume];
        
        [self pressedCancel:nil];
    }
}

- (void)loadTaggingWithUploadID:(NSNumber *)uploadID profile:(BOOL)profileUpload
{
    if (profileUpload)
    {
        [self returnPrevious:nil];
    }
    else
    {
        MAMWebViewController *webViewController = [[MAMWebViewController alloc] initWithNibName:@"MAMWebViewController" bundle:nil];
        
        webViewController.customURL = [NSString stringWithFormat:@"%@?%@=%@%@",
                                       [NSString mediaPostComment],
                                       self.videoUpload ? @"videoID" : @"imageID",
                                       uploadID,
                                       self.channel.length ? [NSString stringWithFormat:@"&channel=%@",self.channel] : @""];
        
        webViewController.currentUser = self.currentUser;
        
        [self.navigationController pushViewController:webViewController animated:YES];
    }
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend
{
    DLog(@"\nupload task progress %@ sent and expected %@", @(totalBytesSent),@(self.uploadFileSize));
    self.progressHUD.progress = totalBytesSent/(float)self.uploadFileSize;
}

- (NSData *)createUploadRequestData:(NSData *)imageData
{
    // Build the request body
    NSString *boundary = @"-----------comMPBoundaryMarker";
    NSMutableData *body = [NSMutableData data];
    if (imageData)
    {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo\"; filename=\"image.jpg\"\r\n"]
                          dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:imageData];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}

- (IBAction)pressedCancel:(UIButton *)sender
{
    self.selectedImageView.image = nil;
    self.choosePhotoContainer.hidden = NO;
    self.imagePostContainer.hidden= YES;
}

- (void)didChooseFilteredImage:(UIImage *)image
{
    if (image)
    {
        self.selectedImageView.image = image;
        self.imagePostContainer.hidden = NO;
        self.choosePhotoContainer.hidden = YES;
        [self.navigationController popToViewController:self animated:YES];
    }
}

- (void)didChooseImage:(UIImage *)image
{
    DLog(@"\ndebugging message %@",image);
}

- (void)didChooseVideo:(NSURL *)assetURL
{
    AVAsset *video = [AVAsset assetWithURL:assetURL];
    if (video)
    {
        self.videoURL = assetURL;
        self.selectedVideo = video;
        
        CGRect playerRect = CGRectMake(0, 0, CGRectGetWidth(self.selectedImageView.layer.frame), CGRectGetHeight(self.selectedImageView.layer.frame));
        self.playerLayer.frame = playerRect;
        
        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:assetURL];
        [self.audioVideoPlayer replaceCurrentItemWithPlayerItem:playerItem];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        
        [self didChooseFilteredImage:[UIImage new]];
        
        self.playerLayer.hidden = NO;
        self.playButton.hidden = NO;
        [self.playButton setTitle:[CHAFontAwesome icon:@"fa-play-circle"] forState:UIControlStateNormal];
        
        [self.imagePostContainer.superview bringSubviewToFront:self.playButton];
    }
}

- (void)itemDidFinishPlaying:(NSNotification *)notification
{
    [self.audioVideoPlayer seekToTime:kCMTimeZero];
    [self.playButton setTitle:[CHAFontAwesome icon:@"fa-play-circle"] forState:UIControlStateNormal];
}

- (void)togglePlayerState:(id)sender
{
    if (self.audioVideoPlayer.rate)
    {
        [self.audioVideoPlayer pause];
        [self.playButton setTitle:[CHAFontAwesome icon:@"fa-play-circle"] forState:UIControlStateNormal];
    }
    else
    {
        [self.audioVideoPlayer play];
        [self.playButton setTitle:[CHAFontAwesome icon:@"fa-pause-circle"] forState:UIControlStateNormal];
    }
}

- (void)prepareVideo
{
    MBProgressHUD *compressionHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    compressionHUD.label.text = @"Compressing Video";
    compressionHUD.progress = 0;
    
    AVAsset *videoAsset = self.selectedVideo;
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:videoAsset presetName:AVAssetExportPresetMediumQuality];
    self.exportSession = exportSession;
    exportSession.outputFileType = AVFileTypeMPEG4;
    
    NSURL *outputURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    outputURL = [outputURL URLByAppendingPathComponent:[NSString stringWithFormat:@"%ld.%@",(long)[NSDate timeIntervalSinceReferenceDate],self.videoURL.pathExtension]];
    exportSession.outputURL = outputURL;
    
    __weak typeof(&*self)weakSelf = self;
    __weak AVAssetExportSession *weakSession = exportSession;
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           switch (weakSession.status)
                           {
                               case AVAssetExportSessionStatusExporting:
                               {
                                   compressionHUD.progress = weakSession.progress;
                                   break;
                               }
                               case AVAssetExportSessionStatusCompleted:
                               {
                                   compressionHUD.progress = 1;
                                   compressionHUD.label.text = @"Completed";
                                   [compressionHUD hideAnimated:YES afterDelay:0.5];
                                   [weakSelf startUpload:outputURL];
                                   break;
                               }
                               case AVAssetExportSessionStatusCancelled:
                               case AVAssetExportSessionStatusFailed:
                               default:
                               {
                                   compressionHUD.label.text = @"Compression Failed";
                                   [compressionHUD hideAnimated:YES afterDelay:0.5];
                                   DLog(@"\nsession %@ -- error %@",@(weakSession.status),weakSession.error);
                                   if ([[NSFileManager defaultManager] fileExistsAtPath:outputURL.path])
                                   {
                                       NSError *removalError = nil;
                                       if ([[NSFileManager defaultManager] removeItemAtURL:outputURL error:&removalError])
                                       {
                                           [weakSelf prepareVideo];
                                       }
                                       else
                                       {
                                           DLog(@"\nremoval error %@",removalError);
                                       }
                                   }
                                   break;
                               }
                           }
                       });
    }];
}

- (void)startUpload:(NSURL *)videoLocalURL
{
    [self uploadData:[NSData dataWithContentsOfURL:videoLocalURL] url:[NSString stringWithFormat:[NSString userVideo],self.currentUser.user_id] video:YES];
}

#pragma mark - Helper Methods
- (void)showFailedUpload
{
    SIAlertView *failedAlert = [[SIAlertView alloc] initWithTitle:@"Upload Failed" andMessage:@"There was a problem with your upload. Please make sure you are connected to the network and upload the image again."];
    [failedAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
    
    UILabel *failed = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 37, 37)];
    failed.font = [UIFont fontWithName:@"FontAwesome" size:45.f];
    failed.textColor = [UIColor redColor];
    failed.text = @"";
    
    self.progressHUD.customView = failed;
    self.progressHUD.mode = MBProgressHUDModeCustomView;
    self.progressHUD.label.text = @"Upload failed! Try again!";
    [self.progressHUD hideAnimated:true afterDelay:2.f];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
