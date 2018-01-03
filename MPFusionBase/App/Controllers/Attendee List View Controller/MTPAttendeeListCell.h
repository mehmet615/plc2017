//
//  MTPAttendeeSectionCell.h
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 8/8/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTPAttendeeListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *ellipsisContainer;
@property (weak, nonatomic) IBOutlet UIView *ellipsisLabel;

@property (weak, nonatomic) IBOutlet UILabel *initialsLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;


@end
