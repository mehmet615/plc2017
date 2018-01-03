//
//  MAMLocationSelectionViewController.m
//  HPEEvents
//
//  Created by Michael Thongvanh on 10/6/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMLocationSelectionViewController.h"
#import "NSURLSession+MTPCategory.h"
#import "SIAlertView.h"
#import "UIButton+MTPNavigationBar.h"
#import "MAMLoginViewController.h"
#import "MTPLoginClient.h"
#import "MAMRootNavigationViewController.h"
#import "MTPAppSettingsKeys.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"
#import "MTPLanguageSelectionViewController.h"
#import "UIColor+AppColors.h"

@interface MAMLocationSelectionViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate, UISearchBarDelegate, MTPLanguageSelectionDelegate>

@property (weak, nonatomic) IBOutlet UIView *filterContainer;
@property (weak, nonatomic) IBOutlet UITextField *filterListTextField;
@property (weak, nonatomic) IBOutlet UISearchBar *filterListSearchBar;

@property (weak, nonatomic) IBOutlet UITableView *locationsTableView;

@property (nonatomic, strong) NSArray *filteredList;
@property (nonatomic, strong) NSArray *locationsAll;

@end

@implementation MAMLocationSelectionViewController
NSString *const kLocationsListCell = @"locationListCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.filteredList = [NSArray new];
    self.locationsAll = [NSArray new];
    
    self.locationsTableView.dataSource = self;
    self.locationsTableView.delegate = self;
    
    if ([self.locationsTableView respondsToSelector:@selector(layoutMargins)])
    {
        self.locationsTableView.layoutMargins = UIEdgeInsetsZero;
    }
    
    MTPLanguageSelectionViewController *languageSelection = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MTPLanguageSelectionViewController"];
    languageSelection.view.translatesAutoresizingMaskIntoConstraints = NO;
    languageSelection.languageSelectionDelegate = self;
    
    [self.languageSelectionContainer addSubview:languageSelection.view];
    [self.languageSelectionContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[languageSelection]|" options:0 metrics:nil views:@{@"languageSelection":languageSelection.view}]];
    [self.languageSelectionContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[languageSelection]|" options:0 metrics:nil views:@{@"languageSelection":languageSelection.view}]];
    
    [self addChildViewController:languageSelection];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self navigationItem] setTitleView:[UIButton navigationBarLogo:CGRectGetHeight(self.navigationController.navigationBar.frame)]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchData:(NSString *)eventListString
{
    if (eventListString.length == 0)
    {
        NSLog(@"empty event list");
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    NSMutableURLRequest *eventListRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:eventListString]];
    eventListRequest.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:eventListRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error)
        {
            SIAlertView *errorAlert = [[SIAlertView alloc] initWithTitle:@"There was a Problem" andMessage:@"There was a problem fetching the event list data. Press OK to try fetching the event list again."];
            
            __weak __typeof(&*self)weakSelf = self;
            [errorAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) {
                
                [weakSelf fetchData:eventListString];
            }];
            
            [errorAlert addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeCancel handler:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [errorAlert show];
            });
        }
        else
        {
            id responseObject = [NSURLSession serializeJSONData:data response:response error:error];
            if (responseObject)
            {
                __weak __typeof(&*self)weakSelf = self;
                __block NSMutableArray *locations = [NSMutableArray new];
                [responseObject enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    
                    [locations addObject:[obj firstObject]];
                }];
                
                [locations sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    __block NSNumber *obj1Order = @0;
                    obj1Order = [obj1 objectForKey:@"order"];
                    
                    __block NSNumber *obj2Order = @0;
                    obj2Order = [obj2 objectForKey:@"order"];
                    
                    return [obj1Order compare:obj2Order];
                }];
                
                weakSelf.locationsAll = [NSArray arrayWithArray:locations];
                weakSelf.filteredList = [NSArray arrayWithArray:weakSelf.locationsAll];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.locationsTableView reloadData];
                });
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:true];
        });
    }] resume];
}


#pragma mark - Protocol Conformance
#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kLocationsListCell forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(layoutMargins)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    cell.separatorInset = UIEdgeInsetsZero;
    
    [self configureCell:cell data:self.filteredList[indexPath.row] indexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell data:(NSDictionary *)cellData indexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[MAMLocationsListCell class]])
    {
        MAMLocationsListCell *locationCell = (MAMLocationsListCell *)cell;
        
        __block NSDictionary *eventDetails = cellData;
        
        NSString *eventLocation = [eventDetails objectForKey:@"location"];
        NSString *eventDate = [eventDetails objectForKey:@"date"];
        NSString *eventIconURL = [eventDetails objectForKey:@"eventIconURL"];
        NSString *eventName = [eventDetails objectForKey:@"eventName"];
        
        locationCell.eventNameLabel.text = eventName;
        locationCell.eventLocationLabel.text = eventLocation.length > 0 ? eventLocation : @"HP Event";
        locationCell.eventDateLabel.text = eventDate.length > 0 ? eventDate : @"Unknown Date";
        
        if (eventIconURL.length)
        {
            NSURL *iconURL = [NSURL URLWithString:eventIconURL];
            [locationCell.eventIconImage setImageWithURL:iconURL];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    NSDictionary *eventData = self.filteredList[indexPath.row];
    NSString *eventBaseHTTP = [eventData objectForKey:@"url"];
    NSString *eventBaseAPI = [eventData objectForKey:@"apiurl"];
    
    [self configureURL:eventBaseHTTP apiURL:eventBaseAPI];
    [self configureConferenceMenuItemInfo:[eventData objectForKey:MTP_ConferenceMenuDetails]];
    
//    self.view.superview.hidden = YES;
    
    [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
    
    if (self.locationSelectionDelegate && [self.locationSelectionDelegate respondsToSelector:@selector(locationSelector:didSelectLocation:)])
    {
        [self.locationSelectionDelegate locationSelector:self didSelectLocation:eventData];
    }
    else
    {
        DLog(@"delegate check failed %@",self.locationSelectionDelegate);
    }
}

- (void)configureURL:(NSString *)baseHTTP apiURL:(NSString *)baseAPI
{
    NSMutableDictionary *networkOptions = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:MTP_NetworkOptions]];
    if (baseHTTP.length > 0)
    {
        [networkOptions setObject:baseHTTP forKey:MTP_EventBaseHTTPURL];
    }
    
    if (baseAPI.length > 0)
    {
        [networkOptions setObject:baseAPI forKey:MTP_EventBaseAPIURL];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:networkOptions forKey:MTP_NetworkOptions];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)configureConferenceMenuItemInfo:(NSDictionary *)conferenceDetails
{
    if (conferenceDetails.allKeys.count == 0)
    {
        return;
    }
    
    NSMutableDictionary *conferenceInfo = [NSMutableDictionary new];
    
    NSString *remoteFolder = [conferenceDetails objectForKey:MTP_ConferenceMenuRemoteFolder];
    if (remoteFolder.length)
    {
        [conferenceInfo setObject:remoteFolder forKey:MTP_ConferenceMenuRemoteFolder];
    }
    else
    {
        return;
    }
    
    NSString *remoteFilename = [conferenceDetails objectForKey:MTP_ConferenceMenuRemoteFilename];
    if (remoteFilename.length)
    {
        [conferenceInfo setObject:remoteFilename forKey:MTP_ConferenceMenuRemoteFilename];
    }
    else
    {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:conferenceInfo forKey:MTP_ConferenceMenuDetails];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)languageSelector:(MTPLanguageSelectionViewController *)languageSelector didSelectLanguage:(NSDictionary *)languageData
{
    self.languageSelectionContainer.hidden = YES;
    self.locationsTableView.superview.hidden = NO;
    
    [self fetchData:languageData[@"eventList"]];
    self.headerTitleLabel.text = languageData[@"pageTitle"];
    
    NSNumber *languageID = languageData[@"languageID"];
    if (languageID)
    {
        [[NSUserDefaults standardUserDefaults] setObject:languageID forKey:@"lanuageID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end

@implementation MAMLocationsListCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    for (UIView *borderColorView in @[self.contentContainer,self.customAccessoryLabel])
    {
        borderColorView.layer.borderWidth = 0.5;
        borderColorView.layer.borderColor = [UIColor mtp_colorFromString:@"007ac3"].CGColor;
    }
    
    self.customAccessoryLabel.backgroundColor = [UIColor mtp_colorFromString:@"0xeeeeee"];
    [self.contentView sendSubviewToBack:self.customAccessoryLabel];
}

@end