//
//  MAMQuickLinksViewController+MTPNearbyHelper.m
//  MeetingPlay
//
//  Created by MeetingPlay on 4/4/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MAMQuickLinksViewController+MTPNearbyHelper.h"
#import "MAMBaseViewController.h"

#import "MTPMatchCoordinator.h"
#import "MTPNearbyCoordinator.h"
#import "MTPAttendeeListCoordinator.h"
#import "MTPNearbyCardPresenter.h"
#import "MTPNavigationRouter.h"
#import "MTPAPIDataInitializer.h"
#import "User.h"
#import "MTPMatchProfile.h"

#import "MTPDLogDefine.h"

@implementation MAMQuickLinksViewController (MTPNearbyHelper)

- (void)setupNearbyAttendees
{
    self.attendeeListCoordinator = [MTPAttendeeListCoordinator new];
    self.attendeeListCoordinator.collectionView = self.attendeesCollectionView;
    self.attendeesCollectionView.delegate = self.attendeeListCoordinator;
    self.attendeesCollectionView.dataSource = self.attendeeListCoordinator;
    
    self.attendeeListCoordinator.attendeeDelegate = self;
    
    MTPMatchCoordinator *matchCoordinator = self.navigationRouter.dataInitializer.matchCoordinator;
    if (matchCoordinator == nil)
    {
        matchCoordinator = [MTPMatchCoordinator new];
        self.matchCoordinator = matchCoordinator;
    }

    [matchCoordinator matches:self.navigationRouter.currentUser.user_id completion:^(NSArray *matches, NSError *error)
     {
         if (error)
         {
             DLog(@"\nerror %@",error);
         }
         
         self.matches = matches;
         
         if (self.nearbyUpdateTimer)
         {
             dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                 [self.nearbyCoordinator checkNearbyEnabled:^(BOOL enabled, NSString *message) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         if (enabled)
                         {
                             NSArray *attendees = [self.nearbyCoordinator nearbyUsers:self.navigationRouter.currentUser.user_id];
                             self.noAttendeesLabel.hidden = [attendees count];
                             self.noAttendeesLabel.text = message.length ? message : @"NO ONE AROUND YOU? CHECK YOUR BLUETOOTH SETTINGS";
                             
                             [self.attendeeListCoordinator loadAttendees:attendees];
                             [self.attendeeListCoordinator.collectionView reloadData];
                         }
                         else
                         {
                             self.noAttendeesLabel.hidden = NO;
                             self.noAttendeesLabel.text = message.length ? message : @"CHECK BACK LATER";
                         }
                     });
                 }];
                 [self.nearbyUpdateTimer fire];
             });
         }
     }];
    
    [matchCoordinator sponsorMatches:self.navigationRouter.currentUser.user_id completion:nil];
}

- (void)updateNearby:(id)sender
{
    [self.nearbyCoordinator checkNearbyEnabled:^(BOOL enabled, NSString *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (enabled)
            {
                NSArray *attendees = [self.nearbyCoordinator nearbyUsers:self.navigationRouter.currentUser.user_id];
                self.noAttendeesLabel.hidden = [attendees count];
                self.noAttendeesLabel.text = message.length ? message : @"NO ONE AROUND YOU? CHECK YOUR BLUETOOTH SETTINGS";
                
                [self.attendeeListCoordinator loadAttendees:attendees];
                [self.attendeeListCoordinator.collectionView reloadData];
                self.attendeesCollectionView.hidden = NO;
            }
            else
            {
                self.attendeesCollectionView.hidden = YES;
                self.noAttendeesLabel.hidden = NO;
                self.noAttendeesLabel.text = message.length ? message : @"CHECK BACK LATER";
            }
        });
    }];
}

#pragma mark - Protocol Conformance
#pragma mark MTPAttendeeListCoordinator Delegate
- (void)attendeeCoordinatorDidSelectAttendee:(User *)attendee
{
    id parentViewController = self.navigationController.parentViewController;
    if ([parentViewController isKindOfClass:[MAMBaseViewController class]])
    {
        MAMBaseViewController *base = (MAMBaseViewController *)parentViewController;

        BOOL match = [self.matchCoordinator isMatch:attendee.user_id];
        [base.nearbyCardPresenter showAttendeeCard:attendee match:match];
    }
}
@end
