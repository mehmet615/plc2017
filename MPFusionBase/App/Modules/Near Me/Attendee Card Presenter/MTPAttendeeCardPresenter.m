//
//  MTPAttendeeCardPresenter.m
//  CPC2016
//
//  Created by MeetingPlay on 11/22/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPAttendeeCardPresenter.h"
#import "MTPAttendeeContactCard.h"
#import "User+Helpers.h"
#import "MTPDLogDefine.h"
#import "UIImageView+WebCache.h"
#import "MTPNavigationRouter.h"
#import "NSString+MTPWebViewURL.h"

@interface MTPAttendeeCardPresenter () <MTPAttendeeContactCardDelegate>
@property (strong, nonatomic) MTPAttendeeContactCard *contactCard;
@property (strong, nonatomic) NSLayoutConstraint *topConstraint;
@property (strong, nonatomic) User *displayedAttendee;
@property (assign, nonatomic) BOOL show;
@end

@implementation MTPAttendeeCardPresenter

- (void)showCard:(User *)attendee match:(BOOL)isMatch completion:(void(^)(User *attendee))completionHandler;
{
    if (attendee)
    {
        self.displayedAttendee = attendee;
        
        DLog(@"existing contact card %@",self.contactCard);
        
        MTPAttendeeContactCard *card = self.contactCard;
        if (card == nil)
        {
            card = [self createContactCard];
            self.contactCard = card;
        }
        
        DLog(@"newcontact card %@",card);
        
        card.topButton.hidden = !isMatch;
        card.middleButton.hidden = !isMatch;
        
        if (!isMatch)
        {
            [card showJobTitle];
        }
        else
        {
            [card hideJobTitle];
        }
        
        [self setupConstraints:card parent:self.presentationView];
        
        card.attendeeImageView.image = nil;
        card.attendeeImageView.hidden = YES;
        card.initialsLabel.text = @"";
        
        [self loadAttendee:attendee card:card];
        
        card.background.alpha = 0;
        
        [card layoutSubviews];
        
        [self.presentationView layoutIfNeeded];
        
        self.topConstraint.constant = -CGRectGetHeight(self.presentationView.frame);
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.presentationView bringSubviewToFront:card];
            [self.presentationView layoutIfNeeded];
            card.background.alpha = 0.5;
        } completion:^(BOOL finished) {
            if (completionHandler)
            {
                completionHandler(attendee);
            }
        }];
    }
    else
    {
        if (completionHandler)
        {
            completionHandler(attendee);
        }
    }
}

- (void)loadAttendee:(User *)attendee card:(MTPAttendeeContactCard *)contactCard
{
    contactCard.attendeeImageView.hidden = YES;
    contactCard.hideImage = YES;
    
    contactCard.attendeeNameLabel.text = [attendee displayMainTitle].length ? [attendee displayMainTitle] : @"";
    contactCard.detailsMainLabel.text = attendee.company.length ? attendee.company : @"";
    contactCard.detailsSubLabel.text = [attendee bio].length ? [attendee bio] : @"";
    
    if ([attendee jobtitle].length == 0)
    {
        contactCard.titleLabel.text = @"";
        [contactCard hideJobTitle];
    }
    else
    {
        contactCard.titleLabel.text = [attendee jobtitle];
    }
    
    NSURL *profileImageURL = [attendee displayImageURL];
    if (profileImageURL)
    {
        [contactCard.attendeeImageView sd_setImageWithURL:profileImageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            contactCard.hideImage = NO;
        }];
    }
    
    NSString *firstName = attendee.first_name;
    NSString *lastName = attendee.last_name.length ? [NSString stringWithFormat:@"%@.",[attendee.last_name substringToIndex:1]] : @"";
    
    contactCard.initialsLabel.text = [NSString stringWithFormat:@"%@%@",
                               firstName.length ? [firstName substringToIndex:1] : @"",
                               lastName.length ? [lastName substringToIndex:1] : @""];
}

- (MTPAttendeeContactCard *)createContactCard
{
    MTPAttendeeContactCard *card = (MTPAttendeeContactCard *)[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([MTPAttendeeContactCard class]) owner:self options:nil] firstObject];
    card.delegate = self;
    card.translatesAutoresizingMaskIntoConstraints = NO;
    
    return card;
}

- (void)setupConstraints:(MTPAttendeeContactCard *)card parent:(UIView *)parentView
{
    [parentView addSubview:card];
    
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:card attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:card attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|[card]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(card)]];
    
    if ([[parentView constraints] containsObject:self.topConstraint])
    {
        [parentView removeConstraint:self.topConstraint];
    }
    
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:card attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [parentView addConstraint:topConstraint];
    self.topConstraint = topConstraint;
}

#pragma mark - Protocol Conformance
#pragma mark MTPAttendeeContactCard Delegate
- (void)attendeeCardDidViewSharedInterests:(MTPAttendeeContactCard *)attendeeCard
{
    [self.navigationRouter pushPage:[NSURL URLWithString:[NSString stringWithFormat:@"mp://pushPage?path=\'%@\'",[NSString sharedInterests:self.displayedAttendee.user_id]]]];
    [attendeeCard removeFromSuperview];
    self.topConstraint = nil;
}

- (void)attendeeCardDidSparkConversation:(MTPAttendeeContactCard *)attendeeCard
{
    [self.navigationRouter pushPage:[NSURL URLWithString:[NSString stringWithFormat:@"mp://pushPage?path=\'%@\'",[NSString chat:self.displayedAttendee.user_id]]]];
    [attendeeCard removeFromSuperview];
    self.topConstraint = nil;
}

- (void)attendeeCardDidViewProfile:(MTPAttendeeContactCard *)attendeeCard
{
    [self.navigationRouter pushPage:[NSURL URLWithString:[NSString stringWithFormat:@"mp://pushPage?path=\'%@\'",[NSString attendeeProfile:self.displayedAttendee.user_id]]]];
    [attendeeCard removeFromSuperview];
    self.topConstraint = nil;
}

- (void)attendeeCardDidConnect:(MTPAttendeeContactCard *)attendeeCard
{
    [self.navigationRouter openQRCode];
    [attendeeCard removeFromSuperview];
    self.topConstraint = nil;
}

- (void)attendeeCardDidDismiss:(MTPAttendeeContactCard *)attendeeCard
{
    attendeeCard.background.alpha = 0;
    [self.presentationView layoutIfNeeded];
    [attendeeCard removeFromSuperview];
    self.topConstraint = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.presentationView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.contactCard = nil;
    }];
}
@end
