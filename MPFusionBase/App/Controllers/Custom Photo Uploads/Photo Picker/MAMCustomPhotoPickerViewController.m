//
//  MAMCustomPhotoPickerViewController.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/21/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMCustomPhotoPickerViewController.h"
#import "UIViewController+NavigationItemSetup.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import "MTPPhotoPickerCell.h"
#import "MAMCustomPhotoFiltersViewController.h"
//#import "MDPhotoViewController.h"
#import "EventKeys.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "UIButton+MTPNavigationBar.h"
#import "MTPThemeOptionsManager.h"
#import "MTPAppSettingsKeys.h"
#import "SIAlertView.h"
#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>

@interface MAMCustomPhotoPickerViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) NSMutableArray *assetsArray;
@property (nonatomic, strong) ALAssetsGroup *assetGroup;
@property (strong, nonatomic) ALAssetsLibrary *library;
@property (nonatomic, strong) UIImagePickerController *cameraPicker;

-(void)reloadPhotos;
@end

@implementation MAMCustomPhotoPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.assetGroup = [[ALAssetsGroup alloc] init];
    
    if ([self.userDefaults boolForKey:kPhotoPickerFirstLoad])
    {
        [self performSelectorInBackground:@selector(reloadPhotos) withObject:nil];
    }
    else
    {
        [self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    }
    
    [self setupNavigationItem:[[self.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];

    [self.themeOptionsManager loadRemoteTexture:[self.themeOptionsManager backgroundTexture] forView:self.photoPickerCollectionView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (![self.userDefaults boolForKey:kPhotoPickerFirstLoad])
    {
        [self performSelectorInBackground:@selector(reloadPhotos) withObject:nil];
    }
    else
    {
        [self performSelectorInBackground:@selector(preparePhotos) withObject:nil];
    }
    
    [[self navigationItem] setTitleView:[UIButton navigationBarLogo:CGRectGetHeight(self.navigationController.navigationBar.frame)]];
    [[self navigationItem] setLeftBarButtonItem:[UIButton toggleMainMenuButton:@{@"imageName": @"backIcon"} target:self selector:@selector(toggleMenu:)]];
}

- (void)dealloc {
    //    DLog(@"\nmdphotopickerviewcontroller dealloc");
    
    self.assetsArray = nil;
    self.assetGroup = nil;
    self.library = nil;
    self.cameraPicker = nil;
}

- (void)toggleMenu:(id)sender
{
    if ([self navigationController])
    {
        [[self navigationController] popViewControllerAnimated:true];
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UIImage class]])
    {
        if ([segue.destinationViewController isKindOfClass:[MAMCustomPhotoFiltersViewController class]])
        {
            MAMCustomPhotoFiltersViewController *filterSelector = (MAMCustomPhotoFiltersViewController*)segue.destinationViewController;
            [filterSelector setDelegate:self.delegate];
            [filterSelector setOriginalImage:sender];
            filterSelector.themeOptionsManager = self.themeOptionsManager;
            [filterSelector setupImageEditorView];
        }
    }
}


#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetsArray.count + 1;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MTPPhotoPickerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"photoPickerCell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.thumbnail.image = nil;
        cell.cameraLabel.hidden = false;
    } else {
        if (self.assetsArray.count > 0)
        {
            cell.cameraLabel.hidden = true;
            ALAsset *asset = [self.assetsArray objectAtIndex:indexPath.row - 1];
            cell.thumbnail.image = [UIImage imageWithCGImage:asset.thumbnail];
            cell.thumbnail.highlightedImage = [UIImage imageWithCGImage:asset.thumbnail];
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        [self openCamera];
    }
    else
    {
        ALAsset *asset = [self.assetsArray objectAtIndex:indexPath.row - 1];
        ALAssetRepresentation *assetRep = [asset defaultRepresentation];
        if (self.videoUpload)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didChooseVideo:)])
            {
                [self.delegate didChooseVideo:assetRep.url];
            }
            else
            {
                DLog(@"delegate check failed %@",self.delegate);
            }
        }
        else
        {
            CGImageRef imgRef = [assetRep fullResolutionImage];
            ALAssetOrientation orientation = [assetRep orientation];
            UIImage *img = [UIImage imageWithCGImage:imgRef scale:1.0f orientation:(NSInteger)orientation];
            
            [self performSegueWithIdentifier:@"segueAddFilter" sender:img];
        }
    }
}

- (void)openCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        if (self.videoUpload)
        {
            self.cameraPicker.mediaTypes = [NSArray arrayWithObject:@"public.movie"];
            self.cameraPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        }
        
        if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusNotDetermined || [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized)
        {
            [self presentViewController:self.cameraPicker animated:NO completion:nil];
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
    } else {
        DLog(@"\ncamera isnt available");
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self.cameraPicker dismissViewControllerAnimated:NO completion:NULL];
    if (self.videoUpload)
    {
        NSURL *capturedImageURL = info[UIImagePickerControllerMediaURL];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didChooseVideo:)])
        {
            [self.delegate didChooseVideo:capturedImageURL];
        }
        else
        {
            DLog(@"delegate check failed %@",self.delegate);
        }
    }
    else
    {
        UIImage *originalImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        UIImageWriteToSavedPhotosAlbum(originalImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        [self performSegueWithIdentifier:@"segueAddFilter" sender:[self scaleAndRotateImage:originalImage withSize:CGSizeMake(1024,MAXFLOAT)]];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self.cameraPicker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    DLog(@"didFinishSavingWithError is %@\n contextInfo is %@",error,contextInfo);
    [self reloadPhotos];
}

#pragma mark - Helper Methods
- (void)reloadPhotos
{
    [self.assetsArray removeAllObjects];
    self.assetsArray = [NSMutableArray array];
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    self.library = assetLibrary;
    
    // Load Albums into assetGroups
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            
            // Group enumerator Block
            void (^assetGroupEnumerator)(ALAssetsGroup *, BOOL *) = ^(ALAssetsGroup *group, BOOL *stop)
            {
                if (group == nil) {
                    return;
                }
                
                if (self.videoUpload)
                {
                    [group setAssetsFilter:[ALAssetsFilter allVideos]];
                }
                else
                {
                    [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                }
                
                //                DLog(@"group is %@",group);
                // added fix for camera albums order
                NSUInteger nType = [[group valueForProperty:ALAssetsGroupPropertyType] intValue];
                if (nType == ALAssetsGroupSavedPhotos) {
                    //                    DLog(@"camera roll");
                    self.assetGroup = group;
                }
                self.title = [self.assetGroup valueForProperty:ALAssetsGroupPropertyName];
                [self.assetsArray removeAllObjects];
                [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result == nil) {
                        return;
                    }
                    [self.assetsArray insertObject:result atIndex:0];
                }];
                //                DLog(@"self.assetsArray.count is %lu",self.assetsArray.count);
                [self.photoPickerCollectionView reloadData];
            };
            
            // Group Enumerator Failure Block
            void (^assetGroupEnumberatorFailure)(NSError *) = ^(NSError *error) {
                
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Album Error: %@ - %@", [error localizedDescription], [error localizedRecoverySuggestion]] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                
                DLog(@"A problem occured %@", [error description]);
            };

            
            // Enumerate Albums
            if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined || [ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized)
            {
                [self.library enumerateGroupsWithTypes:ALAssetsGroupAll
                                            usingBlock:assetGroupEnumerator
                                          failureBlock:assetGroupEnumberatorFailure];
            }
            else
            {
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Problem Accessing Images" andMessage:@"Please select \'Settings\' to enter the Settings app and ensure \'Photos\' is enabled (green), or \'Cancel\' to continue."];
                [alertView addButtonWithTitle:@"Settings" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                }];
                [alertView addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeCancel handler:nil];
                [alertView show];
            }
        }
    });
}

- (void)preparePhotos
{
    @autoreleasepool {
        self.assetsArray = [NSMutableArray array];
        [self.assetsArray removeAllObjects];
        [self.assetGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result == nil) {
                return;
            }
            [self.assetsArray insertObject:result atIndex:0];
        }];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.photoPickerCollectionView reloadData];
        });
    }
}

- (IBAction)cancelPhotoPick:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getters
- (UIImagePickerController *)cameraPicker{
    if (_cameraPicker == nil) {
        _cameraPicker = [[UIImagePickerController alloc]init];
    }
    _cameraPicker.allowsEditing = NO;
    _cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    _cameraPicker.delegate = self;
    return _cameraPicker;
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image withSize:(CGSize)size
{
    CGFloat  maxWidth=size.width;
    CGFloat  maxHeight=size.height;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    if (width > maxWidth || height > maxHeight) {
        CGFloat maxRatio = maxWidth/maxHeight;
        CGFloat ratio = width/height;
        if (ratio > maxRatio) {
            bounds.size.width = maxWidth;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = maxHeight;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:NSLocalizedString(@"Invalid image orientation", @"")];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end
