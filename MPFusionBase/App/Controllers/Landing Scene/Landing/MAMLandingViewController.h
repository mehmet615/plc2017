//
//  MAMLandingViewController.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/10/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAMRootNavigationViewController.h"

@interface MAMLandingViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UIView *contentContainerView;

extern CGFloat const menuWidth;

- (void)toggleEditProfileVisibility;
- (void)refreshEditProfileWebView:(NSNumber *)userID;
@end
