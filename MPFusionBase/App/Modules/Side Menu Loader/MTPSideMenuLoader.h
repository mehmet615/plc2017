//
//  MTPSideMenuLoader.h
//  HS2016
//
//  Created by Michael Thongvanh on 3/28/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPRightNavigationViewController,MTPNavigationRouter;

@interface MTPSideMenuLoader : NSObject

@property (strong, nonatomic) MTPRightNavigationViewController *rightMenu;

@property (readonly, nonatomic) NSLayoutConstraint *rightMenuLeading;
- (MTPRightNavigationViewController *)setupSideMenu:(UIView *)parentView inViewController:(UIViewController *)parentViewController navigationRouter:(MTPNavigationRouter *)navigationRouter;

- (void)showMenu;
- (void)hideMenu;
- (void)loadWebView;
@end
