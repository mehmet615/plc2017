//
//  MTPRightNavigationViewController.m
//  MPFusionBase
//
//  Created by Michael Thongvanh on 3/21/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "MTPRightNavigationViewController.h"
#import "MTPThemeOptionsManager.h"
#import "User.h"
#import "UIColor+AppColors.h"
#import "MTPAppSettingsKeys.h"
#import "MTPDLogDefine.h"
#import "UIImageView+WebCache.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSMutableURLRequest+MTPHelper.h"
#import "MBProgressHUD.h"
#import <WebKit/WebKit.h>

@interface MTPRightNavigationViewController () <WKNavigationDelegate>
@property (strong, nonatomic) NSString *appURLScheme;
@property (weak, nonatomic) IBOutlet UIView *webViewContainer;
@end

@implementation MTPRightNavigationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.profileImage.layer.borderColor = [UIColor whiteColor].CGColor;
    self.profileImage.layer.borderWidth = 4.f;
    self.profileImage.layer.shadowColor = [UIColor blackColor].CGColor;
    self.profileImage.layer.shadowOffset = CGSizeMake(0, 0);
    self.profileImage.layer.shadowRadius = 5.f;
    self.profileImage.layer.shadowOpacity = 0.5;
    
    self.editProfileButton.layer.cornerRadius = 3.f;
    self.editProfileButton.layer.masksToBounds = YES;
    
    NSArray *urlTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    [urlTypes enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull urlType, NSUInteger idx, BOOL * _Nonnull found)
     {
         NSString *role = urlType[@"CFBundleTypeRole"];
         if ([role isEqual:@"Editor"])
         {
             NSArray *schemes = urlType[@"CFBundleURLSchemes"];
             [schemes enumerateObjectsUsingBlock:^(NSString * _Nonnull scheme, NSUInteger idx, BOOL * _Nonnull stop) {
                 if (scheme.length > 1)
                 {
                     if ([scheme rangeOfString:@"mp" options:NSCaseInsensitiveSearch range:NSMakeRange(0, 2)].length)
                     {
                         _appURLScheme = scheme;
                         *stop = YES;
                         *found = YES;
                     }
                     else
                     {
                         DLog(@"\nnot a meetingplay scheme %@",scheme);
                     }
                 }
                 else
                 {
                     DLog(@"\ninvalid scheme %@",scheme);
                 }
             }];
         }
     }];
    
    [self setupWebView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupWebView
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.processPool = self.processPool;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    webView.translatesAutoresizingMaskIntoConstraints = NO;
    webView.navigationDelegate = self;
    [self.webViewContainer addSubview:webView];
    [webView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    [webView.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(webView)]];
    
    //    self.userProfileWebView.hidden = YES;
    
    self.userProfileWebView = webView;
    
    self.webViewContainer.backgroundColor = [UIColor clearColor];
    
    self.userProfileWebView.backgroundColor = [UIColor clearColor];
    self.userProfileWebView.opaque = NO;
    self.userProfileWebView.alpha = 1;
}

- (void)configureWithUserDetails:(User *)currentUser
{
    [self reloadWithUserID:currentUser.user_id];
}

- (void)configureWithThemeOptions:(MTPThemeOptionsManager *)themeOptionsManager
{
    NSDictionary *themeOptions = themeOptionsManager.themeOptions;
    NSDictionary *colors = themeOptions[MPFUSION_colors];
    
    UIColor *color18 = [UIColor mtp_colorFromString:colors[@"color18"]];
    self.headerContainer.backgroundColor = color18;
    
    UIColor *color19 = [UIColor mtp_colorFromString:colors[@"color19"]];
    self.headerSeparator.backgroundColor = color19;
    
    UIColor *color20 = [UIColor mtp_colorFromString:colors[@"color20"]];
    self.editProfileButton.layer.borderColor = color20.CGColor;
    
    UIColor *color2 = [UIColor mtp_colorFromString:colors[MPFUSION_color2]];
    [self.editProfileButton setTitleColor:color2 forState:UIControlStateNormal];
    
    UIColor *color21 = [UIColor mtp_colorFromString:colors[MPFUSION_color21]];
    self.editProfileButton.backgroundColor = color21;
    self.editProfileButton.layer.borderWidth = 1;
    
    UIColor *color22 = [UIColor mtp_colorFromString:colors[@"color22"]];
    self.usernameLabel.textColor = color22;
}

- (void)loadBackgroundTexture:(MTPThemeOptionsManager *)themeOptionsManager
{
    NSString *backgroundTextureRemote = [themeOptionsManager.themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageBackgroundTexture];
    NSURL *backgroundTextureSavePath = [MTPThemeOptionsManager saveURLForImage:backgroundTextureRemote];
    if (backgroundTextureSavePath.path.length)
    {
        __weak typeof(&*self)weakSelf = self;
        [themeOptionsManager fetchImage:backgroundTextureRemote saveURL:backgroundTextureSavePath completion:^(UIImage *fetchedImage, NSError *error)
        {
            if (error)
            {
                DLog(@"\nerror %@",error);
            }
            else
            {
                if (fetchedImage)
                {
                    [weakSelf.view setBackgroundColor:[UIColor colorWithPatternImage:fetchedImage]];
                }
                else
                {
                    DLog(@"\nfetched image was nil %@",backgroundTextureRemote);
                }
            }
        }];
    }
}

- (void)reloadWithUserID:(NSNumber *)userID
{
    if (userID == nil)
    {
        DLog(@"\nuser id was nil %@",userID);
        return;
    }
    
    __weak typeof(&*self)weakSelf = self;
    
    NSString *userDetails = [NSString stringWithFormat:@"%@/%@",[NSString userInfo],userID];
    
    NSMutableURLRequest *userInfoRequest = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:userDetails parameters:nil];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:userInfoRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            DLog(@"\nerror %@",error);
        }
        else
        {
            NSError *serializationError;
            id apiResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
            if (serializationError)
            {
                DLog(@"\nserialization error %@",serializationError);
            }
            else
            {
                if ([apiResponse isKindOfClass:[NSDictionary class]])
                {
                    id userDetails = [apiResponse objectForKey:@"data"];
                    if ([userDetails isKindOfClass:[NSDictionary class]])
                    {
                        NSString *firstName = [NSString stringWithFormat:@"%@",userDetails[@"first_name"]];
                        NSString *lastName = [NSString stringWithFormat:@"%@",userDetails[@"last_name"]];
                        NSString *imageURL = [NSString stringWithFormat:@"%@",userDetails[@"photo"]];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.usernameLabel.text = [NSString stringWithFormat:@"%@%@",
                                                           firstName.length ? [NSString stringWithFormat:@"%@ ",firstName] : @"",
                                                           lastName.length ? lastName : @""];
                        });
                        
                        NSString *profileImageBaseURL = [NSString stringWithFormat:@"%@",[apiResponse[@"info"] objectForKey:@"profile_url"]];
                        NSString *profileImageURL = [[NSString stringWithFormat:@"%@%@",profileImageBaseURL,imageURL] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                        [weakSelf loadProfileImage:profileImageURL];
                    }
                    else
                    {
                        DLog(@"\nuser details not a dictionary %@",apiResponse);
                    }
                }
                else
                {
                    DLog(@"\nnot a dictionary %@",apiResponse);
                }
            }
        }
    }] resume];
}

- (void)loadProfileImage:(NSString *)profileImageRemoteURL
{
    [self.profileImage sd_setImageWithURL:[NSURL URLWithString:profileImageRemoteURL] placeholderImage:[UIImage imageNamed:@"no_photo"]];
}

- (IBAction)pressedEditProfile:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sideMenu:didEditProfile:)])
    {
        [self.delegate sideMenu:self didEditProfile:self];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

#pragma mark Web View Delegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self toggleProgressHUDVisiblity:true];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self toggleProgressHUDVisiblity:false];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self toggleProgressHUDVisiblity:false];
}

- (void)toggleProgressHUDVisiblity:(BOOL)visible
{
    UIView *hudContainerView = self.userProfileWebView;
    if (hudContainerView)
    {
        if (visible)
        {
            [MBProgressHUD showHUDAddedTo:hudContainerView animated:true];
        }
        else
        {
            [MBProgressHUD hideHUDForView:hudContainerView animated:true];
        }
    }
    else
    {
        NSLog(@"%s\n[%s]: Line %i] %@",__FILE__,__PRETTY_FUNCTION__,__LINE__,
              @"no feedback container found");
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    WKNavigationActionPolicy actionPolicy = WKNavigationActionPolicyAllow;
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated)
    {
        NSString *urlString = [NSString stringWithFormat:@"%@",[[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL]];
        
        BOOL externalLink = [navigationAction.request.URL.absoluteString rangeOfString:urlString options:NSCaseInsensitiveSearch].location == NSNotFound;
        BOOL appURLSchemeLink = [[navigationAction.request.URL scheme] compare:self.appURLScheme options:NSCaseInsensitiveSearch] == NSOrderedSame;
        
        if (externalLink || appURLSchemeLink)
        {
            actionPolicy = WKNavigationActionPolicyCancel;
            
            if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL])
            {
                [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
            }
        }
    }
    decisionHandler(actionPolicy);
}

/*! @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;
{
    [self toggleProgressHUDVisiblity:YES];
}

/*! @abstract Invoked when an error occurs while starting to load data for
 the main frame.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self toggleProgressHUDVisiblity:NO];
}

/*! @abstract Invoked when a main frame navigation completes.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation;
{
    [self toggleProgressHUDVisiblity:NO];
}

/*! @abstract Invoked when an error occurs during a committed main frame
 navigation.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 @param error The error that occurred.
 */
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    [self toggleProgressHUDVisiblity:NO];
}
@end
