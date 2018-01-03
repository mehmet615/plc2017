//
//  MDCustomTransmitter.m
//  MarriottDigitalSummit
//
//  Created by Michael Thongvanh on 4/30/14.
//  Copyright (c) 2014 Grumble Apps. All rights reserved.
//

#import "MDCustomTransmitter.h"
#import "NSObject+MTPModelValidation.h"

@interface MDCustomTransmitter ()
@property (strong, readwrite, nonatomic) NSString *identifier;
@property (strong, readwrite, nonatomic) NSString *name;
@property (strong, readwrite, nonatomic) NSString *iconURL;
@property (assign, readwrite, nonatomic) GMBLBatteryLevel batteryLevel;
@property (assign, readwrite, nonatomic) NSInteger temperature;
@end

@implementation MDCustomTransmitter

- (void)fillValuesFrom:(GMBLBeacon *)transmitter
{
    self.name = transmitter.name;
    self.identifier = transmitter.identifier;
    self.iconURL = transmitter.iconURL;
    self.batteryLevel = transmitter.batteryLevel;
    self.temperature = transmitter.temperature;
}

- (void)fillValuesFromAPI:(NSDictionary *)apiBeaconData
{
    self.name = [apiBeaconData objectForKey:@"name"];
    self.accuracy = [apiBeaconData objectForKey:@"accuracy"];
    id beaconID = [apiBeaconData objectForKey:@"beacon_id"];
    self.identifier = [beaconID mtp_stringValue];
    
    self.minor = [[apiBeaconData objectForKey:@"minor"] mtp_numberValue];
    self.major = [[apiBeaconData objectForKey:@"major"] mtp_numberValue];
    
    self.minor = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"minor"]];
    self.major = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"major"]];
    self.proximity = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"proximity"]];
    self.rssi_exit = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"rssi_exit"]];
    self.rssi_entry = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"rssi_entry"]];
    self.longitude = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"longitude"]];
    self.latitude = [self changeEmptyStringToNil:[apiBeaconData objectForKey:@"latitude"]];
    
    self.beaconType = [apiBeaconData[@"beacon_type"] mtp_stringValue];
}

- (id)changeEmptyStringToNil:(id)possibleString {
    if ([possibleString isKindOfClass:[NSString class]]) {
        return nil;
    } else {
        return possibleString;
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _identifier = [aDecoder decodeObjectForKey:@"identifier"];
        _name = [aDecoder decodeObjectForKey:@"name"];
        _iconURL = [aDecoder decodeObjectForKey:@"iconURL"];
        
        _accuracy = [aDecoder decodeObjectForKey:@"accuracy"];
        _minor = [aDecoder decodeObjectForKey:@"minor"];
        _major = [aDecoder decodeObjectForKey:@"major"];
        _proximity = [aDecoder decodeObjectForKey:@"proximity"];
        _rssi_exit = [aDecoder decodeObjectForKey:@"rssi_exit"];
        _rssi_entry = [aDecoder decodeObjectForKey:@"rssi_entry"];
        _RSSI = [aDecoder decodeObjectForKey:@"RSSI"];
        _longitude = [aDecoder decodeObjectForKey:@"longitude"];
        _latitude = [aDecoder decodeObjectForKey:@"latitude"];
        
        _beaconType = [aDecoder decodeObjectForKey:@"beaconType"];;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.iconURL forKey:@"iconURL"];
    
    [aCoder encodeObject:self.accuracy forKey:@"accuracy"];
    [aCoder encodeObject:self.minor forKey:@"minor"];
    [aCoder encodeObject:self.major forKey:@"major"];
    [aCoder encodeObject:self.proximity forKey:@"proximity"];
    [aCoder encodeObject:self.rssi_exit forKey:@"rssi_exit"];
    [aCoder encodeObject:self.rssi_entry forKey:@"rssi_entry"];
    [aCoder encodeObject:self.RSSI forKey:@"RSSI"];
    [aCoder encodeObject:self.longitude forKey:@"longitude"];
    [aCoder encodeObject:self.latitude forKey:@"latitude"];
    [aCoder encodeObject:self.beaconType forKey:@"beaconType"];;
}

@end
