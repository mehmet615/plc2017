//
//  UIView+MTPCategory.h
//  GaylordHotels
//
//  Created by Michael Thongvanh on 5/8/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MTPCategory)

+ (void)createLayerShadow:(CALayer *)layerForShadow;
- (void)setRoundWithRadius:(CGFloat)radius borderWidth:(CGFloat)width borderColor:(UIColor *)color ;
@end
