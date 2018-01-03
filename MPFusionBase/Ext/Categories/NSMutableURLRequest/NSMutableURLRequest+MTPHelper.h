//
//  NSMutableURLRequest+MTPHelper.h
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/21/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (MTPHelper)

+ (NSMutableURLRequest *)mtp_defaultRequestMethod:(NSString *)methodType URL:(NSString *)url parameters:(NSDictionary *)parameters;

@end
