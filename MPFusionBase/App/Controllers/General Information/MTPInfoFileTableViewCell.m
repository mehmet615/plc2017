//
//  MTPInfoFileTableViewCell.m
//  MPFusionBaseProject
//
//  Created by Admin on 8/27/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPInfoFileTableViewCell.h"
#import "MTPAssetData.h"

@implementation MTPInfoFileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureTableCell: (MTPAssetData *)assetData {
    self.assetNameLabel.text = assetData.assetName;
    self.assetTypeLabel.text = [NSString stringWithFormat:@"File Type: %@", assetData.assetExtension];
}

@end
