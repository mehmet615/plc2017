//
//  UIViewController+NavigationItemSetup.m
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 12/2/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "UIViewController+NavigationItemSetup.h"
#import "UIButton+MTPNavigationBar.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "MTPAppSettingsKeys.h"
#import "MTPSideMenuTogglable.h"

@implementation UIViewController (NavigationItemSetup)

- (void)setupNavigationItem:(BOOL)qrEnabled
{
//    [[self navigationItem] setTitleView:[UIButton navigationBarLogo:CGRectGetHeight(self.navigationController.navigationBar.frame)]];
    [self setupSideMenuButton];
    
    if (qrEnabled)
    {
        [self setupQRButton];
    }
}

- (void)setupLeftBarButton:(UIBarButtonItem *)leftBarButton
{
    if ([self respondsToSelector:leftBarButton.action])
    {
        [[self navigationItem] setLeftBarButtonItem:leftBarButton];
    }
    else
    {
        DLog(@"\ndoesnt respond to selector %@", NSStringFromSelector(leftBarButton.action));
    }
}

- (UIBarButtonItem *)customBarButtonItem:(SEL)customAction
{
    UIBarButtonItem *customBarItem = [UIButton toggleMainMenuButton:nil
                                                             target:self
                                                           selector:customAction];
    [customBarItem setTarget:self];
    [customBarItem setAction:customAction];
    
    return customBarItem;
}

- (void)setupQRButton
{
    SEL openQRCode = @selector(openQRCode:);
    
    if ([[[self.userDefaults objectForKey:MTP_BaseOptions] objectForKey:MTP_QREnabled] boolValue])
    {
        if ([self.parentViewController.parentViewController respondsToSelector:openQRCode])
        {
            NSMutableArray *rightButtonItems = [NSMutableArray arrayWithArray:[[self navigationItem] rightBarButtonItems]];
            UIButton *qrButton = [self qrButton:openQRCode];
            UIBarButtonItem *qrBarItem = [[UIBarButtonItem alloc] initWithCustomView:qrButton];
            [rightButtonItems addObject:qrBarItem];
            
            [[self navigationItem] setRightBarButtonItems:rightButtonItems];
        }
        else if ([self.parentViewController.parentViewController respondsToSelector:openQRCode])
        {
            NSMutableArray *rightButtonItems = [NSMutableArray arrayWithArray:[[self navigationItem] rightBarButtonItems]];
            UIButton *qrButton = [self qrButton:openQRCode];
            UIBarButtonItem *qrBarItem = [[UIBarButtonItem alloc] initWithCustomView:qrButton];
            [rightButtonItems addObject:qrBarItem];
            
            [[self navigationItem] setRightBarButtonItems:rightButtonItems];
        }
        else
        {
            DLog(@"\ndoesnt respond to selector %@", NSStringFromSelector(openQRCode));
        }
    }
    else
    {
//        DLog(@"\nQR is disabled in user defaults settings");
    }
}

- (UIButton *)qrButton:(SEL)buttonAction
{
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    //    [menuButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:21.f]];
    [menuButton setFrame:CGRectMake(0, 0, menuButtonSize, menuButtonSize)];
    [menuButton setImage:[UIImage imageNamed:@"qrIcon"] forState:UIControlStateNormal];
    
    [menuButton addTarget:self.parentViewController.parentViewController
                   action:buttonAction
         forControlEvents:UIControlEventTouchUpInside];
    
    return menuButton;
}

- (void)setupSideMenuButton
{
    UIViewController *parentViewController = nil;
    
    if ([self.parentViewController.parentViewController respondsToSelector:@selector(toggleSideMenu:)])
    {
        parentViewController = self.parentViewController.parentViewController;
    }
    else if ([self.parentViewController respondsToSelector:@selector(toggleSideMenu:)])
    {
        parentViewController = self.parentViewController;
    }
    
    if (parentViewController)
    {
        NSMutableArray *rightButtonItems = [NSMutableArray arrayWithArray:[[self navigationItem] rightBarButtonItems]];
        UIButton *profileButton = [self profileButton:@selector(toggleSideMenu:) target:parentViewController];
        UIBarButtonItem *profileBarItem = [[UIBarButtonItem alloc] initWithCustomView:profileButton];
        [rightButtonItems addObject:profileBarItem];
        
        [[self navigationItem] setRightBarButtonItems:rightButtonItems];
    }
}

- (UIButton *)profileButton:(SEL)action target:(UIViewController *)parentViewController
{
    UIButton *menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [menuButton setFrame:CGRectMake(0, 0, menuButtonSize, menuButtonSize)];
    [menuButton setImage:[UIImage imageNamed:@"userSettingsIcon"] forState:UIControlStateNormal];
    
    [menuButton addTarget:parentViewController action:action
         forControlEvents:UIControlEventTouchUpInside];
    
    return menuButton;
}

@end
