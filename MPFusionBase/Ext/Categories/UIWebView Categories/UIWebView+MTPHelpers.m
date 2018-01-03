//
//  UIWebView+MTPHelpers.m
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 10/10/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "UIWebView+MTPHelpers.h"
#import "MTPAppSettingsKeys.h"

@implementation UIWebView (MTPHelpers)

- (BOOL)requiresAutoLogin
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
    
    return requiresAutoLogin;
}

@end
