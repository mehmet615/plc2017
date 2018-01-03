//
//  UINavigationBar+MTPHelper.m
//  PTC16
//
//  Created by Michael Thongvanh on 2/29/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "UINavigationBar+MTPHelper.h"
#import "UIColor+AppColors.h"

@implementation UINavigationBar (MTPHelper)

- (void)addBackgroundGradient:(NSString *)colorString
{
    [self setBackgroundImage:[self backgroundImage:colorString] forBarMetrics:UIBarMetricsDefault];
}

- (UIImage *)backgroundImage:(NSString *)baseColorString
{
    CGFloat red = 1;
    CGFloat green = 1;
    CGFloat blue = 1;
    CGFloat alpha = 1;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CIVector *point1 = [CIVector vectorWithX:0 Y:-30];
    CIVector *point2 = [CIVector vectorWithX:0 Y:34];
    
    UIColor *baseColor = [UIColor mtp_colorFromString:baseColorString];
    [baseColor getRed:&red green:&green blue:&blue alpha:&alpha];
    CIColor *startColor = [CIColor colorWithRed:red green:green blue:blue];
    
    baseColor = [UIColor mtp_colorFromString:@"000000"];
    [baseColor getRed:&red green:&green blue:&blue alpha:&alpha];
    CIColor *endColor = [CIColor colorWithRed:red green:green blue:blue];
    
    
    CIFilter *linearGradient = [CIFilter filterWithName:@"CILinearGradient"
                                          keysAndValues:
                                @"inputPoint0", point1,
                                @"inputPoint1", point2,
                                @"inputColor0", endColor,
                                @"inputColor1", startColor,
                                nil];
    
    CIImage *result = [linearGradient valueForKey:kCIOutputImageKey];
    CGRect extent = CGRectMake(0, 0, 1242, 44);
    CGImageRef cgImage = [context createCGImage:result fromRect:extent];
    
    UIImage *backgroundImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    return backgroundImage;
}
@end
