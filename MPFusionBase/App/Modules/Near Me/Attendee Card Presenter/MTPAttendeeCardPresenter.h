//
//  MTPAttendeeCardPresenter.h
//  CPC2016
//
//  Created by MeetingPlay on 11/22/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User,MTPAttendeeContactCard,MTPNavigationRouter;

@interface MTPAttendeeCardPresenter : NSObject

@property (strong, nonatomic) UIView *presentationView;
@property (strong, nonatomic) MTPNavigationRouter *navigationRouter;

- (void)loadAttendee:(User *)attendee card:(MTPAttendeeContactCard *)contactCard;
- (void)showCard:(User *)attendee match:(BOOL)isMatch completion:(void(^)(User *attendee))completionHandler;

@end
