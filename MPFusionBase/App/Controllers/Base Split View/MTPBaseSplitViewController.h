//
//  MTPBaseSplitViewController.h
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 11/24/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MTPMainMenuTogglable.h"
#import "MTPNavigationRouter.h"

@interface MTPBaseSplitViewController : UISplitViewController <MTPNavigationRouterDelegate,MTPMainMenuTogglable>

@property (nonatomic, strong) MTPNavigationRouter *navigationRouter;

- (void)loadMainViewControllers;
- (void)openQRCode:(id)sender;

@end
