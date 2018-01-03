//
//  MTPMatchesAlertPresenter.h
//  CPC2016
//
//  Created by Michael Thongvanh on 11/30/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User,MTPMatchesAlertView,MTPNavigationRouter,MTPMatchProfile;

@interface MTPMatchesAlertPresenter : NSObject

@property (strong, nonatomic) UIView *presentationView;
@property (strong, nonatomic) MTPNavigationRouter *navigationRouter;

@property (assign, nonatomic) BOOL showingAlert;

- (void)showMatchAlert:(User *)attendee matchProfile:(MTPMatchProfile *)matchProfile completion:(void(^)(User *attendee))completionHandler;;
@end
