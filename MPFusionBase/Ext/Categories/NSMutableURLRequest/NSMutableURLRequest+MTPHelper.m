//
//  NSMutableURLRequest+MTPHelper.m
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/21/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "NSMutableURLRequest+MTPHelper.h"
#import "MTPAppSettingsKeys.h"
#import <UIKit/UIDevice.h>
#import <UIKit/UIScreen.h>

@implementation NSMutableURLRequest (MTPHelper)

+ (NSMutableURLRequest *)mtp_defaultRequestMethod:(NSString *)methodType URL:(NSString *)url parameters:(NSDictionary *)parameters
{
    if (url.length == 0) {
        return nil;
    }
    
    NSMutableURLRequest *defaultRequest = [[NSMutableURLRequest alloc]
                                           initWithURL:[NSURL URLWithString:url]
                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                           timeoutInterval:[[[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_URLRequestDefaultTimeoutInterval] integerValue]];
    
    defaultRequest.HTTPShouldHandleCookies = YES;
    [defaultRequest setHTTPMethod:methodType.uppercaseString];
    
    [[self eventHTTPHeaders] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [defaultRequest setValue:obj forHTTPHeaderField:key];
    }];
    
    NSSet *queryStringEncodingMethods = [NSSet setWithObjects:@"GET",@"HEAD",@"DELETE", nil];
    if (![queryStringEncodingMethods containsObject:defaultRequest.HTTPMethod.uppercaseString]) {
        if (parameters) {
            if (![defaultRequest valueForHTTPHeaderField:@"Content-Type"]) {
                [defaultRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            }
            
            NSError *serializationError = nil;
            [defaultRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&serializationError]];
            
            if (serializationError) {
                NSLog(@"%s [%s]: Line %i]\nSerialization Error %@",
                      __FILE__,__PRETTY_FUNCTION__,__LINE__,
                      serializationError);
                return nil;
            }
        }
    } else {
        __block NSMutableArray *queryStrings = [NSMutableArray array];
        [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [queryStrings addObject:[NSString stringWithFormat:@"%@=%@",key,obj]];
        }];
        
        NSString *query = [queryStrings componentsJoinedByString:@"&"];
        if (query.length > 0)
        {
            defaultRequest.URL = [NSURL URLWithString:[[defaultRequest.URL absoluteString] stringByAppendingFormat:defaultRequest.URL.query ? @"&%@" : @"?%@", query]];
        }
    }
    
    return defaultRequest;
}

+ (NSDictionary *)eventHTTPHeaders
{
    NSMutableDictionary *httpHeaders = [NSMutableDictionary dictionary];
    [httpHeaders setObject:[self eventHTTPUserAgent] forKey:@"User-Agent"];
    [httpHeaders setObject:[[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_XAuthToken] forKey:@"X-Authentication-Token"];
    [httpHeaders setObject:@"application/json" forKey:@"Accept"];
    
    return httpHeaders;
}

+ (NSString *)eventHTTPUserAgent
{
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)",
                           [self bundleIdentifier],
                           [self bundleVersion],
                           [[UIDevice currentDevice] model],
                           [[UIDevice currentDevice] systemVersion],
                           [[UIScreen mainScreen] scale]];
    return userAgent;
}

+ (NSString *)bundleIdentifier
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ? nil : [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey];
}

+ (NSString *)bundleVersion
{
    return (__bridge id)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(),
                                                             kCFBundleVersionKey) ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey];
}

+ (NSString *)eventBaseHTTPURL
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL];
}

@end
