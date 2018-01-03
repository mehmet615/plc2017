//
//  UIButton+MTPNavigationBar.m
//  GaylordHotels
//
//  Created by Michael Thongvanh on 5/11/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "UIButton+MTPNavigationBar.h"
#import "MTPAppSettingsKeys.h"
#import "UIColor+AppColors.h"

@implementation UIButton (MTPNavigationBar)

CGFloat menuButtonSize = 25;

+ (UIBarButtonItem *)toggleMainMenuButton:(NSDictionary *)menuButtonCustomization target:(id)target selector:(SEL)action
{
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [menuButton setFrame:CGRectMake(0, 0, 23, 22)];
    
    if (!menuButtonCustomization)
    {
        [menuButton setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
    }
    else
    {
        NSString *imageName = menuButtonCustomization[@"imageName"];
        if (imageName.length)
        {
            [menuButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        }
        else
        {
            [menuButton setImage:[UIImage imageNamed:@"menuIcon"] forState:UIControlStateNormal];
        }
    }
    
    [menuButton addTarget:target action:action
         forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:menuButton];
}

+ (UIBarButtonItem *)refreshMenuButton:(NSDictionary *)refreshButtonCustomization target:(id)target selector:(SEL)action
{
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshButton setFrame:CGRectMake(0, 0, menuButtonSize, menuButtonSize)];
    
    if (!refreshButtonCustomization)
    {
        [refreshButton setImage:[UIImage imageNamed:@"refreshIcon"] forState:UIControlStateNormal];
    }
    else
    {
        NSString *imageName = refreshButtonCustomization[@"imageName"];
        if (imageName.length)
        {
            [refreshButton setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        }
        else
        {
            [refreshButton setImage:[UIImage imageNamed:@"refreshIcon"] forState:UIControlStateNormal];
        }
    }
    
    [refreshButton addTarget:target action:action
            forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
}

+ (void)addTitleColor:(UIButton *)button
{
    NSString *navigationBarButtonColor = [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_MainApperance] objectForKey:MTP_NavigationBarButtonColor];
    if (navigationBarButtonColor.length == 0)
    {
        return;
    }
    
    UIColor *buttonColor = [UIColor mtp_colorFromString:navigationBarButtonColor];
    if (buttonColor)
    {
        [button setTitleColor:buttonColor forState:UIControlStateNormal];
    }
}

+ (void)addBorderEffect:(UIButton *)menuButton
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:menuButton.frame cornerRadius:5];
    CAShapeLayer *thickFrame = [[CAShapeLayer alloc] initWithLayer:menuButton.layer];
    thickFrame.path = bezierPath.CGPath;
    thickFrame.strokeColor = [UIColor blackColor].CGColor;
    thickFrame.fillColor = [UIColor clearColor].CGColor;
    thickFrame.lineWidth = 0.5f;
    [menuButton.layer insertSublayer:thickFrame atIndex:1];
    
    CAShapeLayer *thinFrame = [[CAShapeLayer alloc] initWithLayer:menuButton.layer];
    thinFrame.path = bezierPath.CGPath;
    thinFrame.strokeColor = [UIColor colorWithWhite:1 alpha:0.15].CGColor;
    thinFrame.fillColor = [UIColor clearColor].CGColor;
    thinFrame.lineWidth = 2.5f;
    [menuButton.layer insertSublayer:thinFrame atIndex:1];
}

+ (UIImageView *)navigationBarLogo:(CGFloat)destinationHeight
{
    UIImageView *logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navigationBarLogo"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    CGRect newFrame = CGRectMake(0, 0, 10, destinationHeight - 15);
    logoView.frame = newFrame;
    
    return logoView;
}

@end
