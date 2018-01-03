//
//  MAMMainFooterView.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/14/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMMainFooterView.h"
#import "UIView+AutoLayoutHelper.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "MTPAppSettingsKeys.h"
#import "UIColor+AppColors.h"

@interface MAMMainFooterView ()
@property (nonatomic, assign) BOOL laidOutConstraints;
@end

@implementation MAMMainFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    UIColor *footerTextColor = [UIColor mtp_colorFromString:[[[self.userDefaults objectForKey:MTP_MainMenuOptions] objectForKey:MTP_MainMenuFooter] objectForKey:MTP_MainMenuFooterTextColor]];
    if (footerTextColor == nil)
    {
        footerTextColor =[UIColor whiteColor];
    }
    
    UIColor *footerLogoColor = [UIColor mtp_colorFromString:[[[self.userDefaults objectForKey:MTP_MainMenuOptions] objectForKey:MTP_MainMenuFooter] objectForKey:MTP_MainMenuFooterLogoColor]];
    if (footerLogoColor == nil)
    {
        footerLogoColor =[UIColor whiteColor];
    }
    
    self.meetingplayLabel.textColor = footerTextColor;
    self.marriottLabel.textColor = footerTextColor;
    
    self.meetingplayLogo.image = [self.meetingplayLogo.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.meetingplayLogo setTintColor:footerLogoColor];
    self.laidOutConstraints = true;
    
}

- (void)updateConstraints
{
    if (!self.laidOutConstraints)
    {
        [self removeConstraints:self.constraints];
        [self.marriottLabel removeConstraints:self.marriottLabel.constraints];
        [self.meetingplayLabel removeConstraints:self.meetingplayLabel.constraints];
        [self.meetingplayLogo removeConstraints:self.meetingplayLogo.constraints];
        
        [self setupConstraints];
    }
    [super updateConstraints];
}


- (void)setupConstraints
{
    CGFloat leadingConstant = 10;
    
    [self.meetingplayLogo.superview addConstraints:@[[self.meetingplayLogo pinSide:NSLayoutAttributeLeading
                                                                          constant:leadingConstant],
                                                     [self.meetingplayLogo pinSide:NSLayoutAttributeBottom
                                                                          constant:0],
                                                     [self.meetingplayLogo height:35],
                                                     [self.meetingplayLogo aspectRatio],
                                                     [self.meetingplayLogo pin:self.meetingplayLogo
                                                                          side:NSLayoutAttributeTop
                                                                        toView:self.meetingplayLabel
                                                                    secondSide:NSLayoutAttributeBottom
                                                                      constant:0
                                                                    multiplier:1]]];
    
    [self.meetingplayLabel.superview addConstraints:@[[self.meetingplayLabel pinSide:NSLayoutAttributeLeading
                                                                            constant:leadingConstant],
                                                      [self.meetingplayLabel pinTrailing],
                                                      [self.meetingplayLabel height:15],
                                                      [self.meetingplayLabel pin:self.meetingplayLabel
                                                                            side:NSLayoutAttributeTop
                                                                          toView:self.marriottLabel
                                                                      secondSide:NSLayoutAttributeBottom
                                                                        constant:0
                                                                      multiplier:1]]];
    
    [self.marriottLabel.superview addConstraints:@[[self.marriottLabel pinSide:NSLayoutAttributeTop constant:0],
                                                   [self.marriottLabel pinTrailing],
                                                   [self.marriottLabel height:15],
                                                   [self.marriottLabel pinSide:NSLayoutAttributeLeading
                                                                      constant:leadingConstant]]];
    

    

     
}
@end
