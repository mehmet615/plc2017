//
//  MAMMainMenuTableViewCell.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/10/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMMainMenuTableViewCell.h"
#import "MTPMenuItem.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "MTPAppSettingsKeys.h"

@implementation MAMMainMenuTableViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self respondsToSelector:@selector(layoutMargins)])
    {
        self.layoutMargins = UIEdgeInsetsZero;
    }
    self.menuItemLabel.textColor = [UIColor whiteColor];
    
    self.iconLabel.font = [UIFont fontWithName:@"FontAwesome" size:26.f];
    self.iconLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    self.iconLabel.shadowColor = [UIColor colorWithWhite:8 alpha:0.2];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    UIColor *iconColor = self.defaultIconColor;
    UIColor *textColor = self.defaultTextColor;
    UIColor *backgroundColor = self.defaultBackgroundColor;
    
    if (selected)
    {
        iconColor = self.activeIconColor;
        textColor = self.activeTextColor;
        backgroundColor = self.activeBackgroundColor;
    }
    
    self.iconImage.tintColor = iconColor;
    self.iconLabel.textColor = iconColor;
    self.menuItemLabel.textColor = textColor;
    self.backgroundColor = backgroundColor;
}

@end
