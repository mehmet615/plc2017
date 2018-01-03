//
//  MAMBaseViewController.h
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 9/27/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+MTPAppearanceHelpers.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "EventKeys.h"
#import "MTPEditProfilePresenter.h"

#import "MTPMainMenuTogglable.h"
#import "MTPSideMenuTogglable.h"

@class MAMMainMenuViewController,MTPEditProfilePresenter,User,MDMyConnectionManager,MTPNavigationRouter,MTPRightNavigationViewController,MTPNearbyCardPresenter,MTPMatchCoordinator;

@interface MAMBaseViewController : UIViewController <MTPEditProfileDisplayable, MTPEditProfileDelegate, MTPMainMenuTogglable, MTPSideMenuTogglable>

@property (nonatomic, strong) MTPNavigationRouter *navigationRouter;
@property (strong, nonatomic) MTPMatchCoordinator *matchCoordinator;

@property (nonatomic, strong) MAMMainMenuViewController *mainMenuController;
@property (strong, nonatomic) MTPRightNavigationViewController *rightMenu;

@property (nonatomic, strong) UIViewController *contentViewController;
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) NSLayoutConstraint *contentContainerLeading;

@property (nonatomic, strong) MTPEditProfilePresenter *editProfilePresenter;
@property (strong, nonatomic) MTPNearbyCardPresenter *nearbyCardPresenter;

@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) MDMyConnectionManager *connectionManager;

- (void)topViewControllerShouldToggleMenu:(id)sender;
- (void)addMainMenu:(MAMMainMenuViewController *)mainMenu;
@end




