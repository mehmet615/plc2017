//
//  MTPPhotoPickerCell.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/21/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPPhotoPickerCell.h"

@implementation MTPPhotoPickerCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (self)
    {
        self.cameraLabel.font = [UIFont fontWithName:@"FontAwesome" size:50];
        self.cameraLabel.textAlignment = NSTextAlignmentCenter;
        self.cameraLabel.textColor = [UIColor blackColor];
        self.cameraLabel.text = @"\uf083";
    }
}

@end
