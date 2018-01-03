//
//  MTPSideMenuLoader.m
//  HS2016
//
//  Created by Michael Thongvanh on 3/28/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "MTPSideMenuLoader.h"
#import "MTPRightNavigationViewController.h"
#import "MTPNavigationRouter.h"
#import "User.h"
#import "MTPMenuItem.h"
#import "NSString+MTPWebViewURL.h"
#import <WebKit/WebKit.h>

@interface MTPSideMenuLoader () <MTPSideMenuDelegate>
@property (strong, nonatomic) NSLayoutConstraint *rightMenuWidth;
@property (readwrite, strong, nonatomic) NSLayoutConstraint *rightMenuLeading;

@property (weak, nonatomic) UIView *parentView;

@property (weak, nonatomic) MTPNavigationRouter *navigationRouter;
@end

@implementation MTPSideMenuLoader

- (MTPRightNavigationViewController *)setupSideMenu:(UIView *)parentView inViewController:(UIViewController *)parentViewController navigationRouter:(MTPNavigationRouter *)navigationRouter
{
    self.parentView = parentView;
    self.navigationRouter = navigationRouter;
    
    MTPRightNavigationViewController *rightMenu = [[MTPRightNavigationViewController alloc] initWithNibName:@"MTPRightNavigationViewController" bundle:nil];
    rightMenu.delegate = self;
    
    UIView *rightMenuView = rightMenu.view;

    rightMenuView.translatesAutoresizingMaskIntoConstraints = NO;
    [parentView addSubview:rightMenuView];
    
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightMenuView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightMenuView)]];
    
    self.rightMenuLeading = [NSLayoutConstraint constraintWithItem:rightMenuView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0];
    [parentView addConstraint:self.rightMenuLeading];
    
    self.rightMenuWidth = [NSLayoutConstraint constraintWithItem:rightMenuView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeWidth multiplier:0.8 constant:0];
    [parentView addConstraint:self.rightMenuWidth];
    
    [rightMenu configureWithThemeOptions:navigationRouter.themeOptionsManager];
    [rightMenu configureWithUserDetails:navigationRouter.currentUser];
    [rightMenu loadBackgroundTexture:navigationRouter.themeOptionsManager];
    
    self.rightMenu = rightMenu;
    
    [self loadWebView];
    
    return rightMenu;
}

- (void)sideMenu:(MTPRightNavigationViewController *)sideMenu didEditProfile:(id)sender
{
    MTPMenuItem *editProfile = [MTPMenuItem new];
    editProfile.contentType = MTPContentTypeWebView;
    editProfile.webviewURL = [NSString editProfile];
    
    [self.navigationRouter loadViewController:editProfile animated:YES];
}

- (void)showMenu
{
    if (self.navigationRouter && self.rightMenu)
    {
        [self.rightMenu reloadWithUserID:self.navigationRouter.currentUser.user_id];
        
        [self loadWebView];
        
        UIView *rightMenuView = self.rightMenu.view;
        rightMenuView.layer.shadowColor = [UIColor colorWithWhite:0.3 alpha:0.4].CGColor;
        rightMenuView.layer.shadowOpacity = 1;
        
        CGFloat menuWidth = CGRectGetWidth(self.parentView.frame) * self.rightMenuWidth.multiplier;
        self.rightMenuLeading.constant = -menuWidth;
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.rightMenu.view.superview layoutIfNeeded];
        }];
    }
}

- (void)hideMenu
{
    self.rightMenuLeading.constant = 0;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.rightMenu.view.superview layoutIfNeeded];
    }];
    
    UIView *rightMenuView = self.rightMenu.view;
    rightMenuView.layer.shadowOpacity = 0;
}

- (void)loadWebView
{
    if (self.navigationRouter.currentUser.user_id == nil)
    {
        return;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString pulseProfile:self.navigationRouter.currentUser.user_id]]];
    [self.rightMenu.userProfileWebView loadRequest:request];
    
}

@end
