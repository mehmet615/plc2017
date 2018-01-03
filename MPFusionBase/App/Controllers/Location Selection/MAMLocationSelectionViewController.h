//
//  MAMLocationSelectionViewController.h
//  HPEEvents
//
//  Created by Michael Thongvanh on 10/6/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAMLocationSelectionViewController;

@protocol MAMLocationSelectionDelegate <NSObject>

- (void)locationSelector:(MAMLocationSelectionViewController *)locationSelector didSelectLocation:(NSDictionary *)locationData;

@end

@interface MAMLocationSelectionViewController : UIViewController

extern NSString *const kLocationsListCell;


@property (weak, nonatomic) id <MAMLocationSelectionDelegate> locationSelectionDelegate;

@property (weak, nonatomic) IBOutlet UIView *languageSelectionContainer;
@property (weak, nonatomic) IBOutlet UILabel *headerTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *tableContainer;

@end


@interface MAMLocationsListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *eventIconImage;

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventDateLabel;
@property (nonatomic, weak) IBOutlet UILabel *eventLocationLabel;

@property (weak, nonatomic) IBOutlet UILabel *customAccessoryLabel;
@property (weak, nonatomic) IBOutlet UIView *contentContainer;

@end