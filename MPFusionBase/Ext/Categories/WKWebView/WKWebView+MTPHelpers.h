//
//  WKWebView+MTPHelpers.h
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 10/10/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (MTPHelpers)
- (void)mtp_requiresAutoLoginCompletion:(void(^)(BOOL requiresAutoLogin))completionHandler;
@end
