//
//  MTPSpeakersListCell.m
//
//  Created by MeetingPlay on 8/8/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPSpeakersListCell.h"

@implementation MTPSpeakersListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.initialsLabel.layer.borderColor = [UIColor colorWithWhite:0.66 alpha:1].CGColor;
    self.initialsLabel.layer.borderWidth = 1;
    
    self.detailIndicator.tintColor = [UIColor colorWithWhite:0.5 alpha:1];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.imageView.image = nil;
}

@end
