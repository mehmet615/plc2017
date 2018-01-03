//
//  MTPMenuItemManager.m
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/17/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "MTPMenuItemManager.h"
#import "MTPMenuParser.h"
#import "MTPNavigationMenuLoader.h"
#import "MTPDLogDefine.h"
#import "MTPAppSettingsKeys.h"

@interface MTPMenuItemManager ()
@end

@implementation MTPMenuItemManager

- (NSDictionary *)loadMenuItems
{
    NSURL *updatedMainMenuURL = [self updatedMenuSaveURL];
    NSDictionary *menuItems = [NSDictionary dictionaryWithContentsOfURL:updatedMainMenuURL];
    if (menuItems.allKeys.count == 0)
    {
        // load from json
        NSURL *plistDefaultMenuItems = [[NSBundle mainBundle] URLForResource:@"MenuItems" withExtension:@"json"];
        
        NSError *error = nil;
        id menuItemsDictionary = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:plistDefaultMenuItems] options:NSJSONReadingAllowFragments error:&error];
        if (error)
        {
            DLog(@"\nserialization error %@",error);
        }
        else
        {
            menuItems = menuItemsDictionary;
        }
    }
    
    return menuItems;
}

- (void)parseMenuItems:(NSDictionary *)menuItemData
{
    MTPMenuParser *parser = [MTPMenuParser new];
    
    self.sideNavigationItems = [parser navigationItems:[menuItemData[@"sideNavigationItems"] objectForKey:@"navigation"]];
    self.homepageItems = [parser navigationItems:menuItemData[@"homePageMenuItems"]];
}

- (void)fetchMenuItemsForMeeting:(NSString *)meetingName menuFilename:(NSString *)remoteFilename completion:(void (^)(NSArray *, NSArray *, NSError *))completionHandler
{
    __weak typeof(&*self)weakSelf = self;
    
    [self.menuLoader fetchMeeting:meetingName updatedMenu:remoteFilename completionHandler:^(id responseObject, NSError *updateError)
     {
         if (updateError)
         {
             DLog(@"\nupdate error %@",updateError);
         }
         else
         {
             [weakSelf parseMenuItems:responseObject];
             
             NSMutableDictionary *menuItems = [NSMutableDictionary new];
             if (weakSelf.homepageItems.count)
             {
                 [menuItems setObject:weakSelf.homepageItems forKey:MTP_QuickLinksItems];
             }
             
             if (weakSelf.sideNavigationItems.count)
             {
                 [menuItems setObject:weakSelf.sideNavigationItems forKey:MTP_MainMenuItems];
             }
             
             [[NSNotificationCenter defaultCenter] postNotificationName:MTP_NavigationMenuDidUpdate
                                                                 object:nil
                                                               userInfo:menuItems];
         }
         
         if (completionHandler)
         {
             completionHandler(weakSelf.sideNavigationItems,weakSelf.homepageItems,updateError);
         }
     }];
}

- (NSURL *)updatedMenuSaveURL
{
    return [self.menuLoader updatedMenuSaveURL];
}

- (MTPNavigationMenuLoader *)menuLoader
{
    if (_menuLoader == nil)
    {
        _menuLoader = [MTPNavigationMenuLoader new];
    }
    return _menuLoader;
}

































- (NSDictionary *)loadTestJSON
{
    NSURL *menuItemsTestURL = [[NSBundle mainBundle] URLForResource:@"MenuItems"
                                                      withExtension:@"json"];
    
    NSInputStream *inputStream = [NSInputStream inputStreamWithURL:menuItemsTestURL];
    [inputStream open];
    
    NSError *error;
    id menuItemsJSON = [NSJSONSerialization JSONObjectWithStream:inputStream
                                                         options:NSJSONReadingAllowFragments
                                                           error:&error];
    [inputStream close];
    
    if (error)
    {
        NSLog(@"error %@",error);
    }
    
    return menuItemsJSON;
}

@end
