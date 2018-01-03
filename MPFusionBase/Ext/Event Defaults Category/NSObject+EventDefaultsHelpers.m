//
//  NSObject+EventDefaultsHelpers.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/7/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "NSObject+EventDefaultsHelpers.h"
#import "MTPMenuItem.h"
#import "MTPViewControllerDataSource.h"
#import "MTPAppSettingsKeys.h"

@implementation NSObject (EventDefaultsHelpers)

- (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

- (UIView *)addSeparatorLine:(UILabel *)mainTitleLabel
{
    if (!mainTitleLabel)
    {
        return nil;
    }
    CGRect separatorLineFrame = mainTitleLabel.frame;
    separatorLineFrame.size.height = 1.f;
    separatorLineFrame.origin.y = CGRectGetMaxY(mainTitleLabel.frame) - (separatorLineFrame.size.height * (mainTitleLabel.frame.size.height * 0.15));
    separatorLineFrame.origin.x = 0;
    UIView *separatorLine = [[UIView alloc] initWithFrame:separatorLineFrame];
    separatorLine.translatesAutoresizingMaskIntoConstraints = false;
    separatorLine.backgroundColor = [UIColor whiteColor];
    return separatorLine;
}

- (UIFont *)customSectionHeaderFont:(NSDictionary *)customTextStyling
{
    UIFont *sectionHeaderFont;
    
    NSString *customFontName = [customTextStyling objectForKey:MTP_MainMenuSectionFontName];
    NSNumber *customFontSize = [customTextStyling objectForKey:MTP_MainMenuSectionFontSize];
    if (customFontName)
    {
        if (customFontSize)
        {
            sectionHeaderFont = [UIFont fontWithName:customFontName
                                                size:customFontSize.floatValue];
        }
        else
        {
            sectionHeaderFont = [UIFont fontWithName:customFontName
                                                size:[[customTextStyling objectForKey:MTP_MainMenuDefaultFontSize] floatValue]];
        }
    } else {
        sectionHeaderFont = [UIFont fontWithName:[customTextStyling objectForKey:MTP_MainMenuDefaultFontName]
                                            size:[[customTextStyling objectForKey:MTP_MainMenuDefaultFontSize] floatValue]];
    }
    return sectionHeaderFont;
}

- (UIFont *)customMainMenuHeaderFont:(NSDictionary *)headerStyling
{
    UIFont *customHeaderFont;
    
    NSString *fontName = [headerStyling objectForKey:MTP_MainMenuHeaderFontName];
    if (fontName)
    {
        NSNumber *fontSize = [headerStyling objectForKey:MTP_MainMenuHeaderFontSize];
        if (fontSize)
        {
            customHeaderFont = [UIFont fontWithName:fontName size:fontSize.floatValue];
        }
        else
        {
            customHeaderFont = [UIFont fontWithName:fontName size:[[headerStyling objectForKey:MTP_MainMenuHeaderFontDefaultSize] floatValue]];
        }
    }
    return customHeaderFont;
}


- (UIFont *)customMainMenuHeaderSubtitleFont:(NSDictionary *)headerStyling
{
    UIFont *customHeaderFont;
    
    NSString *fontName = [headerStyling objectForKey:MTP_MainMenuHeaderSubtitleFontName];
    if (fontName)
    {
        NSNumber *fontSize = [headerStyling objectForKey:MTP_MainMenuHeaderSubtitleFontSize];
        if (fontSize)
        {
            customHeaderFont = [UIFont fontWithName:fontName size:fontSize.floatValue];
        }
        else
        {
            customHeaderFont = [UIFont fontWithName:fontName size:[[headerStyling objectForKey:MTP_MainMenuHeaderFontDefaultSize] floatValue]];
        }
    }
    return customHeaderFont;
}

//- (UIColor *)appTintColor
//{
//    return UIColorFromRGB(0x0178b0);
//}

//- (UIColor *)colorFromString:(NSString *)colorString
//{
//    if (colorString.length == 0)
//    {
//        return nil;
//    }
//    else if ([colorString isEqualToString:@"clear"])
//    {
//        return [UIColor clearColor];
//    }
//    
//    NSMutableString *tempHex = [[NSMutableString alloc] init];
//
//    [tempHex appendString:colorString];
//    
//    unsigned colorInt = 0;
//    
//    [[NSScanner scannerWithString:tempHex] scanHexInt:&colorInt];
//    
//    return UIColorFromRGB(colorInt);
//}


@end
