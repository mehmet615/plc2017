//
//  MAMMainMenuTableViewCell.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/10/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPMenuItem;

@interface MAMMainMenuTableViewCell : UITableViewCell

@property (nonatomic, strong) MTPMenuItem *menuItem;

@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *menuItemLabel;

@property (strong, nonatomic) UIColor *defaultIconColor;
@property (strong, nonatomic) UIColor *defaultTextColor;
@property (strong, nonatomic) UIColor *defaultBackgroundColor;

@property (strong, nonatomic) UIColor *activeIconColor;
@property (strong, nonatomic) UIColor *activeTextColor;
@property (strong, nonatomic) UIColor *activeBackgroundColor;

- (void)reloadCellAppearance;

@end
