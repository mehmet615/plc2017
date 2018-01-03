//
//  NSObject+MTPModelValidation.m
//  GaylordHotels
//
//  Created by Michael Thongvanh on 5/3/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "NSObject+MTPModelValidation.h"

@implementation NSObject (MTPModelValidation)

- (NSString *)mtp_stringValue
{
    if ([self isKindOfClass:[NSString class]])
    {
        return (NSString *)self;
    }
    else
    {
        return [NSString stringWithFormat:@"%@",[self description]];
    }
}

- (NSNumber *)mtp_numberValue
{
    NSNumber *numberValue = [self numberFromValue];
    return numberValue;
}

- (NSNumber *)numberFromValue
{
    if ([self isKindOfClass:[NSNumber class]])
    {
        return (NSNumber *)self;
    }
    else
    {
        NSString *stringRepresentation = [NSString stringWithFormat:@"%@",[self description]];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        NSNumber *numberValue = [formatter numberFromString:stringRepresentation];
        return numberValue;
    }
}

- (NSArray *)mtp_arrayValue
{
    return [self isKindOfClass:[NSArray class]] ? (NSArray *)self : nil;
}

- (NSDictionary *)mtp_dictionaryValue
{
    return [self isKindOfClass:[NSDictionary class]] ? (NSDictionary *)self : nil;
}

@end
