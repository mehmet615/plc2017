//
//  MTPAttendeeSectionCell.h
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 8/8/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTPAttendeeSectionCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *sectionBackground;
@property (weak, nonatomic) IBOutlet UILabel *sectionIndicator;
@property (strong, nonatomic) UIColor *selectedColor;
@property (strong, nonatomic) UIColor *selectedTextColor;
@property (strong, nonatomic) UIColor *unselectedColor;
@property (strong, nonatomic) UIColor *unselectedTextColor;
@end
