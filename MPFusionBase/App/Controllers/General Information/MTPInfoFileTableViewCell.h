//
//  MTPInfoFileTableViewCell.h
//  MPFusionBaseProject
//
//  Created by Admin on 8/27/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPAssetData;

@interface MTPInfoFileTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *assetNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *assetTypeLabel;

- (void)configureTableCell: (MTPAssetData *)assetData;

@end
