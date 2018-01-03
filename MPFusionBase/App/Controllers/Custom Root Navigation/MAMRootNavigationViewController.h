//
//  MAMRootNavigationViewController.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/13/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
// View Controller
#import "MTPBaseNavigationController.h"

#import "MTPViewControllerDataSource.h"
#import "MAMLoginViewController.h"

// Managers
#import "MTPAlertManager.h"
#import "MTPLoginClient.h"
#import "MTPBeaconSightingManager.h"
#import "MDBeaconManager.h"
#import "MDMyConnectionManager.h"
#import "MTPSponsorManager.h"

// Helpers
#import "User+Helpers.h"
#import "MTPMenuItem.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "EventKeys.h"

#import "MTPMainMenuTogglable.h"
#import "MTPNavigationRouter.h"

@class MTPNavigationRouter,MAMBaseViewController;

@interface MAMRootNavigationViewController : UINavigationController <MTPNavigationRouterDelegate,MTPMainMenuTogglable>

@property (nonatomic, strong) MTPNavigationRouter *applicationRouter;

- (void)handleLogin:(NSURL *)url;

@end

