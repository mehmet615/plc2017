//
//  MAMLoginViewController.m
//
//  Created by MeetingPlay on 4/15/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMLoginViewController.h"
#import "MTPLoginClient.h"
#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"
#import "MTPThemeOptionsUpdater.h"

#import "MTPApplicationDefaultsConstants.h"
#import "MTPAppSettingsKeys.h"

#import "MBProgressHUD.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "NSString+MTPWebViewURL.h"
#import "SIAlertView.h"
#import "UIButton+MTPNavigationBar.h"
#import "UIColor+AppColors.h"
#import "UINavigationBar+MTPHelper.h"
#import "UIView+AutoLayoutHelper.h"
#import "UIViewController+NavigationItemSetup.h"
#import "User+Helpers.h"

@interface MAMLoginViewController ()
@property (weak, nonatomic) UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptTermsButton;
@property (weak, nonatomic) IBOutlet UILabel *termsAndConditionsLabel;

@property (weak, nonatomic) IBOutlet UIView *termsContainer;
@property (weak, nonatomic) IBOutlet UIWebView *termsWebView;
@property (weak, nonatomic) IBOutlet UIButton *hideTermsButton;
@property (weak, nonatomic) IBOutlet UILabel *acceptTermsLabel;

@property (nonatomic, assign) BOOL acceptedTerms;
@property (nonatomic, assign) BOOL shouldShowSSO;
@property (nonatomic, strong) UIWebView *ssoWebView;

@property (nonatomic, weak) IBOutlet UIScrollView *loginScrollView;
@property (strong, nonatomic) NSArray *conferences;

@property (weak, nonatomic) IBOutlet UIImageView *loginHeaderImage;
@property (weak, nonatomic) IBOutlet UIImageView *loginLogoImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginHeaderHeight;

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *borderViews;
@end

@interface MAMLoginViewController (UITextFieldSetup)<UITextFieldDelegate>
@end
@implementation MAMLoginViewController (UITextFieldSetup)

- (void)setupTextFields
{
    self.usernameTextField.autocapitalizationType = false;
    self.usernameTextField.autocorrectionType = false;
    self.usernameTextField.keyboardType = UIKeyboardTypeEmailAddress;
    
    self.passwordTextField.secureTextEntry = true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}
@end

@implementation MAMLoginViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundTexture"]]];
    
    self.termsContainer.alpha = 0;
    [self.termsWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.meetingplay.com/terms"]]];
    
    self.failureBlock = ^{
        SIAlertView *failureAlert = [[SIAlertView alloc] initWithTitle:@"Login Failed"
                                                            andMessage:@"Sorry, but there was a problem logging in. Please check your e-mail address and try again."];
        [failureAlert setTitleColor:kDarkBlue];
        [failureAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [failureAlert show];
        });
    };
    
    [self setupLoginCustomization];
    
    if (MTP_SSO_ENABLED)
    {
        self.ssoWebView = [UIWebView new];
        
        self.ssoWebView.translatesAutoresizingMaskIntoConstraints = false;
        [self.view addSubview:self.ssoWebView];
        [self.view addConstraints:[self.ssoWebView pinToSuperviewBoundsInsets:UIEdgeInsetsMake(20, 10, -10, -10)]];
        [self.view bringSubviewToFront:self.ssoWebView];
    }
    
    BOOL toggleKeyboardVisiblity = true;
    if (toggleKeyboardVisiblity)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupNavigationBar];
    
    if (MTP_SSO_ENABLED)
    {
        [self.ssoWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString ssoURL]]]];
        self.ssoWebView.alpha = 0;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.ssoWebView.alpha = 1;
        } completion:nil];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - View Setup

- (void)setupLoginCustomization
{
    [self setupTextFields];

    NSDictionary *colors = self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors];
    
    UIColor *color17 = [UIColor mtp_colorFromString:colors[MPFUSION_color17]];
    UIColor *color2 = [UIColor mtp_colorFromString:colors[MPFUSION_color2]];
    UIColor *color24 = [UIColor mtp_colorFromString:colors[MPFUSION_color24]];
    
    // accept terms button
    [self.acceptTermsButton setTitleColor:color24
                                 forState:UIControlStateNormal];

    [self.acceptTermsButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:20.f]];
    [self.acceptTermsButton setTitle:@" " forState:UIControlStateNormal];
    self.acceptedTerms = false;
    
    NSMutableAttributedString *agreeTermsText = [[NSMutableAttributedString alloc] initWithString:self.acceptTermsLabel.text];
    [agreeTermsText addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}
                            range:[self.acceptTermsLabel.text rangeOfString:@"terms" options:NSCaseInsensitiveSearch]];
    self.acceptTermsLabel.attributedText = agreeTermsText;
    
    // hide terms button
    [self.hideTermsButton.titleLabel setFont:[UIFont fontWithName:@"FontAwesome" size:20.f]];
    [self.hideTermsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.hideTermsButton setTitle:@"\uf00d" forState:UIControlStateNormal];
    
    // login button
    self.loginButton.backgroundColor = color17;
    [self.loginButton setTitleColor:(color2 ? color2 : [UIColor whiteColor])
                           forState:UIControlStateNormal];
    //[self.loginButton.titleLabel setFont:[UIFont fontWithName:@"Lato-Regular" size:17.f]];
    
    for (UILabel *label in @[self.loginToContinueLabel,self.acceptTermsLabel])
    {
        [label setTextColor:[UIColor whiteColor]];
    }
    
    [self loadLoginBackgroundImage:[[self.navigationRouter.themeOptionsManager.themeOptions objectForKey:@"login"] objectForKey:@"background"]];
    [self loadFeaturedImage:[[self.navigationRouter.themeOptionsManager.themeOptions objectForKey:@"login"] objectForKey:@"header"]];
    
    for (UIView *borderViews in self.borderViews)
    {
        borderViews.layer.borderWidth = 1.f;
        borderViews.layer.borderColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    }
}

- (void)loadLoginBackgroundImage:(NSString *)backgroundImage
{
    self.loginBackgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    
    if ([backgroundImage rangeOfString:@"http"].location == NSNotFound)
    {
        UIImage *background = [UIImage imageNamed:backgroundImage];
        self.loginBackgroundImage.image = background;
    }
    else
    {
        NSURL *localSavePath = [MTPThemeOptionsManager saveURLForImage:backgroundImage];
        if (localSavePath)
        {
            __weak typeof(&*self)weakSelf = self;
            [self.navigationRouter.themeOptionsManager fetchImage:backgroundImage saveURL:localSavePath completion:^(UIImage *fetchedImage, NSError *error)
             {
                 if (error)
                 {
                     DLog(@"\nbackground image fetch error %@",error);
                 }
                 else
                 {
                     if (fetchedImage)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             
                             [weakSelf.loginBackgroundImage setImage:fetchedImage];
                             
                             UIColor *color2 = [UIColor mtp_colorFromString:[weakSelf.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color2]];
                             if (color2)
                             {
                                 for (UILabel *label in @[weakSelf.loginToContinueLabel,weakSelf.enterEmailLabel,weakSelf.acceptTermsLabel])
                                 {
                                     [label setTextColor:color2];
                                     label.shadowColor = [UIColor colorWithWhite:0 alpha:0.4];
                                     label.shadowOffset = CGSizeMake(0, 0);
                                 }
                             }
                         });
                     }
                 }
             }];
        }
    }
}

- (void)loadFeaturedImage:(NSString *)featured
{
    self.loginHeaderImage.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([featured rangeOfString:@"http"].length)
    {
        NSURL *localSavePath = [MTPThemeOptionsManager saveURLForImage:featured];
        if (localSavePath)
        {
            __weak typeof(&*self)weakSelf = self;
            [self.navigationRouter.themeOptionsManager fetchImage:featured saveURL:localSavePath completion:^(UIImage *fetchedImage, NSError *error)
             {
                 if (error)
                 {
                     DLog(@"\nbackground image fetch error %@",error);
                 }
                 else
                 {
                     if (fetchedImage)
                     {
                         dispatch_async(dispatch_get_main_queue(), ^{
                             weakSelf.loginHeaderImage.image = fetchedImage;
                             [weakSelf configureFeaturedImageRatio:fetchedImage];
                         });
                     }
                 }
             }];
        }
    }
    else
    {
        UIImage *featuredImage = [UIImage imageNamed:featured];
        if (featuredImage)
        {
            self.loginHeaderImage.image = featuredImage;
            [self configureFeaturedImageRatio:featuredImage];
        }
    }
}

- (void)configureFeaturedImageRatio:(UIImage *)image
{
    CGFloat aspectRatio = image.size.width / image.size.height;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        aspectRatio = 3;
    }
    CGFloat widthSuperview = CGRectGetWidth(self.view.frame);
    self.loginHeaderHeight.constant = widthSuperview / aspectRatio;
}

- (void)setupNavigationBar
{
//    [[[self navigationController] navigationBar] addBackgroundGradient:@"eeeeee"];
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - IBActions

- (IBAction)didPressAcceptTerms:(UIButton *)sender
{
    if ([self.acceptTermsButton.titleLabel.text isEqualToString:@" "])
    {
        [self.acceptTermsButton setTitle:@"\uf00c"
                                forState:UIControlStateNormal];
        self.acceptedTerms = true;
    }
    else
    {
        [self.acceptTermsButton setTitle:@" "
                                forState:UIControlStateNormal];
        self.acceptedTerms = false;
    }
}

- (IBAction)didPressShowTerms:(id)sender
{
    [UIView animateWithDuration:0.125 animations:^{
        self.termsContainer.alpha = self.termsContainer.alpha == 0 ? 1 : 0;
    }];
}

- (IBAction)didPressLogin:(id)sender
{
    if (self.acceptedTerms)
    {
        NSError *validationError = nil;
        if (![self shouldLogin:@[@1]])
        {
            return;
        }
        
        __weak __typeof(&*self)weakSelf = self;
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.label.text = @"Authenticating";
        
        [self.loginClient login:self.usernameTextField.text
                       password:self.passwordTextField.text
                 successHandler:^(id responseObject, User *currentUser) {
                     
             dispatch_async(dispatch_get_main_queue(), ^{
                 [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                 [weakSelf.navigationRouter loadMainScreen:currentUser];
             });
                     
         } failureHandler:^(NSError *error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                 [weakSelf showLoginFailure:error];
             });
         } validationError:validationError];
    }
    else
    {
        UIColor *originalColor = [self.acceptTermsButton.backgroundColor copy];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            [self.acceptTermsButton setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.7]];
        } completion:^(BOOL finished) {
            
            [self.acceptTermsButton setBackgroundColor:originalColor];
        }];
    }
}

/*
- (IBAction)pressedRegister:(id)sender
{
    NSString *firstName = self.registerFirstNameLabel.text;
    NSString *lastName = self.registerLastNameLabel.text;
    NSString *email = self.registerEmailNameLabel.text;
    
    if (firstName.length == 0 || lastName.length == 0 || email.length == 0)
    {
        [self showRegistrationError:@"Please fill out all the registration fields."];
        return;
    }
    
    if (self.acceptedTerms == NO)
    {
        UIColor *originalColor = [self.registerAcceptTermsButton.backgroundColor copy];
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            [self.registerAcceptTermsButton setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.7]];
        } completion:^(BOOL finished) {
            
            [self.registerAcceptTermsButton setBackgroundColor:originalColor];
        }];
        return;
    }
    
    NSNumber *attendeeTypeID = self.staffMemberButton.selected ? @7 : @8;
    
    // send registration
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"Creating User";
    
    __weak typeof(&*self)weakSelf = self;
    [self.loginClient createUser:firstName lastName:lastName email:email attendeeTypeID:attendeeTypeID completion:^(BOOL createdUser, User *attendee, NSDictionary *response, NSError *error)
     {
         if (createdUser)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 hud.label.text = @"Authenticating";
             });
             [self.loginClient login:self.registerEmailNameLabel.text
                            password:nil
                      successHandler:^(id responseObject, User *currentUser) {
                          
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                              [weakSelf.navigationRouter loadMainScreen:currentUser];
                          });
                          
                      } failureHandler:^(NSError *error) {
                          dispatch_async(dispatch_get_main_queue(), ^{
                              [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                              [weakSelf showLoginFailure:error];
                          });
                      } validationError:error];
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [hud hide:YES];
                 NSString *errorMessage = error.localizedDescription;
                 if (errorMessage.length == 0)
                 {
                     errorMessage = @"Failed to create a user";
                 }
                 SIAlertView *creationFailureAlert = [[SIAlertView alloc] initWithTitle:@"Failed Attempt" andMessage:errorMessage];
                 [creationFailureAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
                 [creationFailureAlert show];
             });
         }
     }];
}

- (void)showRegistrationError:(NSString *)errorMessage
{
    SIAlertView *regError = [[SIAlertView alloc] initWithTitle:@"Registration Error" andMessage:errorMessage];
    [regError addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
    [regError show];
}
*/

- (void)showLoginFailure:(NSError *)loginError
{
    if (self.failureBlock)
    {
        self.failureBlock();
    }
}

- (BOOL)shouldLogin:(NSArray *)loginPrerequisites
{
    return true;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Helper Methods
- (IBAction)hideSSOLogin:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]])
    {
        self.ssoWebView.hidden = !self.ssoWebView.hidden;
    }
}

- (void)login:(NSString *)email
{
    if (email.length > 0)
    {
        self.usernameTextField.text = email;
        self.acceptedTerms = true;
        [self didPressLogin:nil];
    }
    
    self.ssoWebView.hidden = true;
}

#pragma mark Keyboard Visibility

- (void)keyboardDidShow:(NSNotification *)notification
{
    CGRect keyboardEndFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect usernameRect = self.usernameTextField.frame;
    
    CGPoint loginBottomLeftCorner = [self.view convertPoint:CGPointMake(0, usernameRect.origin.y + CGRectGetHeight(usernameRect) + 100)
                                                   fromView:self.usernameTextField];
    
    BOOL keyboardCoversView = [self keyboard:keyboardEndFrame coversPoint:loginBottomLeftCorner];
    if (keyboardCoversView)
    {
        UIEdgeInsets newInsets = UIEdgeInsetsZero;
        newInsets.bottom = 64;
        
        self.loginScrollView.contentInset = newInsets;
        
        CGFloat distanceBetweenTextFieldAndKeyboard = fabs(keyboardEndFrame.origin.y - loginBottomLeftCorner.y);
        [UIView animateWithDuration:0.2 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:0 animations:^{
            self.loginScrollView.contentOffset = CGPointMake(self.loginScrollView.contentOffset.x, self.loginScrollView.contentOffset.y + distanceBetweenTextFieldAndKeyboard + 10);
        } completion:nil];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.loginScrollView.contentInset = UIEdgeInsetsZero;
}

- (BOOL)keyboard:(CGRect)keyboardFrame coversPoint:(CGPoint)targetPoint
{
    BOOL coversPoint = CGRectContainsPoint(keyboardFrame, targetPoint);
    return coversPoint;
}

@end
