//
//  MTPSpeakersViewController.h
//
//  Created by MeetingPlay on 8/8/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

@class MTPNavigationRouter, MTPSessionManager, User, MTPThemeOptionsManager;

@interface MTPSpeakersViewController : UIViewController <MTPNavigationItemCustomizable>

@property (weak, nonatomic) IBOutlet UICollectionView *sectionSelectionCollectionView;
@property (weak, nonatomic) IBOutlet UIView *speakerListHeaderContainer;
@property (weak, nonatomic) IBOutlet UILabel *speakerListHeader;
@property (weak, nonatomic) IBOutlet UICollectionView *speakerListCollectionView;

- (void)loadData:(NSArray *)speakerData;


@property (nonatomic, weak) MTPNavigationRouter *navigationRouter;
@property (weak, nonatomic) MTPThemeOptionsManager *themeOptionsManager;
@property (weak, nonatomic) MTPSessionManager *sessionManager;
@property (weak, nonatomic) User *currentUser;

@property (weak, nonatomic) id <MTPMainMenuTogglable> menuToggler;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;
- (void)setupLeftBarButton;
@end
