//
//  MAMQuickLinksViewController.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/10/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"
#import "MTPAttendeeListCoordinator.h"

@class MTPMenuItem,MTPNavigationRouter,MTPNearbyCoordinator,MTPMatchCoordinator;

@interface MAMQuickLinksViewController : UIViewController <MTPNavigationItemCustomizable>
@property (nonatomic, strong) MTPNavigationRouter *navigationRouter;
@property (nonatomic, strong) NSArray *quickLinks;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

@property (weak, nonatomic) IBOutlet UIView *sectionHeaderContainer;
@property (weak, nonatomic) IBOutlet UIImageView *headerBackgroundImage;

@property (weak, nonatomic) IBOutlet UIView *bellyContainer;
@property (weak, nonatomic) IBOutlet UIImageView *bellyImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bellyHeight;

@property (weak, nonatomic) IBOutlet UICollectionView *quickLinksCollectionView;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;

@property (weak, nonatomic) id <MTPMainMenuTogglable> menuToggler;

@property (strong, nonatomic) MTPMatchCoordinator *matchCoordinator;
@property (strong, nonatomic) MTPAttendeeListCoordinator *attendeeListCoordinator;
@property (strong, nonatomic) MTPNearbyCoordinator *nearbyCoordinator;
@property (weak, nonatomic) IBOutlet UILabel *noAttendeesLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *attendeesCollectionView;
@property (strong, nonatomic) NSArray *matches;
@property (strong, nonatomic) NSTimer *nearbyUpdateTimer;

- (void)setupLeftBarButton;

- (void)reloadAppearance;
- (void)updateQuickLinks:(NSNotification *)notification;

@end