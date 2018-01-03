//
//  MTPEditProfilePresenter.m
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 11/17/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPEditProfilePresenter.h"
#import "MBProgressHUD.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "MTPAppSettingsKeys.h"

@interface MTPEditProfilePresenter ()
@property (nonatomic, strong) UIView *editProfileTopView;
@end

@implementation MTPEditProfilePresenter

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _editProfileContainer = [UIView new];
        _editProfileContainer.translatesAutoresizingMaskIntoConstraints = false;
        _editProfileContainer.backgroundColor = [UIColor clearColor];
        _editProfileContainer.clipsToBounds = true;
        
        _editProfileTopView = [UIView new];
        _editProfileTopView.translatesAutoresizingMaskIntoConstraints = false;
        
        _editProfileTopView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigationBarBackground"]];
        _editProfileTopView.layer.cornerRadius = 10.f;
        _editProfileTopView.layer.borderColor = [UIColor blackColor].CGColor;
        _editProfileTopView.layer.borderWidth = 1.f;
        _editProfileTopView.layer.masksToBounds = true;
        
        _toggleEditProfileVisibility = [UIButton buttonWithType:UIButtonTypeCustom];
        _toggleEditProfileVisibility.translatesAutoresizingMaskIntoConstraints = false;
        [_toggleEditProfileVisibility.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:40.f]];
        [_toggleEditProfileVisibility setTitle:@"\uf107" forState:UIControlStateNormal];
        [_toggleEditProfileVisibility addTarget:self action:@selector(toggleEditProfile) forControlEvents:UIControlEventTouchUpInside];
        
        _editProfileWebView = [UIWebView new];
        _editProfileWebView.translatesAutoresizingMaskIntoConstraints = false;
        _editProfileWebView.delegate = self;
        _editProfileWebView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundTexture"]];
    }
    return self;
}

- (void)presentEditProfileInView:(UIView *)parentView
{
    NSDictionary *viewsDictionary = @{@"container": self.editProfileContainer,
                                      @"topView": self.editProfileTopView,
                                      @"showButton": self.toggleEditProfileVisibility,
                                      @"webView": self.editProfileWebView};
    
    [parentView addSubview:self.editProfileContainer];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[container]|" options:0 metrics:nil views:viewsDictionary]];
    [parentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[container]|" options:0 metrics:nil views:viewsDictionary]];
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self.editProfileContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [self.editProfileContainer addConstraint:self.heightConstraint];
    
    // top view that contains the toggle button
    [self.editProfileContainer addSubview:self.editProfileTopView];
    [self.editProfileContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topView]|" options:0 metrics:nil views:viewsDictionary]];
    [self.editProfileContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView(54)]" options:0 metrics:nil views:viewsDictionary]];
    
    [self.editProfileTopView addSubview:self.toggleEditProfileVisibility];
    [self.editProfileTopView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[showButton]-10-|" options:0 metrics:nil views:viewsDictionary]];
    [self.editProfileTopView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[showButton]|" options:0 metrics:nil views:viewsDictionary]];
    
    // webview portion
    [self.editProfileContainer addSubview:self.editProfileWebView];
    [self.editProfileContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(44@999)-[webView]|" options:0 metrics:nil views:viewsDictionary]];
    [self.editProfileContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:viewsDictionary]];
    
    self.profileVisible = false;
    self.animatingVisibility = false;
    
    [parentView bringSubviewToFront:self.editProfileContainer];
}

- (void)toggleEditProfile
{
    if (self.isAnimatingVisiblity)
    {
        return;
    }
    
    self.animatingVisibility = true;
    
    BOOL visible = !self.isProfileVisible;
    
    UIView *editProfileParentView = self.editProfileContainer.superview;
    
    CGFloat containerHeight = 0;
    if (visible)
    {
        containerHeight = CGRectGetHeight(editProfileParentView.frame) * 0.9;
        [self refreshEditProfileWebView:self.userID];
        [editProfileParentView bringSubviewToFront:self.editProfileContainer];
    }
    else
    {
        containerHeight = 0;
    }
    
    [editProfileParentView layoutIfNeeded];
    
    self.heightConstraint.constant = containerHeight;
    
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:1 options:0 animations:^
     {
         [editProfileParentView layoutIfNeeded];
         
     } completion:^(BOOL finished) {
         
         self.profileVisible = visible;
         self.animatingVisibility = !finished;
         
         if (self.editProfileDelegate && [self.editProfileDelegate respondsToSelector:@selector(profilePresenter:didToggleVisiblity:)])
         {
             [self.editProfileDelegate profilePresenter:self didToggleVisiblity:visible];
         }
         else
         {
             DLog(@"delegate check failed %@",self);
         }
     }];
}

- (void)refreshEditProfileWebView:(NSNumber *)userID
{
    if (userID)
    {
        NSString *editProfileURL = [NSString stringWithFormat:@"%@/edit-profile/?userID=%@",
                                    [[self.userDefaults objectForKey:MTP_NetworkOptions]
                                     objectForKey:MTP_EventBaseHTTPURL],userID];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:editProfileURL]
                                                 cachePolicy:NSURLRequestReloadIgnoringCacheData
                                             timeoutInterval:30.f];
        
        [self.editProfileWebView loadRequest:request];
    }
    else
    {
        DLog(@"\nno user id found");
    }
}

#pragma mark UIWebViewDelegate Methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self showLoadingIndicator:YES error:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self showLoadingIndicator:NO error:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self showLoadingIndicator:NO error:error];
}

- (void)showLoadingIndicator:(BOOL)visible error:(NSError *)error
{
    if (error)
    {
        NSLog(@"%s\n[%s]: Line %i] error %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
              error);
    }
    
    if (visible)
    {
        [MBProgressHUD showHUDAddedTo:self.editProfileWebView animated:true];
    }
    else
    {
        [MBProgressHUD hideHUDForView:self.editProfileWebView animated:true];
    }
}

@end
