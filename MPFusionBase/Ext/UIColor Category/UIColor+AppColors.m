//
//  UIColor+AppColors.m
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 7/9/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "UIColor+AppColors.h"
#import "MTPAppSettingsKeys.h"
#import "NSObject+EventDefaultsHelpers.h"

@implementation UIColor (AppColors)

+ (UIColor *)appTintColor
{
    UIColor *appTintColor = [self mtp_colorFromString:[[[NSUserDefaults standardUserDefaults] objectForKey:MTP_BaseOptions] objectForKey:MTP_AppTintColor]];
    
    if (appTintColor)
    {
        return appTintColor;
    }
    else
    {
        return [UIColor colorWithRed:0/255.0 green:0/255.0 blue:255/255.0 alpha:1.0f];
    }
}

+ (UIColor *)mainMenuBackground
{
    return [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0f];
}

+ (UIColor *)mtp_colorFromString:(NSString *)colorString
{
    if (colorString.length == 0)
    {
        return nil;
    }
    else if ([colorString isEqualToString:@"clear"])
    {
        return [UIColor clearColor];
    }
    
    if ([colorString rangeOfString:@"rgba"].length)
    {
        return [self mtp_colorFromRGBAString:colorString];
    }
    else
    {
        NSMutableString *tempHex = [[NSMutableString alloc] init];
        
        [tempHex appendString:colorString];
        
        unsigned colorInt = 0;
        
        [[NSScanner scannerWithString:tempHex] scanHexInt:&colorInt];
        
        return UIColorFromRGB(colorInt);
    }
}

+ (UIColor *)mtp_colorFromRGBAString:(NSString *)rgbaString
{
    NSMutableArray *colorValues = [NSMutableArray new];
    
    double colorValue = NAN;
    
    NSScanner *scanner = [NSScanner scannerWithString:rgbaString];
    while (!scanner.isAtEnd)
    {
        BOOL foundNumber = [scanner scanDouble:&colorValue];
        if (foundNumber)
        {
            if (colorValue >= 0 && colorValue < 256)
            {
                [colorValues addObject:@(colorValue)];
            }
        }
        [scanner setScanLocation:scanner.scanLocation+1];
    }
    
    __block NSNumber *red = nil;
    __block NSNumber *green = nil;
    __block NSNumber *blue = nil;
    __block NSNumber *alpha = @1;
    
    [colorValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (idx)
        {
            case 0:
            {
                red = obj;
                break;
            }
            case 1:
            {
                green = obj;
                break;
            }
            case 2:
            {
                blue = obj;
                break;
            }
            case 3:
            {
                alpha = obj;
                break;
            }
            default:
                break;
        }
    }];
    
    if (red && green && blue && alpha)
    {
        UIColor *rgbaColor = [UIColor colorWithRed:red.doubleValue/255.f green:green.doubleValue/255.f blue:blue.doubleValue/255.f alpha:alpha.doubleValue];
        return rgbaColor;
    }
    else
    {
        return nil;
    }
}

@end
