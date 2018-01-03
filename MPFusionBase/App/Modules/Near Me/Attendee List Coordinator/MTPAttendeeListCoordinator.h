//
//  MTPAttendeeListCoordinator.h
//  CPC2016
//
//  Created by MeetingPlay on 11/22/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class User;

@protocol MTPAttendeeListCoordinatorDelegate <NSObject>
- (void)attendeeCoordinatorDidSelectAttendee:(User *)attendee;
@end

@interface MTPAttendeeListCoordinator : NSObject <UICollectionViewDelegate,UICollectionViewDataSource>

@property (weak, nonatomic) id<MTPAttendeeListCoordinatorDelegate> attendeeDelegate;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (readonly, strong, nonatomic) NSArray *attendees;
- (void)loadAttendees:(NSArray *)attendees;

@end

@interface MTPQuickLinkAttendeeCell : UICollectionViewCell
@property (assign, nonatomic) BOOL showImage;
@property (weak, nonatomic) IBOutlet UIImageView *attendeeImageView;
@property (weak, nonatomic) IBOutlet UILabel *attendeeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *initialsLabel;
@end
