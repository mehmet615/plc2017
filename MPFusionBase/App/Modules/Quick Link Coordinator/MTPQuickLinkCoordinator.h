//
//  MTPQuickLinkCoordinator.h
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 2/1/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPQuickLinkCoordinator,MTPQuickLinksAppearanceManager,MTPMenuItem;

@protocol MTPQuickLinkCoordinatorDelegate <NSObject>
- (void)quickLinkCoordinator:(MTPQuickLinkCoordinator *)quickLinkCoordinator didSelectMenuItem:(MTPMenuItem *)menuItem;
@end

@interface MTPQuickLinkCoordinator : NSObject <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) id<MTPQuickLinkCoordinatorDelegate> delegate;
@property (strong, nonatomic) MTPQuickLinksAppearanceManager *appearanceManager;
@property (strong, nonatomic) UICollectionView *quickLinksCollectionView;
@property (strong, nonatomic) NSArray *quickLinks;

- (void)setupCollectionView:(UICollectionView *)collectionView inView:(UIView *)parentView;
- (void)loadQuickLinks:(NSArray *)quickLinks;
- (void)configureQuickLinksAppearance;
@end


#import "MTPThemeOptionsManager.h"

@interface MTPQuickLinksAppearanceManager : NSObject

@property (strong, nonatomic) NSString *eventName;
@property (strong, nonatomic) NSString *eventDetails;

@property (strong, nonatomic) UIColor *bellyEventNameColor;
@property (strong, nonatomic) UIColor *bellyEventDateColor;

@property (strong, nonatomic) UIColor *cellImageTintColor;
@property (strong, nonatomic) UIColor *cellTextColor;
@property (strong, nonatomic) UIColor *cellBackgroundColor;
@property (strong, nonatomic) UIColor *cellBorderColor;

@property (strong, nonatomic) NSString *backgroundTextureRemote;
@property (strong, nonatomic) NSString *backgroundImageRemote;
@property (strong, nonatomic) NSString *featuredImageRemote;
@property (strong, nonatomic) NSString *bellyImageRemote;
@property (strong, nonatomic) UIColor *bellyBackgroundColor;
@property (assign, nonatomic) BOOL showBelly;

@property (assign, nonatomic) MTPHomePageDisplayStyle displayStyle;

- (instancetype)initWithThemeOptions:(NSDictionary *)themeOptions;

@end


@interface MTPListLayoutDelegateHandler : NSObject <UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSArray *quickLinksData;
@end