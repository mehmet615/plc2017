//
//  MTPMainMenuTogglable.h
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 12/14/15.
//  Copyright © 2015 MeetingPlay. All rights reserved.
//

#ifndef MTPMainMenuTogglable_h
#define MTPMainMenuTogglable_h

@protocol MTPMainMenuTogglable <NSObject>
@optional
- (void)topViewControllerShouldToggleMenu:(id)sender;
@end

#endif /* MTPMainMenuTogglable_h */
