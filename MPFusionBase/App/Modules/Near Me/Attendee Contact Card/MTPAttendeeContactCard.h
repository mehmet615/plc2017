//
//  MTPAttendeeContactCard.h
//  CPC2016
//
//  Created by Michael Thongvanh on 11/22/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPAttendeeContactCard;

@protocol MTPAttendeeContactCardDelegate <NSObject>
- (void)attendeeCardDidViewSharedInterests:(MTPAttendeeContactCard *)attendeeCard;
- (void)attendeeCardDidSparkConversation:(MTPAttendeeContactCard *)attendeeCard;
- (void)attendeeCardDidViewProfile:(MTPAttendeeContactCard *)attendeeCard;
- (void)attendeeCardDidConnect:(MTPAttendeeContactCard *)attendeeCard;
- (void)attendeeCardDidDismiss:(MTPAttendeeContactCard *)attendeeCard;
@end

@interface MTPAttendeeContactCard : UIView

@property (weak, nonatomic) id<MTPAttendeeContactCardDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIView *background;
@property (weak, nonatomic) IBOutlet UIView *contentContainer;

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (weak, nonatomic) IBOutlet UILabel *initialsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *attendeeImageView;
@property (assign, nonatomic) BOOL hideImage;
@property (weak, nonatomic) IBOutlet UILabel *attendeeNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailsMainLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsSubLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UIButton *topButton;
@property (weak, nonatomic) IBOutlet UIButton *middleButton;
@property (weak, nonatomic) IBOutlet UIButton *bottomButton;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;

- (void)showJobTitle;
- (void)hideJobTitle;

- (IBAction)pressedClose:(id)sender;
- (IBAction)pressedViewShared:(id)sender;
- (IBAction)pressedSparkConversation:(id)sender;
- (IBAction)pressedViewProfile:(id)sender;
- (IBAction)pressedConnect:(id)sender;

@end
