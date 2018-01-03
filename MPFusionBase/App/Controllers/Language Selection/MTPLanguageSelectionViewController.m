//
//  MTPLanguageSelectionViewController.m
//  PTC16
//
//  Created by Michael Thongvanh on 2/29/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import "MTPLanguageSelectionViewController.h"

@interface MTPLanguageSelectionViewController () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *languageListTableView;
@property (weak, nonatomic) IBOutlet UILabel *selectedLanguageLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *displayLanguageButton;

@property (strong, nonatomic) NSArray *languageData;

@property (strong, nonatomic) NSDictionary *selectedLanguage;

@end

@implementation MTPLanguageSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.languageListTableView.delegate = self;
    self.languageListTableView.dataSource = self;
    
    [self fetchLanguageData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Protocol Conformance

#pragma mark UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.languageData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell.textLabel setFont:[UIFont fontWithName:@"Lato-Light" size:17.f]];
    [cell.textLabel setTextColor:[UIColor colorWithRed:28/255.f green:125/255.f blue:191/255.f alpha:1]];
    
    NSDictionary *languageData = self.languageData[indexPath.row];
    
    cell.textLabel.text = languageData[@"language"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self switchLanguage:self.languageData[indexPath.row]];
    
    [self toggleLanguageTable:@NO];
}

- (void)switchLanguage:(NSDictionary *)languageData
{
    self.selectedLanguage = languageData;
    self.selectedLanguageLabel.text = languageData[@"language"];
    
    if (self.languageSelectionDelegate && [self.languageSelectionDelegate respondsToSelector:@selector(languageSelector:didSelectLanguage:)])
    {
        [self.languageSelectionDelegate languageSelector:self didSelectLanguage:languageData];
    }
    else
    {
        NSLog(@"delegate check failed %@",self.languageSelectionDelegate);
    }
}

#pragma mark - Helper Methods

- (IBAction)pressedDisplayLanguage:(id)sender
{
    [self toggleLanguageTable:nil];
}

- (void)toggleLanguageTable:(NSNumber *)forceVisibility
{
    if (self.languageData.count == 0)
    {
        return;
    }
    
    BOOL hide = NO;
    if (forceVisibility)
    {
        hide = [forceVisibility boolValue];
    }
    else
    {
        hide = !(self.tableViewHeight.constant > 0);
    }
    
    self.tableViewHeight.constant = hide ? 150 : 0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)fetchLanguageData
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://deploy.meetingplay.com//app-navigation/prudential-portal/languages/LanguageOptions.json"]];
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
    
    __weak typeof(&*self)weakSelf = self;
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        if (error)
        {
            NSLog(@"\nerror %@",error);
        }
        else
        {
            NSError *serializationError = nil;
            id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&serializationError];
            if (responseObject)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [weakSelf processResponseObject:responseObject];
                });
            }
            else
            {
                NSLog(@"error %@",serializationError);
            }
        }
    }] resume];
}

- (void)processResponseObject:(id)responseObject
{
    if (![responseObject isKindOfClass:[NSArray class]])
    {
        return;
    }
    
    NSArray *languageOptions = (NSArray *)responseObject;
    self.languageData = languageOptions;
    
    [self.languageListTableView reloadData];
}

@end
