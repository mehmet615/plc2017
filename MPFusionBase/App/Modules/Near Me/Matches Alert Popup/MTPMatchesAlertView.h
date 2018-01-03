//
//  MTPMatchesAlertView.h
//  CPC2016
//
//  Created by Michael Thongvanh on 11/30/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPMatchesAlertView;

@protocol MTPMatchesAlertDelegate <NSObject>
- (void)matchesAlertDidViewSharedInterests:(MTPMatchesAlertView *)matchesAlert;
- (void)matchesAlertDidSparkConversation:(MTPMatchesAlertView *)matchesAlert;
- (void)matchesAlertDidConnect:(MTPMatchesAlertView *)matchesAlert;
- (void)matchesAlertDidDismiss:(MTPMatchesAlertView *)matchesAlert;
@end

@interface MTPMatchesAlertView : UIView

@property (weak, nonatomic) id<MTPMatchesAlertDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *background;
@property (weak, nonatomic) IBOutlet UIView *contentContainer;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *initialsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *attendeeImageView;
@property (weak, nonatomic) IBOutlet UILabel *attendeeNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *viewInterestsButton;
@property (weak, nonatomic) IBOutlet UIButton *sparkButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;

@end
