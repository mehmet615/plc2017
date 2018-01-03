//
//  UIImageView+MTPNavigationBar.m
//  NSI2015
//
//  Created by Michael Thongvanh on 6/2/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "UIImageView+MTPNavigationBar.h"

@implementation UIImageView (MTPNavigationBar)

+ (UIView *)navigationBarLogo:(CGRect)viewRect
{
    CGFloat navbarHeight = CGRectGetHeight(viewRect);
    CGFloat navbarWidth = CGRectGetWidth(viewRect);
    
    UIView *logoContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, navbarHeight)];
    
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationBarLogo"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    logoView.frame = CGRectMake((-navbarWidth * 0.4)/2.f, 0, navbarWidth * 0.4, navbarHeight * 1.4);

    [logoContainer addSubview:logoView];
    
    return logoContainer;
}

@end
