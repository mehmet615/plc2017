//
//  UIColor+AppColors.h
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 7/9/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (AppColors)

+ (UIColor *)appTintColor;

+ (UIColor *)mainMenuBackground;

+ (UIColor *)mtp_colorFromString:(NSString *)colorString;
+ (UIColor *)mtp_colorFromRGBAString:(NSString *)rgbaString;
@end
