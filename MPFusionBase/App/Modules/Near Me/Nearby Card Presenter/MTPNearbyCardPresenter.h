//
//  MTPNearbyCardPresenter.h
//  I3-2017
//
//  Created by Michael Thongvanh on 4/4/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPNavigationRouter,User,MTPMatchProfile;

@interface MTPNearbyCardPresenter : NSObject

- (void)setup:(UIView *)parentView navigationRouter:(MTPNavigationRouter *)navigationRouter;

- (void)showAttendeeCard:(User *)attendee match:(BOOL)isMatch;
- (void)showMatchAlert:(User *)attendee matchProfile:(MTPMatchProfile *)matchProfile;
- (void)showCompanyAlert:(User *)attendee;
- (BOOL)showingMatchAlert;

@end
