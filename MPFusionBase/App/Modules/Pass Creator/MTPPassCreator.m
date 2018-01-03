//
//  MTPPassCreator.m
//  ALLTECHONE
//
//  Created by MeetingPlay on 3/29/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPPassCreator.h"
#import "MTPDLogDefine.h"

#import "MBProgressHUD.h"
#import "SIAlertView.h"

#import "NSMutableURLRequest+MTPHelper.h"

#import <PassKit/PassKit.h>

@interface MTPPassCreator ()
@property (strong, nonatomic) UIView *feedbackView;
@property (strong, nonatomic) UIViewController *presentationViewController;
@property (strong, nonatomic) NSString *passIdentifier;
@end

@implementation MTPPassCreator

NSString *const MTP_RegPass_SerialNumber = @"MTP_RegPass_SerialNumber";
NSString *const kMTP_RegPass_APIKey = @"dG1Ed05nTEFqRFVucmVjZ3lzZllqSmRHdWxGZ2VSU2ZIclVqY3FrWnd5d3JSSExJc3FOR2RVTUh1TVdMUGFVYzo=";
NSString *const kMTP_RegPass_PassTemplateID = @"5595290224820224";

- (instancetype)init
{
    if (self = [super init])
    {
        _passIdentifier = [NSString stringWithFormat:@"pass.%@",[[NSBundle mainBundle] bundleIdentifier]];
    }
    return self;
}

- (void)processPassRequest:(NSNumber *)userID feedbackView:(UIView *)feedbackView presentationTarget:(UIViewController *)presentationViewController
{
    self.feedbackView = feedbackView;
    self.presentationViewController = presentationViewController;
    
    NSString *serialNumber = [[NSUserDefaults standardUserDefaults] objectForKey:MTP_RegPass_SerialNumber];
    if (serialNumber.length)
    {
        [self fetchPass:userID serialNumber:serialNumber];
    }
    else
    {
        [self createPass:userID];
    }
}

- (void)fetchPass:(NSNumber *)userID serialNumber:(NSString *)serialNumber
{
    [MBProgressHUD showHUDAddedTo:self.feedbackView animated:YES];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.passslot.com/v1/passes/%@/%@",self.passIdentifier,serialNumber];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest mtp_defaultRequestMethod:@"GET" URL:urlString parameters:nil];
    [urlRequest setValue:@"" forHTTPHeaderField:@"X-Authentication-Token"];
    [urlRequest setValue:[NSString stringWithFormat:@"Basic %@",kMTP_RegPass_APIKey] forHTTPHeaderField:@"Authorization"];
    
    __weak typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          dispatch_async(dispatch_get_main_queue(), ^{
              
              [MBProgressHUD hideHUDForView:weakSelf.feedbackView animated:YES];
              
              void (^passCreationError)(PKPass *fetchedPass,NSError *error) = ^(PKPass *fetchedPass,NSError *error) {
                  SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Wallet Pass Error"
                                                               andMessage:error.localizedDescription];
                  [alert addButtonWithTitle:@"Retry" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView)
                   {
                       [weakSelf fetchPass:userID serialNumber:serialNumber];
                   }];
                  [alert addButtonWithTitle:@"Create New" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                      [weakSelf createPass:userID];
                  }];
                  [alert show];
              };
              
              NSError *passError = nil;
              PKPass *pass = [[PKPass alloc] initWithData:data error:&passError];
              if (passError)
              {
                  passCreationError(nil,passError);
              }
              else
              {
                  if (pass)
                  {
                      PKAddPassesViewController *passViewController = [[PKAddPassesViewController alloc] initWithPass:pass];
                      if (passViewController)
                      {
                          [weakSelf.presentationViewController presentViewController:passViewController animated:YES completion:nil];
                      }
                  }
                  else
                  {
                      passCreationError(nil,[NSError errorWithDomain:@"com.MeetingPlay.PassCreationError" code:10003 userInfo:@{NSLocalizedDescriptionKey:@"There was an error locating your pass. Please try again or create a new pass."}]);
                  }
              }
          });
      }] resume];
}

- (void)createPass:(NSNumber *)userID
{
    if (userID == nil)
    {
        SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Wallet Pass Error"
                                                     andMessage:@"There was an error creating your pass. Please try again or proceed to the help desk."];
        [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
        [alert show];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.feedbackView animated:YES];
    
    NSString *passTemplateURL = [NSString stringWithFormat:@"https://api.passslot.com/v1/templates/%@/pass",kMTP_RegPass_PassTemplateID];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest mtp_defaultRequestMethod:@"POST" URL:passTemplateURL parameters:@{@"UserID":userID}];
    [urlRequest setValue:@"" forHTTPHeaderField:@"X-Authentication-Token"];
    [urlRequest setValue:[NSString stringWithFormat:@"Basic %@",kMTP_RegPass_APIKey] forHTTPHeaderField:@"Authorization"];
    
    __weak typeof(&*self)weakSelf = self;
    [[[NSURLSession sharedSession] dataTaskWithRequest:urlRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          dispatch_async(dispatch_get_main_queue(), ^{
              
              [MBProgressHUD hideHUDForView:weakSelf.feedbackView animated:YES];
              
              NSError *requestError;
              
              if (error)
              {
                  requestError = error;
              }
              else
              {
                  DLog(@"\ndebugging message %@",response);
                  id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&requestError];
                  if (responseObject)
                  {
                      NSString *serialNumber = responseObject[@"serialNumber"];
                      if (serialNumber.length)
                      {
                          [[NSUserDefaults standardUserDefaults] setObject:serialNumber forKey:MTP_RegPass_SerialNumber];
                          [weakSelf fetchPass:userID serialNumber:serialNumber];
                          return;
                      }
                      else
                      {
                          requestError = [NSError errorWithDomain:@"com.MeetingPlay.PassCreationError" code:10002 userInfo:@{NSLocalizedDescriptionKey:@"There was an error creating your pass. Please try again or proceed to the help desk."}];
                      }
                  }
                  else
                  {
                      requestError = [NSError errorWithDomain:@"com.MeetingPlay.PassCreationError" code:10002 userInfo:@{NSLocalizedDescriptionKey:@"There was an error creating your pass. Please try again or proceed to the help desk."}];
                  }
              }
              
              if (requestError)
              {
                  SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Wallet Pass Error"
                                                               andMessage:requestError.localizedDescription];
                  [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
                  [alert show];
              }
          });
      }] resume];
}

@end
