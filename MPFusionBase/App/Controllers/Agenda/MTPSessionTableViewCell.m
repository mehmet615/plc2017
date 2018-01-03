//
//  MTPSessionTableViewCell.m
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 5/17/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPSessionTableViewCell.h"

@implementation MTPSessionTableViewCell

//- (void)drawRect:(CGRect)rect
//{
//    self.ellipsisLabel.layer.cornerRadius = CGRectGetMidX(self.ellipsisLabel.frame);
//    self.ellipsisLabel.layer.masksToBounds = YES;
//}

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    self.ellipsisLabel.backgroundColor = [UIColor lightGrayColor];
    self.sessionTrackButton.layer.cornerRadius = 7;
    self.sessionTrackButton.layer.masksToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.ellipsisLabel.layer.cornerRadius = CGRectGetMidX(self.ellipsisLabel.bounds);
    self.ellipsisLabel.layer.masksToBounds = YES;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
