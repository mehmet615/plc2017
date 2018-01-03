//
//  NSURLSession+MTPCategory.h
//  GaylordHotels
//
//  Created by Michael Thongvanh on 5/8/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLSession (MTPCategory)

+ (NSString *)bundleIdentifier;

+ (NSString *)eventBaseHTTPURL;

+ (NSMutableURLRequest *)defaultRequestMethod:(NSString *)methodType
                                          URL:(NSString *)url
                                   parameters:(NSDictionary *)parameters;

+ (id)serializeJSONData:(NSData *)data
               response:(NSURLResponse *)response
                  error:(NSError *)networkError;



@end
