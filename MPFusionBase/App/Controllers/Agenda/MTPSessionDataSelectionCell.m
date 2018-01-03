//
//  MTPSessionDataSelectionCell.m
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 5/17/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPSessionDataSelectionCell.h"

@implementation MTPSessionDataSelectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    self.dateNumberLabel.textColor = [UIColor whiteColor];
    self.dateNumberLabel.backgroundColor = [UIColor lightGrayColor];
    self.dateNumberLabel.layer.masksToBounds = YES;
}

- (void)drawRect:(CGRect)rect
{
    self.dateNumberLabel.layer.cornerRadius = CGRectGetMidX(self.dateNumberLabel.bounds);
}

- (void)setSelected:(BOOL)selected
{
    if (selected)
    {
        self.dateNumberLabel.backgroundColor = self.selectedColor;
    }
    else
    {
        self.dateNumberLabel.backgroundColor = [UIColor lightGrayColor];
    }
}
@end
