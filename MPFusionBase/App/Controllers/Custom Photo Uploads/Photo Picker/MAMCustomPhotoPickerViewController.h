//
//  MAMCustomPhotoPickerViewController.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/21/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPThemeOptionsManager;

@protocol MTPPhotoPickerDelegate <NSObject>
-(void)didChooseImage:(UIImage*)image;
@optional
-(void)didChooseVideo:(NSURL *)assetURL;
@end

@interface MAMCustomPhotoPickerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *photoPickerCollectionView;
@property (weak, nonatomic) id <MTPPhotoPickerDelegate> delegate;

@property (assign, nonatomic) BOOL videoUpload;

@property (strong, nonatomic) MTPThemeOptionsManager *themeOptionsManager;

@end
