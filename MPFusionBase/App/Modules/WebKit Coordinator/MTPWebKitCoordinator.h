//
//  MTPWebKitCoordinator.h
//  SEEK2017
//
//  Created by Michael Thongvanh on 12/2/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WKWebView,WKProcessPool;

@interface MTPWebKitCoordinator : NSObject

@property (strong, nonatomic) UIView *containerView;
@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) WKProcessPool *processPool;

@property (nonatomic, strong) NSNumber *userID;

- (instancetype)init:(NSNumber *)userID processPool:(WKProcessPool *)processPool;
- (void)setupWebView:(UIView *)containerView margin:(NSNumber *)margin;
- (void)loadCustomURL:(NSURL *)customURL forceReload:(BOOL)forceReload;

@end
