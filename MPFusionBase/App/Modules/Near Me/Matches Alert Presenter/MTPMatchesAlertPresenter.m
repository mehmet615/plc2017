//
//  MTPMatchesAlertPresenter.m
//  CPC2016
//
//  Created by Michael Thongvanh on 11/30/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPMatchesAlertPresenter.h"
#import "MTPMatchesAlertView.h"
#import "MTPMatchProfile.h"
#import "User+Helpers.h"
#import "MTPNavigationRouter.h"
#import "UIImageView+WebCache.h"
#import "NSString+MTPWebViewURL.h"

@interface MTPMatchesAlertPresenter () <MTPMatchesAlertDelegate>
@property (strong, nonatomic) MTPMatchesAlertView *matchAlertView;
@property (strong, nonatomic) NSLayoutConstraint *topConstraint;
@property (strong, nonatomic) User *displayedAttendee;
@end

@implementation MTPMatchesAlertPresenter

- (void)showMatchAlert:(User *)attendee matchProfile:(MTPMatchProfile *)matchProfile completion:(void(^)(User *attendee))completionHandler;
{
    if (attendee)
    {
        self.showingAlert = YES;
        self.displayedAttendee = attendee;
        
        MTPMatchesAlertView *matchAlert = self.matchAlertView;
        if (matchAlert == nil)
        {
            matchAlert = [self createMatchAlert:matchProfile];
            self.matchAlertView = matchAlert;
        }
        [self setupConstraints:matchAlert parent:self.presentationView];
        [self loadAttendee:attendee matchAlert:matchAlert profile:matchProfile];
        
        BOOL showSharedInterest = YES;
        NSString *subtitleText = @"A match from your network is near you!";
        if (matchProfile == nil)
        {
//            showSharedInterest = NO;
//            subtitleText = @"Your Partner/Coach is Near You!";
        }
        
        matchAlert.viewInterestsButton.hidden = !showSharedInterest;
        matchAlert.subtitleLabel.text = subtitleText;
        
        matchAlert.background.alpha = 0;
        
        [self.presentationView layoutIfNeeded];
        
        self.topConstraint.constant = -CGRectGetHeight(self.presentationView.frame);
        
        [UIView animateWithDuration:0.3 animations:^{
            [self.presentationView layoutIfNeeded];
            matchAlert.background.alpha = 0.5;
        } completion:^(BOOL finished) {
            if (completionHandler)
            {
                completionHandler(attendee);
            }
            NSLog(@"\ndebugging message %@",self);
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

- (void)loadAttendee:(User *)attendee matchAlert:(MTPMatchesAlertView *)matchAlertView profile:(MTPMatchProfile *)matchProfile
{
    matchAlertView.attendeeImageView.image = nil;
    matchAlertView.attendeeImageView.hidden = YES;
    
    NSString *firstname = attendee.first_name.length > 0 ? attendee.first_name : @"";
    NSString *lastname = attendee.last_name.length > 0 ? attendee.last_name : @"";
    matchAlertView.attendeeNameLabel.text = [NSString stringWithFormat:@"%@\n%@",firstname.uppercaseString,lastname.uppercaseString];
    
    NSURL *profileImageURL = [attendee displayImageURL];
    if (profileImageURL)
    {
        [matchAlertView.attendeeImageView sd_setImageWithURL:profileImageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            matchAlertView.attendeeImageView.hidden = NO;
        }];
    }
    
    NSString *firstName = attendee.first_name;
    NSString *lastName = attendee.last_name.length ? [NSString stringWithFormat:@"%@.",[attendee.last_name substringToIndex:1]] : @"";
    
    matchAlertView.initialsLabel.text = [NSString stringWithFormat:@"%@%@",
                                      firstName.length ? [firstName substringToIndex:1] : @"",
                                      lastName.length ? [lastName substringToIndex:1] : @""];
}

#pragma mark - Protocol Conformance
#pragma mark MTPMatchesAlert Delegate
- (void)matchesAlertDidViewSharedInterests:(MTPMatchesAlertView *)matchesAlert
{
    NSString *interestURL = [NSString stringWithFormat:@"mp://pushPage?path=\'%@'",[NSString sharedInterests:self.displayedAttendee.user_id]];
    [self.navigationRouter pushPage:[NSURL URLWithString:interestURL]];
    [matchesAlert removeFromSuperview];
    self.topConstraint = nil;
    self.matchAlertView = nil;
    
    self.showingAlert = NO;
}

- (void)matchesAlertDidSparkConversation:(MTPMatchesAlertView *)matchesAlert
{
    NSString *chatURL = [NSString stringWithFormat:@"mp://pushPage?path=\'%@'",[NSString chat:self.displayedAttendee.user_id]];
    [self.navigationRouter pushPage:[NSURL URLWithString:chatURL]];
    [matchesAlert removeFromSuperview];
    self.topConstraint = nil;
    self.matchAlertView = nil;
    
    self.showingAlert = NO;
}

- (void)matchesAlertDidConnect:(MTPMatchesAlertView *)matchesAlert
{
    [self.navigationRouter openQRCode];
    [matchesAlert removeFromSuperview];
    self.topConstraint = nil;
    self.matchAlertView = nil;
    
    self.showingAlert = NO;
}

- (void)matchesAlertDidDismiss:(MTPMatchesAlertView *)matchesAlert
{
    matchesAlert.background.alpha = 0;
    [self.presentationView layoutIfNeeded];
    self.topConstraint = nil;
    
    [matchesAlert removeFromSuperview];
    self.matchAlertView = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.presentationView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.showingAlert = NO;
    }];
}

- (MTPMatchesAlertView *)createMatchAlert:(MTPMatchProfile *)matchProfile
{
    MTPMatchesAlertView *matchAlert = (MTPMatchesAlertView *)[[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([MTPMatchesAlertView class]) owner:self options:nil] firstObject];
    matchAlert.delegate = self;
    matchAlert.translatesAutoresizingMaskIntoConstraints = NO;
    
    return matchAlert;
}

- (void)setupConstraints:(MTPMatchesAlertView *)matchAlert parent:(UIView *)parentView
{
    [parentView addSubview:matchAlert];
    
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:matchAlert attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [parentView addConstraint:[NSLayoutConstraint constraintWithItem:matchAlert attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[matchAlert]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(matchAlert)]];
    
    if ([[parentView constraints] containsObject:self.topConstraint])
    {
        [parentView removeConstraint:self.topConstraint];
    }
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:matchAlert attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
    [parentView addConstraint:topConstraint];
    self.topConstraint = topConstraint;
}

@end
