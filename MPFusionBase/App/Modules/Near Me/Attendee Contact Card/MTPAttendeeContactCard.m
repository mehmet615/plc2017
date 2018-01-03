//
//  MTPAttendeeContactCard.m
//  CPC2016
//
//  Created by MeetingPlay on 11/22/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPAttendeeContactCard.h"
#import "MTPDLogDefine.h"

@interface MTPAttendeeContactCard ()
@property (weak, nonatomic) IBOutlet UILabel *linkLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelHeight;
@end

@implementation MTPAttendeeContactCard

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
    
    self.topButton.layer.cornerRadius = 3.f;
    self.middleButton.layer.cornerRadius = 3.f;
    self.bottomButton.layer.cornerRadius = 3.f;
}

- (void)showJobTitle
{
    [self toggleJobTitleVisiblity:YES];
}

- (void)hideJobTitle
{
    [self toggleJobTitleVisiblity:NO];
}

- (void)toggleJobTitleVisiblity:(BOOL)show
{
    if (show)
    {
        self.titleLabelHeight.priority = 200;
    }
    else
    {
        self.titleLabelHeight.priority = 999;
    }
    
    [self setNeedsUpdateConstraints];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.attendeeImageView.hidden = self.hideImage;
    
    self.attendeeImageView.layer.cornerRadius = CGRectGetWidth(self.attendeeImageView.frame)/2.f;
    self.initialsLabel.layer.cornerRadius = CGRectGetWidth(self.attendeeImageView.frame)/2.f;
    
    self.linkLabel.layer.cornerRadius = CGRectGetMidX(self.linkLabel.bounds);
}

- (IBAction)pressedClose:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(attendeeCardDidDismiss:)])
    {
        [self.delegate attendeeCardDidDismiss:self];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

- (IBAction)pressedViewShared:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(attendeeCardDidViewSharedInterests:)])
    {
        [self.delegate attendeeCardDidViewSharedInterests:self];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

- (IBAction)pressedSparkConversation:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(attendeeCardDidSparkConversation:)])
    {
        [self.delegate attendeeCardDidSparkConversation:self];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

- (IBAction)pressedViewProfile:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(attendeeCardDidViewProfile:)])
    {
        [self.delegate attendeeCardDidViewProfile:self];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

- (IBAction)pressedConnect:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(attendeeCardDidConnect:)])
    {
        [self.delegate attendeeCardDidConnect:self];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}



/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
@end
