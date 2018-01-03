//
//  MTPMainMenuHeaderView.h
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/17/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPHeaderSearchHandler, MTPMainMenuHeaderView;

@protocol MTPMainMenuHeaderDelegate <NSObject>
- (void)mainMenuHeader:(MTPMainMenuHeaderView *)headerView didSearch:(NSString *)searchQuery;
@end

@interface MTPMainMenuHeaderView : UIView

@property (weak, nonatomic) id <MTPMainMenuHeaderDelegate> delegate;

// search bar area
@property (weak, nonatomic) IBOutlet UIView *searchContainer;
@property (weak, nonatomic) IBOutlet UIView *searchBarContainer;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIImageView *searchIcon;
@property (weak, nonatomic) IBOutlet UITextField *searchField;
@property (strong, nonatomic) IBOutlet MTPHeaderSearchHandler *searchHandler;

// event information section
@property (weak, nonatomic) IBOutlet UIView *eventInformationContainer;
@property (weak, nonatomic) IBOutlet UIImageView *sideBarImage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sideBarImageHeight;
@property (weak, nonatomic) IBOutlet UIView *eventTextDetailsContainer;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UIView *eventDetailsContainer;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;

// navigation divider section
@property (weak, nonatomic) IBOutlet UIView *navigationDividerContainer;
@property (weak, nonatomic) IBOutlet UILabel *navigationDividerLabel;


// method declarations
- (void)configureWithTheme:(NSDictionary *)themeOptions;
- (void)loadSideBarImage:(UIImage *)image;

@end


@protocol MTPHeaderSearchDelegate <NSObject>
- (void)searchHandler:(MTPHeaderSearchHandler *)searchHandler didSearch:(NSString *)searchQuery;
@end

@interface MTPHeaderSearchHandler : NSObject <UITextFieldDelegate>
@property (weak, nonatomic) id <MTPHeaderSearchDelegate> delegate;
@end