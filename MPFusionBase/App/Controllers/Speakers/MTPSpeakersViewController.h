//
//  MTPAttendeeListViewController.h
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 8/8/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

@class MTPNavigationRouter, MTPSessionManager, User, MTPThemeOptionsManager;

@interface MTPAttendeeListViewController : UIViewController <MTPNavigationItemCustomizable>

@property (weak, nonatomic) IBOutlet UICollectionView *sectionSelectionCollectionView;
@property (weak, nonatomic) IBOutlet UIView *attendeeListHeaderContainer;
@property (weak, nonatomic) IBOutlet UILabel *attendeeListHeader;
@property (weak, nonatomic) IBOutlet UICollectionView *attendeeListCollectionView;

- (void)loadData:(NSArray *)attendeeData;


@property (nonatomic, weak) MTPNavigationRouter *navigationRouter;
@property (weak, nonatomic) MTPThemeOptionsManager *themeOptionsManager;
@property (weak, nonatomic) MTPSessionManager *sessionManager;
@property (weak, nonatomic) User *currentUser;

@property (weak, nonatomic) id <MTPMainMenuTogglable> menuToggler;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;
- (void)setupLeftBarButton;
@end
