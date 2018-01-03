//
//  MAMQuickLinksViewController+MTPNearbyHelper.h
//  MeetingPlay
//
//  Created by MeetingPlay on 4/4/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MAMQuickLinksViewController.h"

@interface MAMQuickLinksViewController (MTPNearbyHelper) <MTPAttendeeListCoordinatorDelegate>

- (void)setupNearbyAttendees;
- (void)updateNearby:(id)sender;
@end
