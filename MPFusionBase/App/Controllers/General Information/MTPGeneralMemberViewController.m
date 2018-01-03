//
//  MTPGeneralMemberViewController.m
//  MPFusionBaseProject
//
//  Created by Admin on 8/20/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPGeneralMemberViewController.h"
#import "MTPGeneralInformation.h"
#import "MTPInfoFileTableViewCell.h"

#import "MTPAPIDataInitializer.h"
#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"
#import "MTPGeneralInfoCoordinator.h"

#import "UIColor+AppColors.h"
#import "MTPDLogDefine.h"
#import "MTPAppSettingsKeys.h"

#import "UIViewController+NavigationItemSetup.h"
#import "UIImageView+WebCache.h"
#import "UIButton+MTPNavigationBar.h"

#import <MBProgressHUD.h>

@interface MTPGeneralMemberViewController () <UIWebViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webviewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;

@end

@implementation MTPGeneralMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configureWithThemeOptions:self.themeOptionsManager.themeOptions];
    
    [self setupViews];
    
    [self setupNavigationItem:[[self.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 500;
    
    [self.navigationRouter.dataInitializer.generalInfoCoordinator fetchGeneralInfoWithId:self.generalInfo.contentID completion:^(NSArray <MTPAssetData *> *files, NSError *error) {
        
        __weak typeof(&*self)weakSelf = self;
        weakSelf.generalInfo.files = files;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            if (error == nil) {
                [weakSelf loadImageView];
                [weakSelf.tableView reloadData];
            }
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationItem] setLeftBarButtonItem:[UIButton toggleMainMenuButton:@{@"imageName": @"backIcon"} target:self selector:@selector(toggleMenu:)]];
}

- (void)configureWithThemeOptions:(NSDictionary *)themeOptions
{
    NSDictionary *speakerOptions = themeOptions[@"generalInfo"];
    self.generalInfoHeaderContainer.backgroundColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"headerBackground"]];
    self.headerTitleLabel.textColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"headerTextColor"]];
}

- (void)setupViews {
    self.headerTitleLabel.text = self.generalInfo.title;
    self.headerTitleLabel.font = [UIFont fontWithName:@"Lato-Regular" size:17.0];
    [self.tableView registerNib:[UINib nibWithNibName:@"MTPInfoFileTableViewCell" bundle:nil] forCellReuseIdentifier:@"MTPInfoFileTableViewCell"];
}

- (void)loadImageView {
    NSString *photoUrl = [[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MTPL_GeneralInfoPhotoURL"], self.generalInfo.photo] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:photoUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image != nil) {
            self.imageView.image = image;
            CGFloat ratio = image.size.width / image.size.height;
            self.imageViewHeightConstraint.constant = self.imageView.frame.size.width / ratio;
            [self.view layoutIfNeeded];
        }
    }];
    
    NSString *contentHtmlString = [NSString stringWithFormat:@"<div style='font-family: %@; font-style: %@'> %@ </div>", @"Lato", @"normal", self.generalInfo.content];
    
    [self.webView loadHTMLString:contentHtmlString baseURL: [[NSBundle mainBundle] bundleURL]];
}

- (void)toggleMenu:(id)sender
{
    if ([self navigationController])
    {
        [[self navigationController] popViewControllerAnimated:true];
    }
}

#pragma mark - uitableview datasource and delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  (self.generalInfo.files.count == 0) ? 0 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.generalInfo.files.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MTPInfoFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MTPInfoFileTableViewCell"];
    MTPAssetData *file = [self.generalInfo.files objectAtIndex:indexPath.row];
    [cell configureTableCell:file];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MTPAssetData *file = [self.generalInfo.files objectAtIndex:indexPath.row];
    NSString *assetUrl = [[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MTPL_GeneralInfoAssetURL"], file.assetFile] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.navigationRouter.routerDelegate navigationRouter:self.navigationRouter didLoadDocument:[NSURL URLWithString:assetUrl]];
}

#pragma mark Section Header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *labelContainer = [UIView new];
    NSDictionary *speakerOptions = self.themeOptionsManager.themeOptions[@"generalInfo"];
    labelContainer.backgroundColor = [UIColor mtp_colorFromString:speakerOptions[@"headerBackground"]];
    
    UILabel *sectionLabelName = [UILabel new];
    sectionLabelName.translatesAutoresizingMaskIntoConstraints = NO;
    sectionLabelName.textColor = [UIColor whiteColor];
    sectionLabelName.font = [UIFont fontWithName:@"Lato-Bold" size:20.f];
    sectionLabelName.text = @"Files:";
    
    [labelContainer addSubview:sectionLabelName];
    [labelContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sectionLabelName]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sectionLabelName)]];
    [labelContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[sectionLabelName]-margin-|" options:0 metrics:@{@"margin":@10} views:NSDictionaryOfVariableBindings(sectionLabelName)]];
    
    return labelContainer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}


#pragma mark - webview delegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *str = [webView stringByEvaluatingJavaScriptFromString:@"(document.height !== undefined) ? document.height : document.body.offsetHeight;"];
    CGFloat height = str.floatValue;
    self.webviewHeight.constant = height;
    NSLog(@"ContentSize - %lf", height);
    self.tableViewHeight.constant = self.tableView.contentSize.height;
    [self updateViewConstraints];
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = [NSString stringWithFormat:@"%@",[[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions] objectForKey:MTP_EventBaseHTTPURL]];
    NSString *requestUrlString = request.URL.absoluteString;
    
    switch (navigationType)
    {
        case UIWebViewNavigationTypeLinkClicked:
        {
            if ([request.URL.host rangeOfString:@"documentViewer" options:NSCaseInsensitiveSearch].length)
            {
                [[UIApplication sharedApplication] openURL:request.URL];
                return false;
            }
            else if ([requestUrlString rangeOfString:urlString options:NSCaseInsensitiveSearch].location == NSNotFound)
            {
                [[UIApplication sharedApplication] openURL:request.URL];
                return false;
            }
            break;
        }
            
        case UIWebViewNavigationTypeOther:
        {
            if ([request.URL.host rangeOfString:@"maps.google.com" options:NSCaseInsensitiveSearch].length)
            {
                [[UIApplication sharedApplication] openURL:request.URL];
                return false;
            }
            break;
        }
            
        default:
            break;
    }
    
    return true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
