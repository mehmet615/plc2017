//
//  MTPAttendeeSectionCell.m
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 8/8/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPAttendeeSectionCell.h"

@implementation MTPAttendeeSectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.sectionBackground.backgroundColor = selected ? self.selectedColor : self.unselectedColor;
    self.sectionIndicator.textColor = selected ? self.selectedTextColor : self.unselectedTextColor;
}

@end
