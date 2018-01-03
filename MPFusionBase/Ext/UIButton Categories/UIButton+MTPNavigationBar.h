//
//  UIButton+MTPNavigationBar.h
//  GaylordHotels
//
//  Created by Michael Thongvanh on 5/11/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (MTPNavigationBar)

extern CGFloat menuButtonSize;

+ (UIBarButtonItem *)toggleMainMenuButton:(NSDictionary *)menuButtonCustomization target:(id)target selector:(SEL)action;

+ (UIBarButtonItem *)refreshMenuButton:(NSDictionary *)refreshButtonCustomization target:(id)target selector:(SEL)action;

+ (UIImageView *)navigationBarLogo:(CGFloat)destinationHeight;

@end
