//
//  MTPGeneralInfoViewController.h
//  MPFusionBaseProject
//
//  Created by Admin on 8/20/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

@class MTPNavigationRouter, MTPSessionManager, User, MTPThemeOptionsManager;

@interface MTPGeneralInfoViewController : UIViewController <MTPNavigationItemCustomizable>


@property (weak, nonatomic) IBOutlet UICollectionView *generalInfoCollectionView;
@property (weak, nonatomic) IBOutlet UIView *generalInfoHeaderContainer;
@property (weak, nonatomic) IBOutlet UILabel *headerTitleLabel;

@property (nonatomic, weak) MTPNavigationRouter *navigationRouter;
@property (weak, nonatomic) MTPThemeOptionsManager *themeOptionsManager;
@property (weak, nonatomic) MTPSessionManager *sessionManager;
@property (weak, nonatomic) User *currentUser;

@property (weak, nonatomic) id <MTPMainMenuTogglable> menuToggler;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;

@end
