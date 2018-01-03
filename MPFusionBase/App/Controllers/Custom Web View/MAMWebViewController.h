//
//  MAMWebViewController.h
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/13/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

@class User,MTPNavigationRouter,MTPThemeOptionsManager;

@interface MAMWebViewController : UIViewController <UITextViewDelegate, UIWebViewDelegate, MTPNavigationItemCustomizable,MTPMainMenuTogglable>

@property (strong, nonatomic) MTPNavigationRouter *navigationRouter;
@property (strong, nonatomic) MTPThemeOptionsManager *themeOptionsManager;

@property (nonatomic, weak) IBOutlet UIView *webViewContainer;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) NSString *customURL;

@property (nonatomic, strong) User *currentUser;

@property (nonatomic, assign, getter=isFirstLogin) BOOL firstLogin;

@property (weak, nonatomic) IBOutlet UIView *webViewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *headerBackground;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UITextView *webviewDescriptionTextView;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;

@property (weak, nonatomic) id<MTPMainMenuTogglable> menuToggleDelegate;

- (IBAction)refreshWebView:(id)sender;

@end
