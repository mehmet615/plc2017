//
//  MAMCustomPhotoFiltersViewController.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/21/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPThemeOptionsManager;

@protocol MTPFilterSelectionDelegate <NSObject>
@optional
-(void)didChooseFilteredImage:(UIImage*)image;
@end

@interface MAMCustomPhotoFiltersViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) id <MTPFilterSelectionDelegate> delegate;

@property (strong, nonatomic) MTPThemeOptionsManager *themeOptionsManager;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIImageView *filteredImage;
@property (strong, nonatomic) UIImage *originalImage;
@property (weak, nonatomic) IBOutlet UIButton *selectPhoto;

@property (weak, nonatomic) IBOutlet UIImageView *upArrow;
@property (weak, nonatomic) IBOutlet UIImageView *downArrow;

- (IBAction)didSelectPhoto:(id)sender;
- (void)setupImageEditorView;
@end
