//
//  MTPRightNavigationViewController.h
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/21/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPRightNavigationViewController,MTPThemeOptionsManager, User, WKProcessPool, WKWebView;

@protocol MTPSideMenuDelegate <NSObject>

- (void)sideMenu:(MTPRightNavigationViewController *)sideMenu didEditProfile:(id)sender;
- (void)toggleSideMenu:(id)sender;

@end

@interface MTPRightNavigationViewController : UIViewController

@property (weak, nonatomic) id <MTPSideMenuDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *headerContainer;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *headerSeparator;
@property (weak, nonatomic) IBOutlet UIButton *editProfileButton;
@property (strong, nonatomic) WKProcessPool *processPool;

@property (strong, nonatomic) WKWebView *userProfileWebView;

- (void)configureWithUserDetails:(User *)currentUser;
- (void)reloadWithUserID:(NSNumber *)userID;

- (void)configureWithThemeOptions:(MTPThemeOptionsManager *)themeOptionsManager;
- (void)loadBackgroundTexture:(MTPThemeOptionsManager *)themeOptionsManager;
- (void)loadProfileImage:(NSString *)profileImageRemoteURL;

- (IBAction)pressedEditProfile:(id)sender;

@end
