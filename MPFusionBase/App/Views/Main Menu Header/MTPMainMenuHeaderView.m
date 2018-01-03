//
//  MTPMainMenuHeaderView.m
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/17/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "MTPMainMenuHeaderView.h"
#import "MTPDLogDefine.h"
#import "MTPAppSettingsKeys.h"
#import "UIColor+AppColors.h"

#import "MTPApplicationDefaultsConstants.h"

@interface MTPMainMenuHeaderView () <MTPHeaderSearchDelegate>

@end

@implementation MTPMainMenuHeaderView

CGFloat headerViewCornerRadius = 2.f;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.searchButton.layer.cornerRadius = headerViewCornerRadius;
    self.searchButton.layer.masksToBounds = YES;
    
    self.searchBarContainer.layer.cornerRadius = headerViewCornerRadius;
    
    self.searchHandler.delegate = self;
    
    self.searchIcon.tintColor = [UIColor whiteColor];
    
    if (MTP_MAINMENUHEADER_DARK_SEARCH_BACKGROUND)
    {
        self.searchField.textColor = [UIColor whiteColor];
        self.searchField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.searchField.placeholder attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    }
    
    if (MTP_MAINMENUHEADER_SHOW_SEARCH_CLEAR_BACKGROUND)
    {
        self.searchBarContainer.backgroundColor = [UIColor clearColor];
    }
}

- (void)configureWithTheme:(NSDictionary *)themeOptions
{
    [self supplyEventDetails:themeOptions[MPFUSION_eventInformation]];
    
    NSDictionary *colors = themeOptions[MPFUSION_colors];
    
    UIColor *color16 = [UIColor mtp_colorFromString:colors[MPFUSION_color16]];
    self.searchContainer.backgroundColor = color16;
    
    UIColor *color9 = [UIColor mtp_colorFromString:colors[MPFUSION_color9]];
    if (color9)
    {
        self.navigationDividerLabel.backgroundColor = color9;
    }
    
    UIColor *color14 = [UIColor mtp_colorFromString:colors[MPFUSION_color14]];
    if (color14)
    {
        self.searchIcon.tintColor = color14;
    }
    
    UIColor *color15 = [UIColor mtp_colorFromString:colors[MPFUSION_color15]];
    if (color15)
    {
        self.searchButton.backgroundColor = color15;
    }
    
    self.navigationDividerLabel.text = [themeOptions[MPFUSION_sideBar] objectForKey:MPFUSION_sideBarDividerTitle];
    UIColor *color10 = [UIColor mtp_colorFromString:colors[MPFUSION_color10]];
    self.navigationDividerLabel.textColor = color10;
}

- (void)supplyEventDetails:(NSDictionary *)eventDetails
{
    NSString *eventName = eventDetails[MPFUSION_eventName];
    NSString *eventDate = eventDetails[MPFUSION_eventDate];
    NSString *eventLocation = eventDetails[MPFUSION_eventLocation];
    
    self.eventNameLabel.text = eventName.length ? eventName : @"Event Details";
    self.eventLocationLabel.text = eventLocation.length ? eventLocation : @"Event Location";
    self.eventDateLabel.text = eventDate.length ? eventDate : @"Event Date";
}

- (void)loadSideBarImage:(UIImage *)image
{
    if (image == nil)
    {
        return;
    }
    
    CGFloat aspectRatio = image.size.height / MAX(1,image.size.width);
    
    CGFloat sideBarWidth = self.sideBarImage.frame.size.width;
    CGFloat sideBarHeight = sideBarWidth * aspectRatio;
    
    self.sideBarImageHeight.constant = sideBarHeight;
    
    [self.sideBarImage setImage:image];
}

- (IBAction)pressedSearch:(id)sender
{
    [self forwardSearch:self.searchField.text];
}

- (void)forwardSearch:(NSString *)searchQuery
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mainMenuHeader:didSearch:)])
    {
        NSString *trimmedSearchQuery = [searchQuery stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (trimmedSearchQuery.length)
        {
            [self.delegate mainMenuHeader:self didSearch:trimmedSearchQuery];
        }
        else
        {
            DLog(@"\nsearch query was empty %@",self.delegate);
        }
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
    
    [self endEditing:YES];
}

- (void)searchHandler:(MTPHeaderSearchHandler *)searchHandler didSearch:(NSString *)searchQuery
{
    [self forwardSearch:searchQuery];
}

@end



@implementation MTPHeaderSearchHandler

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self didSearch:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self didSearch:textField.text];
    
    return YES;
}

- (void)didSearch:(NSString *)searchQuery
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchHandler:didSearch:)])
    {
        [self.delegate searchHandler:self didSearch:searchQuery];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

@end
