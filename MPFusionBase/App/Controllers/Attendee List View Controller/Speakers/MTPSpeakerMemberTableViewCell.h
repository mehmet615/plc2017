//
//  MTPSpeakerMemberTableViewCell.h
//  MPFusionBaseProject
//
//  Created by Admin on 8/18/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTPSpeakerMemberTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *imageContentView;
@property (weak, nonatomic) IBOutlet UILabel *imageLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailTextView;

@property (weak, nonatomic) UIFont *detailLabelFont;

- (void)configureCell:(NSString *)string font:(UIFont *)font isCompany:(BOOL)isCompany;

@end
