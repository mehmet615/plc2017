//
//  UIViewController+NavigationItemSetup.h
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 12/2/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (NavigationItemSetup)

- (void)setupNavigationItem:(BOOL)qrEnabled;
- (void)setupLeftBarButton:(UIBarButtonItem *)leftBarButton;
- (void)setupQRButton;
- (void)setupSideMenuButton;
- (UIBarButtonItem *)customBarButtonItem:(SEL)customAction;

@end
