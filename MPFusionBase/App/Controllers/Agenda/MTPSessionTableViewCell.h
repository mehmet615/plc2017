//
//  MTPSessionTableViewCell.h
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 5/17/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTPSessionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *timeContainer;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelHeight;

@property (weak, nonatomic) IBOutlet UILabel *sessionTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *sessionTeaserLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sessionTeaserHeight;

// session time
@property (weak, nonatomic) IBOutlet UIView *sessionTimeContainer;
@property (weak, nonatomic) IBOutlet UILabel *sessionTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sessionTimeContainerHeight;

// session location
@property (weak, nonatomic) IBOutlet UIView *sessionLocationContainer;
@property (weak, nonatomic) IBOutlet UILabel *sessionLocationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sessionLocationContainerHeight;

// session track
@property (weak, nonatomic) IBOutlet UIView *sessionTrackContainer;
@property (weak, nonatomic) IBOutlet UIButton *sessionTrackButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sessionTrackContainerHeight;

@property (weak, nonatomic) IBOutlet UILabel *ellipsisLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sessionEllipsisLabel;

@end
