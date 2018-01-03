//
//  MTPPhotoPickerCell.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/21/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTPPhotoPickerCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *thumbnail;
@property (nonatomic, weak) IBOutlet UILabel *cameraLabel;
@end
    