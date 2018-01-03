//
//  WKWebView+MTPHelpers.m
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 10/10/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "WKWebView+MTPHelpers.h"
#import "MTPAppSettingsKeys.h"

@implementation WKWebView (MTPHelpers)

- (void)mtp_requiresAutoLoginCompletion:(void(^)(BOOL requiresAutoLogin))completionHandler
{
    __block BOOL requiresAutoLogin = true;
    
    NSURL *url = [NSURL URLWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL]];
    
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:url];
    [cookies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSHTTPCookie class]])
        {
            NSHTTPCookie *cookie = (NSHTTPCookie *)obj;
            
            NSString *cookieName = cookie.name;
            if ([cookieName isEqualToString:@"LOGGEDIN"])
            {
                requiresAutoLogin = false;
                *stop = true;
            }
        }
    }];
    
    if (completionHandler)
    {
        completionHandler(requiresAutoLogin);
    }
}

@end
