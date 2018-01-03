//
//  MTPSearchResultsViewController.h
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/22/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

@class MTPThemeOptionsManager;

@interface MTPSearchResultsViewController : UIViewController <MTPNavigationItemCustomizable>

@property (strong, nonatomic) MTPThemeOptionsManager *themeOptionsManager;
@property (strong, nonatomic) NSNumber *userID;
@property (strong, nonatomic) NSString *searchQuery;

@property (weak, nonatomic) id <MTPMainMenuTogglable> menuToggler;
@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;
- (void)setupLeftBarButton;

- (NSMutableURLRequest *)requestForQuery:(NSString *)searchQuery;

- (IBAction)refreshWebView:(id)sender;

@end
