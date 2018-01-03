//
//  MTPSpeakersListCell.h
//
//  Created by MeetingPlay on 8/8/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTPSpeakersListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *ellipsisContainer;
@property (weak, nonatomic) IBOutlet UIView *ellipsisLabel;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *initialsLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;


@property (weak, nonatomic) IBOutlet UIImageView *detailIndicator;
@end
