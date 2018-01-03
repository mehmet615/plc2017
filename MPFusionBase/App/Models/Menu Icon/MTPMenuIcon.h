//
//  MTPMenuIcon.h
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/9/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

@interface MTPMenuIcon : NSObject

@property (nonatomic, strong) NSURL *iconURL;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, strong) NSString *resourceName;

@property (nonatomic, strong) NSURL *localURL;

@property (nonatomic, strong) NSString *fontAwesomeCode;

- (instancetype)initWithDictionary:(NSDictionary *)iconDictionary;
- (NSString *)fontAwesomeHexCode;
@end
