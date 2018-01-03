//
//  MTPMatchesAlertView.m
//  CPC2016
//
//  Created by Michael Thongvanh on 11/30/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPMatchesAlertView.h"
#import "MTPDLogDefine.h"

@interface MTPMatchesAlertView ()
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@end

@implementation MTPMatchesAlertView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contentContainer.layer.cornerRadius = 4.f;
    self.contentContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    self.contentContainer.layer.shadowOpacity = 1;
    self.contentContainer.layer.shadowRadius = 5;
    self.contentContainer.clipsToBounds = YES;
    
    self.attendeeImageView.layer.masksToBounds = YES;
    self.initialsLabel.layer.masksToBounds = YES;
    
    self.linkLabel.layer.masksToBounds = YES;
    self.linkLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    self.viewInterestsButton.layer.cornerRadius = 3.f;
    self.sparkButton.layer.cornerRadius = 3.f;
    self.cancelButton.layer.cornerRadius = 3.f;
}

- (void)dealloc
{
    DLog(@"\ndealloc %@",self);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.attendeeImageView.layer.cornerRadius = CGRectGetWidth(self.attendeeImageView.frame)/2.f;
    self.initialsLabel.layer.cornerRadius = CGRectGetWidth(self.attendeeImageView.frame)/2.f;
    
    self.linkLabel.layer.cornerRadius = CGRectGetMidX(self.linkLabel.bounds);
}

- (IBAction)pressedViewShared:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(matchesAlertDidViewSharedInterests:)])
    {
        [self.delegate matchesAlertDidViewSharedInterests:self];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

- (IBAction)pressedSparkConversation:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(matchesAlertDidSparkConversation:)])
    {
        [self.delegate matchesAlertDidSparkConversation:self];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

- (IBAction)pressedClose:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(matchesAlertDidDismiss:)])
    {
        [self.delegate matchesAlertDidDismiss:self];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

- (IBAction)pressedConnect:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(matchesAlertDidConnect:)])
    {
        [self.delegate matchesAlertDidConnect:self];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

@end
