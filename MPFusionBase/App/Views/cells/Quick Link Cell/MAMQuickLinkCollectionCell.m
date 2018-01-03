//
//  MAMQuickLinkCollectionCell.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/14/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMQuickLinkCollectionCell.h"
#import <QuartzCore/CALayer.h>
#import "NSObject+EventDefaultsHelpers.h"
#import "UIColor+AppColors.h"
#import "MTPAppSettingsKeys.h"

#import "MTPApplicationDefaultsConstants.h"

@interface MAMQuickLinkCollectionCell ()
@property (nonatomic, assign) CGRect circleRect;
@property (strong, nonatomic) CAShapeLayer *circleLayer;
@property (strong, nonatomic) UIColor *customBackgroundColor;
@end

@implementation MAMQuickLinkCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.circleInset = 8;
    
    self.iconLabel.font = [UIFont fontWithName:@"FontAwesome" size:35.f];

    self.iconLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.0];
    self.iconLabel.shadowOffset = CGSizeMake(2, 2);
    self.iconContainer.backgroundColor = [UIColor clearColor];
    
    self.quickLinkTitle.font = [UIFont fontWithName:@"Lato-Regular" size:16.f];
    self.quickLinkTitle.lineBreakMode = NSLineBreakByWordWrapping;
    self.quickLinkTitle.numberOfLines = 0;
    
    self.quickLinkTitle.shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.quickLinkTitle.shadowOffset = CGSizeMake(0, 1);
}

- (void)drawRect:(CGRect)rect
{
    CGRect newCircleRect = self.circleBackground.bounds;

    CGFloat rectSideLength = MIN(CGRectGetHeight(newCircleRect), CGRectGetWidth(newCircleRect));
    newCircleRect.size = CGSizeMake(rectSideLength, rectSideLength);
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectInset(newCircleRect, self.circleInset, self.circleInset)];

    if (self.circleLayer == nil) {
        CAShapeLayer *circleLayer = [CAShapeLayer layer];
        circleLayer.lineWidth = MTP_QUICKLINKSCELL_SHOWBORDER ? 3.f : 0;
        self.circleLayer = circleLayer;
        [self.circleBackground.layer addSublayer:circleLayer];
    }
    
    self.circleLayer.path = circlePath.CGPath;
    self.circleLayer.fillColor = self.customBackgroundColor.CGColor;
    
    if (self.borderColor)
    {
        self.circleLayer.strokeColor = self.borderColor.CGColor;
    }
    else
    {
        self.circleLayer.strokeColor = self.customBackgroundColor.CGColor;
    }
    
    self.circleRect = newCircleRect;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
//    self.circleLayer.position = self.circleBackground.center;
}

- (void)setCircleColor:(UIColor *)circleColor
{
    self.customBackgroundColor = circleColor;
}

@end
