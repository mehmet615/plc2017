//
//  MAMCustomPhotoFiltersViewController.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/21/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMCustomPhotoFiltersViewController.h"
#import "UIViewController+NavigationItemSetup.h"

#import "MTPFilterSelectionCell.h"
#import "UIButton+MTPNavigationBar.h"
#import "UIColor+AppColors.h"
#import "MTPAppSettingsKeys.h"

#import "MBProgressHUD.h"
#import "MTPThemeOptionsManager.h"
#import "TOCropViewController.h"

@interface MDFilterSelectionHeader : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@end
@implementation MDFilterSelectionHeader
@end

@interface MDFilterSelectionFooter : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIImageView *footerImage;
@end
@implementation MDFilterSelectionFooter
@end

@interface MAMCustomPhotoFiltersViewController () <TOCropViewControllerDelegate>
@property (strong, nonatomic) NSArray *filterNames;
@property (strong, nonatomic) NSMutableArray *filteredImageThumbnails;
@property (strong, nonatomic) TOCropViewController *cropViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewBottom;
@property (assign, nonatomic) BOOL animatingFilterSelection;
@property (weak, nonatomic) IBOutlet UIButton *toggleFiltersButton;
@end

@implementation MAMCustomPhotoFiltersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = [UIColor whiteColor];
    
    self.filterNames = @[@"CIPhotoEffectChrome",
                         @"CIPhotoEffectFade",
                         @"CIPhotoEffectInstant",
                         @"CIPhotoEffectMono",
                         @"CIPhotoEffectNoir",
                         @"CIPhotoEffectProcess",
                         @"CIPhotoEffectTonal",
                         @"CIPhotoEffectTransfer"];
    self.filteredImageThumbnails = [NSMutableArray new];
    
//    [self loadFilterThumbnails];
    
    [self configureWithThemeOptionsManager:self.themeOptionsManager];
    
    [self setupNavigationItem:[[self.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];
    
    self.selectPhoto.layer.cornerRadius = 3.f;
    self.selectPhoto.layer.masksToBounds = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self navigationItem] setTitleView:nil];
    [[self navigationItem] setLeftBarButtonItem:[UIButton toggleMainMenuButton:@{@"imageName": @"backIcon"} target:self selector:@selector(toggleMenu:)]];
}

- (void)setupImageEditorView
{
    [self setupImageEditorView:self.originalImage];
    [self loadFilterThumbnails];
}

- (void)setupImageEditorView:(UIImage *)image
{
    [self.cropViewController.view removeFromSuperview];
    self.cropViewController = nil;
    
    TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:image];
    cropViewController.delegate = self;
    cropViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view insertSubview:cropViewController.view atIndex:0];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[view]|" options:0 metrics:nil views:@{@"view":cropViewController.view}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:@{@"view":cropViewController.view}]];
    
    self.cropViewController = cropViewController;
}

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChooseFilteredImage:)])
    {
        UIImage *bigImage = image;
        
        CGSize targetSize;
        
        if (bigImage.size.height > bigImage.size.width)
        {
            targetSize = CGSizeMake(MAXFLOAT, 1024);
        }
        else
        {
            targetSize = CGSizeMake(1024, MAXFLOAT);
        }
        UIImage *filteredImage = [self scaleAndRotateImage:bigImage withSize:targetSize];
        [self.delegate didChooseFilteredImage:filteredImage];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)cropViewController:(TOCropViewController *)cropViewController didFinishCancelled:(BOOL)cancelled
{
    [self toggleMenu:nil];
}

- (void)loadFilterThumbnails
{
    self.filteredImage.image = self.originalImage;
    
    MBProgressHUD *loadingFilters = [MBProgressHUD showHUDAddedTo:self.collectionView animated:YES];
    loadingFilters.label.text = @"Loading Filters";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (self.originalImage && self.filteredImageThumbnails.count < 1)
        {
            UIImage *thumbnail = [self createThumbnail:self.originalImage];
            [self.filteredImageThumbnails addObject:[thumbnail copy]];
            
            __weak __typeof(&*self)weakSelf = self;
            [self.filterNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [weakSelf.filteredImageThumbnails addObject:[weakSelf applyFilter:obj onImage:thumbnail]];
            }];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:self.collectionView animated:true];
            [self.collectionView reloadData];
        });
    });
}

- (void)toggleMenu:(id)sender
{
    if ([self navigationController])
    {
        [[self navigationController] popViewControllerAnimated:true];
    }
}

- (void)configureWithThemeOptionsManager:(MTPThemeOptionsManager *)themeOptionsManager
{
    [self.themeOptionsManager loadRemoteTexture:[self.themeOptionsManager backgroundTexture] forView:self.view];
    
    UIColor *color1 = [UIColor mtp_colorFromString:[self.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color25]];
    
    self.selectPhoto.backgroundColor = color1 ? color1 : [UIColor darkGrayColor];
}

#pragma mark - Delegation Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.filteredImageThumbnails.count > 2 ? self.filterNames.count+1 : 0;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MTPFilterSelectionCell *cell = (MTPFilterSelectionCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"filterSelection" forIndexPath:indexPath];
    NSArray *filters = @[@"Original",@"Chrome",@"Fade",@"Instant",@"Mono",@"Noir",@"Process",@"Tonal",@"Transfer"];
    cell.filterName.text = filters[indexPath.row];
    cell.filterThumbnail.image = self.filteredImageThumbnails[indexPath.row];
    cell.layer.cornerRadius = 5.0f;
    cell.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.layer.shadowOffset = CGSizeMake(2, 2);
    cell.layer.shadowRadius = 5;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MBProgressHUD *applyFilterHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    applyFilterHUD.label.text = @"Applying Filter";
    
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0), ^{
        UIImage *image = self.originalImage;
        if (indexPath.row == 0)
        {
            image = self.originalImage;
        }
        else
        {
            CGSize bigImageSize = self.originalImage.size;
            CIImage *ciImage = [[CIImage alloc] initWithImage:[self scaleAndRotateImage:image withSize:bigImageSize]];
            CIFilter *filter = [CIFilter filterWithName:self.filterNames[indexPath.row-1]
                                          keysAndValues:kCIInputImageKey, ciImage, nil];
            [filter setDefaults];
            
            CIContext *context = [CIContext contextWithOptions:nil];
            CIImage *outputImage = [filter outputImage];
            image = [UIImage imageWithCGImage:[context createCGImage:outputImage fromRect:outputImage.extent]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [applyFilterHUD hideAnimated:YES];
            [self setupImageEditorView:image];
            [self toggleFiltersHeight:nil];
        });
    });
}

#pragma mark UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat verticalOffset = scrollView.contentOffset.y;
    CGFloat downArrowBoundary = scrollView.contentSize.height - (scrollView.frame.size.height + 200);
    if (verticalOffset > 80) {
        self.upArrow.hidden = NO;
        if (verticalOffset > downArrowBoundary) {
            self.downArrow.hidden = YES;
        } else {
            self.downArrow.hidden = NO;
        }
    } else {
        self.upArrow.hidden = YES;
        self.downArrow.hidden = NO;
    }
}

#pragma mark - UIEvents

#pragma mark - Helper Methods

- (UIImage*)createThumbnail:(UIImage*)largeImage {
    return [self scaleAndRotateImage:largeImage withSize:CGSizeMake(150, 200)];
}

- (UIImage*)applyFilter:(NSString*)filterName onImage:(UIImage*)thumbnail {
    
    UIImage *filteredThumbnail;
    
    if (filterName) {
        CIImage *image = [[CIImage alloc] initWithImage:thumbnail];
        CIFilter *filter = [CIFilter filterWithName:filterName
                                      keysAndValues:kCIInputImageKey, image, nil];
        [filter setDefaults];
        
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *outputImage = [filter outputImage];
        CGImageRef cgImage = [context createCGImage:outputImage
                                           fromRect:[outputImage extent]];
        
        filteredThumbnail = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
    }
    
    return filteredThumbnail;
}

- (IBAction)didSelectPhoto:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChooseFilteredImage:)])
    {
        UIImage *bigImage = self.filteredImage.image;
        
        CGSize targetSize;
        
        if (bigImage.size.height > bigImage.size.width)
        {
            targetSize = CGSizeMake(MAXFLOAT, 1024);
        }
        else
        {
            targetSize = CGSizeMake(1024, MAXFLOAT);
        }
        UIImage *filteredImage = [self scaleAndRotateImage:bigImage withSize:targetSize];
        [self.delegate didChooseFilteredImage:filteredImage];
    }
}

- (IBAction)toggleFiltersHeight:(UIButton *)sender
{
    if (self.animatingFilterSelection == NO)
    {
        self.animatingFilterSelection = YES;
        
        CGFloat height = 0;
        NSString *text;
        if (self.collectionViewBottom.constant == 0)
        {
            height = 150;
            text = @"\uf139";
        }
        else
        {
            height = 0;
            text = @"\uf13a";
        }
        [self.view layoutIfNeeded];
        self.collectionViewBottom.constant = height;
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.toggleFiltersButton setTitle:text forState:UIControlStateNormal];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.animatingFilterSelection = NO;
        }];
    }
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
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    
    //    CGContextRelease(context);
    
    return imageCopy;
}

@end
