//
//  MAMLoginViewController.h
//  MarriottMasters
//
//  Created by MeetingPlay on 4/15/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPLoginClient, MTPNavigationRouter;

@interface MAMLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *loginBackgroundImage;
@property (nonatomic, strong) MTPNavigationRouter *navigationRouter;

@property (nonatomic, strong) MTPLoginClient *loginClient;

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (nonatomic, weak) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UILabel *loginToContinueLabel;
@property (weak, nonatomic) IBOutlet UILabel *enterEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *agreeTermsLabel;


@property (nonatomic, copy) void (^failureBlock)(void);

- (IBAction)didPressLogin:(id)sender;
- (void)showLoginFailure:(NSError *)loginError;

- (void)login:(NSString *)email;

@end
