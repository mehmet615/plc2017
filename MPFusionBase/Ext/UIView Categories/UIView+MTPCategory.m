//
//  UIView+MTPCategory.m
//  GaylordHotels
//
//  Created by Michael Thongvanh on 5/8/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "UIView+MTPCategory.h"

@implementation UIView (MTPCategory)

+ (void)createLayerShadow:(CALayer *)layerForShadow
{
    layerForShadow.shadowColor = [UIColor blackColor].CGColor;
    layerForShadow.shadowOpacity = 0.2f;
    layerForShadow.shadowRadius = 1.f;
    layerForShadow.shadowOffset = CGSizeMake(0, 1);
}

- (void)setRoundWithRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color {
    self.layer.cornerRadius = radius;
    self.layer.borderWidth = width;
    self.layer.borderColor = [color CGColor];
    self.clipsToBounds = YES;
}

@end
