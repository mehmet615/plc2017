//
//  MAMMapViewController.h
//  PrudentialIIC
//
//  Created by Michael Thongvanh on 5/28/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPViewControllerDataSource.h"
#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

@interface MAMMapViewController : UIViewController <MTPViewControllerDataSourceDelegate, MTPNavigationItemCustomizable>

@property (nonatomic, strong) MTPViewControllerDataSource *configurationDataSource;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;
@property (weak, nonatomic) id<MTPMainMenuTogglable> menuToggleDelegate;
@end
