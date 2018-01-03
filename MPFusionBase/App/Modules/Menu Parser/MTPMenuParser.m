//
//  MTPMenuParser.m
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/16/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "MTPMenuParser.h"
#import "MTPMenuItem.h"

@interface MTPMenuParser ()

@end


@implementation MTPMenuParser

- (NSArray *)navigationItems:(NSArray *)navigationItemDictionaries
{
    NSMutableArray *menuItems = [NSMutableArray new];
    
    for (NSDictionary *newMenuItem in navigationItemDictionaries)
    {
        MTPMenuItem *menuItem = [MTPMenuItem createMenuItems:newMenuItem];
        if (menuItem)
        {
            [menuItems addObject:menuItem];
        }
    }
    
    return menuItems;
}











































@end
