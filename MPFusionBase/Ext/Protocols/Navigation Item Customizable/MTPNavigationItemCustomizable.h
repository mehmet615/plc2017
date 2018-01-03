//
//  MTPNavigationItemCustomizable.h
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 12/2/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MTPNavigationItemCustomizable <NSObject>
@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;
@optional
- (void)setupLeftBarButton;
@end
