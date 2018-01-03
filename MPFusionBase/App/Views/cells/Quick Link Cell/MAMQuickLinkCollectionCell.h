//
//  MAMQuickLinkCollectionCell.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/14/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAMQuickLinkCollectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *iconContainer;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UIView *circleBackground;
@property (weak, nonatomic) IBOutlet UILabel *quickLinkTitle;
@property (strong, nonatomic) UIColor *borderColor;

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;

@property (assign, nonatomic) CGFloat circleInset;

- (void)setCircleColor:(UIColor *)circleColor;

@end
