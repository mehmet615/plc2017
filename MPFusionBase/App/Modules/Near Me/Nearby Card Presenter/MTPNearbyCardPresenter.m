//
//  MTPNearbyCardPresenter.m
//  I3-2017
//
//  Created by Michael Thongvanh on 4/4/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPNearbyCardPresenter.h"
#import "MTPNavigationRouter.h"
#import "MTPAttendeeCardPresenter.h"
#import "MTPMatchesAlertPresenter.h"
#import "MTPMatchProfile.h"
#import "User.h"

@interface MTPNearbyCardPresenter ()
@property (strong, nonatomic) MTPAttendeeCardPresenter *attendeeCardPresenter;
@property (strong, nonatomic) MTPMatchesAlertPresenter *matchesAlertPresenter;
@end

@implementation MTPNearbyCardPresenter

- (void)setup:(UIView *)parentView navigationRouter:(MTPNavigationRouter *)navigationRouter
{
    [self setupCardPresenter:parentView navigationRouter:navigationRouter];
    [self setupMatchAlertPresenter:parentView navigationRouter:navigationRouter];
}

- (void)setupCardPresenter:(UIView *)parentView navigationRouter:(MTPNavigationRouter *)navigationRouter
{
    MTPAttendeeCardPresenter *presenter = [MTPAttendeeCardPresenter new];
    presenter.presentationView = parentView;
    presenter.navigationRouter = navigationRouter;
    self.attendeeCardPresenter = presenter;
}

- (void)setupMatchAlertPresenter:(UIView *)parentView navigationRouter:(MTPNavigationRouter *)navigationRouter
{
    MTPMatchesAlertPresenter *presenter = [MTPMatchesAlertPresenter new];
    presenter.presentationView = parentView;
    presenter.navigationRouter = navigationRouter;
    self.matchesAlertPresenter = presenter;
}

- (void)showAttendeeCard:(User *)attendee match:(BOOL)isMatch
{
    [self.attendeeCardPresenter showCard:attendee match:isMatch completion:nil];
}

- (void)showMatchAlert:(User *)attendee matchProfile:(MTPMatchProfile *)matchProfile
{
    [self.matchesAlertPresenter showMatchAlert:attendee matchProfile:matchProfile completion:nil];
}

- (void)showCompanyAlert:(User *)attendee
{
    [self.matchesAlertPresenter showMatchAlert:attendee matchProfile:nil completion:nil];
}

- (BOOL)showingMatchAlert
{
    return self.matchesAlertPresenter.showingAlert;
}
@end
