//
//  MTPSessionDataSelectionCell.h
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 5/17/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTPSessionDataSelectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateWeekdayLabel;
@property (strong, nonatomic) UIColor *selectedColor;

@end
