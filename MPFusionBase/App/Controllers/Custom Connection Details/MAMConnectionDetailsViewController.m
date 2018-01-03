//
//  MAMConnectionDetailsViewController.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/17/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMConnectionDetailsViewController.h"

#import "EventKeys.h"
#import "MBProgressHUD.h"
#import "MTPAppSettingsKeys.h"
#import "MTPDataSource.h"

#import "MDMyConnectionManager.h"
#import "MDBeaconManager.h"
#import "MTPSponsorManager.h"
#import "Sponsor+Helpers.h"
#import "User+Helpers.h"

#import "NSURLSession+MTPCategory.h"
#import "NSString+MTPAPIAddresses.h"
#import "UIButton+MTPNavigationBar.h"
#import "UIImageView+AFNetworking.h"
#import "NSObject+EventDefaultsHelpers.h"

@interface MAMConnectionDetailsViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *connectionDetailsHeader;
@property (weak, nonatomic) IBOutlet UILabel *emailIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailAddressLabel;
@property (weak, nonatomic) IBOutlet UIView *separator;
@property (weak, nonatomic) IBOutlet UIImageView *headerBackground;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) CAShapeLayer *highlightLayer;

- (IBAction)didPressInitiateConnection:(id)sender;
@end

@implementation MAMConnectionDetailsViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupLabelDefaults];
    self.connectionDetailsImage.layer.borderWidth = 3.f;
    self.connectionDetailsImage.layer.borderColor = [UIColor whiteColor].CGColor;
    
    self.separator.backgroundColor = UIColorFromRGB(0x2a142e);
    self.webView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationItem] setTitleView:[UIButton navigationBarLogo:CGRectGetHeight(self.navigationController.navigationBar.frame)]];
    [[self navigationItem] setLeftBarButtonItem:[UIButton toggleMainMenuButton:@{@"fontAwesomeCode": @"\uf053"}
                                                                    target:self
                                                                  selector:@selector(toggleMenu:)]];
    [self configureWithDataSource:self.configurationDataSource];
    [self displayConnectionData:self.connection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.connectionStatusContainer.layer addSublayer:
     [self createConnectionButtonBorderEffect:self.connectionStatusContainer.layer.bounds]];
}

#pragma mark - Protocol Conformance
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = [NSString stringWithFormat:@"%@",[[self.userDefaults objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL]];
    DLog(@"\nurlString %@",urlString);

    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        if ([request.URL.absoluteString rangeOfString:urlString].location == NSNotFound) {
            [[UIApplication sharedApplication] openURL:request.URL];
            return false;
        }
    }
    
    return true;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // this suppresses the error that occurs when the user navigates to another
    // screen and when it cancels opening "../#/mds-pollzone/" after login
    if (error.code != -999 && error.code != 102) {
        //        [MTConstants showSIAlertWithTitle:@"Network Error" message:@"Couldn't load the website! Press reload to try again"];
    }
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark - IBActions
- (IBAction)didPressInitiateConnection:(id)sender
{
    [self initiateConnectionRequest:[self.connection connectionID]];
}

#pragma mark - Helper Methods
- (void)toggleMenu:(id)sender
{
    if ([self navigationController])
    {
        [[self navigationController] popViewControllerAnimated:true];
    }
}

- (void)displayConnectionData:(id<MTPConnectionDetailsDisplayable>)connectionData
{
    self.connection = connectionData;
    
    if ([connectionData respondsToSelector:@selector(displayMainTitle)])
    {
        self.connectionDetailsMainTitle.text = [connectionData displayMainTitle];
        self.connectionDetailsSubtitle.text = [connectionData displaySubtitle];
        [self.connectionDetailsImage setImageWithURL:[connectionData displayImageURL]
                                    placeholderImage:[UIImage imageNamed:@"no_photo"]];
    }
    
    if ([connectionData isKindOfClass:[User class]])
    {
        if (self.loggedInUserID)
        {
            User *connection = connectionData;
            self.emailAddressLabel.text = connection.email;
            self.connectionStatusContainer.hidden = [connection.user_id isEqualToNumber:self.loggedInUserID];
            [self changeConnectionStatusContainer:[self currentConnectionStatus:connection.user_id]];
            
            NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/profile/%@/?userID=%@",[[self.userDefaults objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL],connection.user_id,self.loggedInUserID]];
            [self.webView loadRequest:[NSURLRequest requestWithURL:profileURL]];
        }
    }
}

#pragma mark - Initial Setup
- (void)configureWithDataSource:(MTPViewControllerDataSource *)controllerDataSource
{
    self.connectionDetailsHeader.backgroundColor = [UIColor colorWithRed:238/255.f
                                                                   green:238/255.f
                                                                    blue:238/255.f
                                                                   alpha:1];
    
    self.headerBackground.image = [UIImage imageNamed:@"menuHeaderBackground"];
}

- (void)performManagerSetup:(void(^)(void))completionHandler
{
    self.dataSource = [MTPDataSource dataSourceRootObjectContext:self.rootObjectContext
                                                   beaconManager:self.beaconManager
                                               connectionManager:self.connectionManager];
    
    if (completionHandler)
    {
        completionHandler();
    }
}

const CGFloat cornerRadius = 5.f;

- (void)setupLabelDefaults
{
    NSArray *headerLabels = @[self.connectionDetailsMainTitle,
                              self.connectionDetailsSubtitle,
                              self.emailAddressLabel,
                              self.emailIconLabel,
                              self.connectionStatusIconLabel,
                              self.connectionStatusText];
    
    for (UILabel *headerLabel in headerLabels)
    {
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.adjustsFontSizeToFitWidth = true;
        headerLabel.minimumScaleFactor = 0.5;
    }
    
    self.connectionDetailsMainTitle.font = [UIFont fontWithName:@"RobotoCondensed-Bold" size:25.f];
    self.connectionDetailsSubtitle.font = [UIFont fontWithName:@"Roboto-LightItalic" size:13.f];
    self.emailAddressLabel.font = [UIFont fontWithName:@"Roboto-LightItalic" size:20.f];
    
    self.emailIconLabel.font = [UIFont fontWithName:@"FontAwesome" size:20.f];
    self.emailIconLabel.text = @"\uf003";
    
    self.connectionStatusIconLabel.font = [UIFont fontWithName:@"FontAwesome" size:20.f];
    self.connectionStatusIconLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1];
    self.connectionStatusIconLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    self.connectionStatusIconLabel.shadowColor = [UIColor colorWithWhite:1 alpha:0.5];
    
    self.connectionStatusText.font = [UIFont fontWithName:@"RobotoCondensed-Bold" size:20.f];
    
    self.connectionStatusContainer.layer.cornerRadius = cornerRadius;
    self.connectionStatusContainer.layer.borderColor = [UIColor colorWithRed:11/255.0 green:41/255.0 blue:61/255.0 alpha:0.7f].CGColor;
    self.connectionStatusContainer.layer.borderWidth = 1;
}

- (CALayer *)createConnectionButtonBorderEffect:(CGRect)targetRect
{
    if (self.highlightLayer) {
        return self.highlightLayer;
    }
    
    CGRect highlightRect = CGRectInset(targetRect, 1, 1);
//    highlightRect.size.width = self.connectionStatusContainer.frame.size.width;
    UIBezierPath *roundedButtonHighlight = [UIBezierPath bezierPathWithRoundedRect:highlightRect cornerRadius:cornerRadius];
    self.highlightLayer = [CAShapeLayer layer];
    self.highlightLayer.path = roundedButtonHighlight.CGPath;
    self.highlightLayer.lineWidth = 1;
    self.highlightLayer.strokeColor = [UIColor colorWithWhite:1 alpha:0.25].CGColor;
    self.highlightLayer.fillColor = [UIColor clearColor].CGColor;

    return self.highlightLayer;
}

#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    return;
}
@end

#pragma mark - ConnectionStatusToggling
@implementation MAMConnectionDetailsViewController (ConnectionStatusToggling)

- (void)initiateConnectionRequest:(NSNumber *)connectionID
{
    NSDictionary *connectionStatusTransformations = @{kMyConnectionNotConnected: kMyConnectionPending,
                                                      kMyConnectionPending: kMyConnectionPending,
                                                      kMyConnectionConnected: kMyConnectionConnected};
    
    NSString *oldConnectionStatus = [self currentConnectionStatus:connectionID];
    if ([oldConnectionStatus isEqualToString:kMyConnectionConnected])
    {
        DLog(@"\nalready connected to %@", self.connection);
        return;
    }
    else if (!oldConnectionStatus)
    {
        oldConnectionStatus = kMyConnectionNotConnected;
    }
    NSString *newConnectionStatus = [connectionStatusTransformations objectForKey:oldConnectionStatus];
    
    [self changeConnectionStatusContainer:newConnectionStatus];
    
    NSDictionary *requestInformation;
    
    if ([self showingUserProfile])
    {
        requestInformation = [self initiateUserConnectionRequest:self.loggedInUserID];
    }
    else
    {
        requestInformation = [self initiateSponsorConnectionRequest:self.loggedInUserID];
    }
    
    [self sendConnectionRequest:requestInformation];
}

- (NSDictionary *)initiateUserConnectionRequest:(NSNumber *)userID
{
    return @{@"apiURL": [NSString stringWithFormat:[NSString userConnectionAdd],userID],
             @"parameters": @{@"connection_user_id":[self.connection connectionID]},
             @"requestType": @"userConnection"};
}

- (NSDictionary *)initiateSponsorConnectionRequest:(NSNumber *)sponsorID
{
    return @{@"apiURL": [NSString stringWithFormat:[NSString sponsorConnectionAdd],sponsorID],
             @"parameters": @{@"user_id":[self.connection connectionID]},
             @"requestType": @"userConnection"};
}

- (void)changeConnectionStatusContainer:(NSString *)newStatus
{
    NSDictionary *connectionStatus = [self connectionDetailsForStatus:newStatus];
    
    NSString *statusImage = [connectionStatus objectForKey:@"icon"];
    NSString *statusText = [connectionStatus objectForKey:@"text"];
    UIColor *statusBackgroundColor = [connectionStatus objectForKey:@"color"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.connectionStatusContainer.backgroundColor = statusBackgroundColor;
        self.connectionStatusIconLabel.text = statusImage;
        self.connectionStatusText.text = statusText;
    });
}

- (BOOL)processRequest:(NSURLRequest *)request apiError:(NSError *)apiError response:(NSURLResponse *)urlResponse
{
    if (!apiError)
    {
        return false;
    }
    
    if (apiError.code == 400) {
        //        NSString *connectionStatus = [self.connectionManager checkMyConnectionFor:[self.connection connectionID]];
        // should load game
        //                [weakSelf performSegueWithIdentifier:@"initiateConnectionSegue" sender:nil];
    }
    else if (apiError.code == 409)
    {
        if (![self showingUserProfile])
        {
            [self.sponsorManager updateSponsor:self.connection connectionStatus:kMyConnectionConnected];
            /*
             if (self.delegate && [weakSelf.delegate respondsToSelector:@selector(sponsorConnection:)])
             {
             [weakSelf.delegate sponsorConnection:weakSelf.sponsor];
             }
             */
        }
        DLog(@"\nalready sent a request");
    }
    DLog(@"\nerror %@", apiError.localizedDescription);
    
    return true;
}

- (void)sendConnectionRequest:(NSDictionary *)requestDetails
{
    NSString *requestURLString = [requestDetails objectForKey:@"apiURL"];
    NSDictionary *requestParameters = [requestDetails objectForKey:@"parameters"];
    
    NSMutableURLRequest *urlRequest = [NSURLSession defaultRequestMethod:@"PUT"
                                                                     URL:requestURLString
                                                              parameters:requestParameters];
    
    __weak __typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          if ([weakSelf processRequest:urlRequest apiError:error response:response] == false) {
              // no error so it must have succeeded
              id responseObject = [NSURLSession serializeJSONData:data
                                                         response:response
                                                            error:error];
              
              
              
              if ([weakSelf showingUserProfile])
              {
                  if ([weakSelf.userDefaults objectForKey:@"eventHasConnectionGame"])
                  {
                      [weakSelf performSegueWithIdentifier:@"initiateConnectionSegue" sender:nil];
                  }
                  else
                  {
                      DLog(@"\nresponseObject %@", responseObject);
                      [weakSelf.connectionManager changeMyConnectionStatus:[weakSelf.connection connectionID]
                                                                  toStatus:kMyConnectionConnected];
                      [weakSelf changeConnectionStatusContainer:kMyConnectionConnected];
                      [weakSelf completeConnectionRequest:nil];
                  }
              }
              else
              {
                  [weakSelf.sponsorManager updateSponsor:weakSelf.connection
                                        connectionStatus:kMyConnectionConnected];
                  
                  //            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(sponsorConnection:)])
                  //            {
                  //                [weakSelf.delegate sponsorConnection:weakSelf.sponsor];
                  //            }
                  [weakSelf changeConnectionStatusContainer:[weakSelf.sponsorManager
                                                             connectionStatus:weakSelf.loggedInUserID]];
              }
          }
      }] resume];
}

- (void)completeConnectionRequest:(NSDictionary *)connectionCompletionDetails
{
    
    // change data
    //    NSNumber *userID;
    //    [[MDMyConnectionManager sharedManager] changeMyConnectionStatus:userID to:kMyConnectionConnected];
    
    // change ui
    //    [self toggleConnectionStatus];
    
    if (self.connectionCompletionDelegate
        && [self.connectionCompletionDelegate respondsToSelector:@selector(didCompleteConnection:atIndexPath:)])
    {
        [self.connectionCompletionDelegate didCompleteConnection:self.connection atIndexPath:self.connectionIndexPath];
    }
}

- (NSString *)currentConnectionStatus:(NSNumber *)userID
{
    NSString *connectionStatus = [self showingUserProfile] ? [self.connectionManager checkMyConnectionFor:userID] : [self.sponsorManager connectionStatus:userID];
    return connectionStatus ? connectionStatus : kMyConnectionNotConnected;
}

- (BOOL)showingUserProfile
{
    return [self.connection isKindOfClass:[User class]] ? true : false;
}

- (NSDictionary *)connectionDetailsForStatus:(NSString *)connectionStatus
{
    NSDictionary *connectionDetails = @{kMyConnectionConnected:@{@"icon": @"\uf0c1",
                                                                 @"text": @"Connected",
                                                                 @"color": kDarkGreen},
                                        
                                        kMyConnectionPending:@{@"icon": @"\uf017",
                                                               @"text": @"Pending",
                                                               @"color": kOrange},
                                        
                                        kMyConnectionNotConnected:@{@"icon": @"\uf127",
                                                                    @"text": @"Click to Connect",
                                                                    @"color": kDarkBlue}
                                        };
    return [connectionDetails objectForKey:connectionStatus];
}
@end

#pragma mark - ConnectionGameHelper
@implementation MAMConnectionDetailsViewController (ConnectionGameHelper)

- (void)checkDrawing:(NSNumber *)userID
{
    
}

- (void)loadGame:(id<MTPConnectionDetailsDisplayable>)connection
{
    
}
@end