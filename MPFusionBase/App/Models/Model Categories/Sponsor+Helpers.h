//
//  Sponsor+Helpers.h
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/7/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "Sponsor.h"
#import "MAMConnectionDetailsViewController.h"

@interface Sponsor (Helpers) <MTPConnectionDetailsDisplayable>

+ (instancetype)sponsorName:(NSString*)name photo:(NSURL*)photoUrl;
+ (void)populateSponsor:(Sponsor*)sponsor withJSON:(NSDictionary*)jsonObject;

@end
