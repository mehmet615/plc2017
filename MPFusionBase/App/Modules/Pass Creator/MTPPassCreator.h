//
//  MTPPassCreator.h
//  ALLTECHONE
//
//  Created by MeetingPlay on 3/29/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PKPass,UIView,UIViewController;

@interface MTPPassCreator : NSObject

extern NSString *const MTP_RegPass_SerialNumber;

- (void)processPassRequest:(NSNumber *)userID feedbackView:(UIView *)feedbackView presentationTarget:(UIViewController *)presentationViewController;

@end
