//
//  MTPEditProfilePresenter.h
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 11/17/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPEditProfilePresenter;

@protocol MTPEditProfileDisplayable <NSObject>
- (void)toggleEditProfileVisibility;
@end

@protocol MTPEditProfileDelegate <NSObject>
- (void)profilePresenter:(MTPEditProfilePresenter *)profilePresenter didToggleVisiblity:(BOOL)visible;
@end

#pragma mark - Class Interface
@interface MTPEditProfilePresenter : NSObject <UIWebViewDelegate>

@property (nonatomic, strong) UIView *editProfileContainer;
@property (nonatomic, strong) UIButton *toggleEditProfileVisibility;
@property (nonatomic, strong) UIWebView *editProfileWebView;
@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;
@property (nonatomic, strong) NSNumber *userID;

@property (nonatomic, weak) id <MTPEditProfileDelegate> editProfileDelegate;

@property (nonatomic, assign, getter=isProfileVisible) BOOL profileVisible;
@property (nonatomic, assign, getter=isAnimatingVisiblity) BOOL animatingVisibility;

- (void)presentEditProfileInView:(UIView *)parentView;
- (void)toggleEditProfile;

@end
