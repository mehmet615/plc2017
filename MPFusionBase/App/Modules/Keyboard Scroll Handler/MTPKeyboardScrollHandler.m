//
//  MTPKeyboardScrollHandler.m
//  EXPERIENCE16
//
//  Created by Michael Thongvanh on 4/15/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPKeyboardScrollHandler.h"

@implementation MTPKeyboardScrollHandler
- (instancetype)initWithScrollView:(UIScrollView *)scrollView lowestView:(UIView *)lowestView containerView:(UIView *)containerView
{
    if (self = [super init])
    {
        _scrollView = scrollView;
        _lowestView = lowestView;
        _containerView = containerView;
        
        [self registerNotifications];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 0,CGRectGetHeight(keyboardFrame)/3.f + 5,0);
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

@end
