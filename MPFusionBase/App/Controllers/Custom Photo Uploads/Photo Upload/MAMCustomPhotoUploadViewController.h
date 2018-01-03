//
//  MAMCustomPhotoUploadViewController.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/21/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

@class User, MTPThemeOptionsManager;

@interface MAMCustomPhotoUploadViewController : UIViewController <MTPNavigationItemCustomizable>

@property (strong, nonatomic) MTPThemeOptionsManager *themeOptionsManager;
@property (strong, nonatomic) NSString *channel;
@property (assign, nonatomic) BOOL profile;
@property (assign, nonatomic) BOOL videoUpload;

@property (weak, nonatomic) IBOutlet UIView *contentContainer;

@property (nonatomic, strong) User *currentUser;

#pragma mark - Photography
@property (weak, nonatomic) IBOutlet UIView *imageContainer;

#pragma mark Choosing the Photo
@property (weak, nonatomic) IBOutlet UIView *choosePhotoContainer;
@property (weak, nonatomic) IBOutlet UIButton *choosePhotoButton;

#pragma mark Posting the Photo
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *imagePostContainer;

@property (weak, nonatomic) IBOutlet UIButton *uploadButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;
@property (weak, nonatomic) id<MTPMainMenuTogglable> menuToggleDelegate;

#pragma mark - Method Declarations
- (IBAction)pressedChoosePhoto:(UIButton *)sender;
- (IBAction)pressedUpload:(UIButton *)sender;
- (IBAction)pressedCancel:(UIButton *)sender;

@end
