//
//  MTPWebViewController.h
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 10/27/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

@class User,MTPNavigationRouter,MTPThemeOptionsManager;

@protocol MTPWebViewRefreshable <NSObject>
- (void)refreshWebView:(id)sender;
@end

@interface MTPWebViewController : UIViewController <UITextViewDelegate,MTPNavigationItemCustomizable,MTPMainMenuTogglable,MTPWebViewRefreshable>

@property (strong, nonatomic) MTPNavigationRouter *navigationRouter;
@property (strong, nonatomic) MTPThemeOptionsManager *themeOptionsManager;

@property (nonatomic, weak) IBOutlet UIView *webViewContainer;
@property (strong, nonatomic) WKWebView *webView;
@property (nonatomic, strong) NSString *customURL;

@property (strong, nonatomic) WKProcessPool *processPool;

@property (nonatomic, strong) User *currentUser;

@property (nonatomic, assign, getter=isFirstLogin) BOOL firstLogin;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;

@property (weak, nonatomic) id<MTPMainMenuTogglable> menuToggleDelegate;

@end
