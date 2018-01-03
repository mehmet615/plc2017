//
//  NSObject+MTPModelValidation.h
//  GaylordHotels
//
//  Created by Michael Thongvanh on 5/3/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MTPModelValidation)

- (NSString *)mtp_stringValue;
- (NSNumber *)mtp_numberValue;
- (NSArray *)mtp_arrayValue;
- (NSDictionary *)mtp_dictionaryValue;

@end
