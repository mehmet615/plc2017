//
//  MAMMainMenuViewController.h
//  MarriottMasters
//
//  Created by MeetingPlay on 4/10/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPMainMenuHeaderView.h"
#import "MAMMainFooterView.h"

#import <UIKit/UIKit.h>

#import "MTPMenuItem.h"
#import "MTPNavigationMenuLoader.h"
#import "MAMBaseViewController.h"

@class MAMMainMenuViewController, User, MDMyConnectionManager;

typedef NS_ENUM(NSInteger, MTPMainMenuVisibilityState)
{
    MTPMainMenuVisibilityStateHidden     = -1,
    MTPMainMenuVisibilityStateAnimating  =  0,
    MTPMainMenuVisibilityStateVisible    =  1,
    
};

@protocol MTPMainMenuDelegate <NSObject>
- (void)mainMenuDidToggleMenu:(MAMMainMenuViewController *)mainMenu;
- (void)mainMenu:(MAMMainMenuViewController *)mainMenu didSelectMainMenuItem:(MTPMenuItem *)menuItem;
@end

@interface MAMMainMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MTPNavigationLoadable>

@property (nonatomic, weak) id <MTPMainMenuDelegate> mainMenuDelegate;
@property (nonatomic, weak) id <MTPEditProfileDisplayable> editProfilePresentationTarget;

@property (nonatomic, strong) MTPNavigationRouter *navigationRouter;
@property (nonatomic, strong) MDMyConnectionManager *connectionManager;

@property (nonatomic, strong, readonly) NSArray *mainMenuItems;
@property (nonatomic, assign) MTPMainMenuVisibilityState visiblityState;

@property (weak, nonatomic) IBOutlet UIImageView *mainMenuBackgroundImage;

@property (weak, nonatomic) IBOutlet MTPMainMenuHeaderView *headerView;

@property (weak, nonatomic) IBOutlet UITableView *menuTableView;

@property (weak, nonatomic) IBOutlet MAMMainFooterView *menuFooterView;

- (void)configureHeaderView;

- (void)reloadAppearance;

- (void)loadMainMenuItem:(MTPMenuItem *)menuItem;

- (void)menuSelectable:(BOOL)selectable;

/**
 @description Reloads the menu data. The default implementation does nothing. Subclasses should override this method to perform custom data fetching.
 @param reloadCompletionHandler Optional completion handler
 */
- (void)reloadMainMenuData:(void(^)(NSArray *menuItems))reloadCompletionHandler;

@end
