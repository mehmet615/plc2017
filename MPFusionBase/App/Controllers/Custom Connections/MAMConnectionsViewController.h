//
//  MAMConnectionsViewController.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/13/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPDataSource.h"
#import "MTPViewControllerDataSource.h"
#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

@class User,MTPNavigationRouter,MDBeaconManager;

@interface MAMConnectionsViewController : UIViewController <MTPViewControllerDataSourceDelegate, MTPNavigationItemCustomizable>

@property (nonatomic, strong) IBOutlet MTPDataSource *dataSource;
@property (nonatomic, strong) User *currentUser;
@property (nonatomic, strong) NSManagedObjectContext *rootObjectContext;
@property (nonatomic, strong) MDBeaconManager *beaconManager;
@property (nonatomic, strong) MDMyConnectionManager *connectionManager;
@property (nonatomic, strong) MTPSponsorManager *sponsorManager;

@property (weak, nonatomic) IBOutlet UIView *connectionViewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *headerBackground;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *connectionDescriptionTextView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;
@property (weak, nonatomic) id<MTPMainMenuTogglable> menuToggleDelegate;

@property (nonatomic, strong) MTPViewControllerDataSource *configurationDataSource;

- (MTPDataSource *)setupDataSource;

@end

@interface MAMConnectionsViewController (CollectionViewCategories) <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, MTPCellLayoutDelegate>

@end