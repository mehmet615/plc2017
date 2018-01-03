//
//  MAMConnectionsCollectionViewCell.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/16/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAMConnectionsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *connectionImageView;
@property (weak, nonatomic) IBOutlet UILabel *connectionNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *connectionNameTitle;
@property (weak, nonatomic) IBOutlet UILabel *connectionStatusLabel;

@property (weak, nonatomic) IBOutlet UIView *userDetailsBackground;


- (void)configureStatusButton:(NSString *)status shouldHide:(BOOL)shouldHide;
@end
