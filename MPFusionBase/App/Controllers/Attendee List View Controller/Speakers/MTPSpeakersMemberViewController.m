//
//  MTPSpeakersMemberViewController.m
//  MPFusionBaseProject
//
//  Created by Admin on 8/18/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPSpeakersMemberViewController.h"
#import "MTPSpeakerMemberTableViewCell.h"
#import "MTPSessionDataViewController.h"
#import "MAMWebViewController.h"
#import "MTPSpeakerCoordinator.h"
#import "MTPSessionManager.h"

#import "MTPAPIDataInitializer.h"
#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"
#import "MTPAppSettingsKeys.h"
#import "MBProgressHUD.h"
#import "MTPDLogDefine.h"

#import "UIColor+AppColors.h"
#import "UIView+MTPCategory.h"
#import "UIViewController+NavigationItemSetup.h"
#import "UIImageView+WebCache.h"
#import "NSString+MTPWebViewURL.h"
#import "UIButton+MTPNavigationBar.h"

@interface MTPSpeakersMemberViewController ()<UITableViewDataSource, UITableViewDelegate, MTPSessionDataDelegate>

@property (weak, nonatomic) IBOutlet UIView *aboutView;
@property (weak, nonatomic) IBOutlet UIView *speakingAtView;
@property (weak, nonatomic) IBOutlet UIView *sessionAssignView;

@property (weak, nonatomic) IBOutlet UITableView *sessionDataTable;

@property (strong, nonatomic) IBOutlet MTPSessionDataViewController *sessionDataViewController;

@end

@implementation MTPSpeakersMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configureWithThemeOptions:self.themeOptionsManager.themeOptions];
    [self.tableView registerNib:[UINib nibWithNibName:@"MTPSpeakerMemberTableViewCell" bundle:nil] forCellReuseIdentifier:@"MTPSpeakerMemberTableViewCell"];
    
    [self setupNavigationItem:[[self.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];
    
    [self.sessionDataViewController prepareSessionDataTable:self.sessionDataTable];
    self.sessionDataViewController.agendaAppearanceOptions = self.navigationRouter.themeOptionsManager.themeOptions[@"speakers"];
    self.sessionDataViewController.delegate = self;
    
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 500;
    
    self.sessionAssignView.hidden = YES;
    self.sessionDataTable.hidden = YES;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(&*self)weakSelf = self;
    [_navigationRouter.dataInitializer.speakerCoordinator fetchSpeakerWithSpeakerId:_speaker.speakerID completion:^(NSArray<MTPSession *> *sessions, NSError *error) {
        weakSelf.speaker.sessionData = sessions;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (sessions.count > 0) {
                self.sessionDataTable.hidden = NO;
            } else {
                self.sessionAssignView.hidden = NO;
            }
            
            [weakSelf.sessionDataViewController loadSessionData:[MTPSessionManager sortSessions:sessions]];
            
            if (sessions.count > 1) {
                self.sessionTitleView.text = [NSString stringWithFormat:@"%@'s Sessions", self.speaker.firstname];
            } else {
                self.sessionTitleView.text = [NSString stringWithFormat:@"%@'s Session", self.speaker.firstname];
            }
            
            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
        });
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setupViews];
    
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
    
    [[self navigationItem] setLeftBarButtonItem:[UIButton toggleMainMenuButton:@{@"imageName": @"backIcon"} target:self selector:@selector(toggleMenu:)]];
}

- (void)setupViews {
    
    self.speakerHeaderLabel.text = [NSString stringWithFormat:@"%@ %@", self.speaker.firstname, self.speaker.lastname];
    self.speakerLocationLabel.text = self.speaker.jobTitle;
    
    if (self.speaker.photo)
    {
        NSString *profileImageURL = [[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MTPL_SpeakersProfileURL"],self.speaker.photo] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [self.userImageView sd_setImageWithURL:[NSURL URLWithString:profileImageURL] placeholderImage:[UIImage imageNamed:@"no_photo"]];
    }
    
    [self.userImageView setRoundWithRadius:3.0 borderWidth:.0f borderColor:[UIColor clearColor]];
    
    [self.aboutButton setRoundWithRadius:15.0 borderWidth:1.0 borderColor:self.selectedColor];
    [self.speakingAtButton setRoundWithRadius:15.0 borderWidth:1.0 borderColor:self.selectedColor];
    [self.aboutButton setTitleColor:self.unSelectedTextColor forState:UIControlStateNormal];
    [self.speakingAtButton setTitleColor:self.unSelectedTextColor forState:UIControlStateNormal];
    
    self.speakingAtButton.backgroundColor = self.unSelectedColor;
    self.aboutButton.backgroundColor = self.unSelectedColor;
    
    self.sessionTitleView.text = [NSString stringWithFormat:@"%@'s Session", self.speaker.firstname];
    [self.sessionAssignView setRoundWithRadius:0.0 borderWidth:1.0 borderColor:[UIColor blackColor]];
    
    [self setupHeadButtonViews:0];
}

- (void)toggleMenu:(id)sender
{
    if ([self navigationController])
    {
        [[self navigationController] popViewControllerAnimated:true];
    }
}


- (void)configureWithThemeOptions:(NSDictionary *)themeOptions
{
    NSDictionary *speakerOptions = themeOptions[@"speakers"];
    self.speakerListHeaderContainer.backgroundColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"headerBackground"]];
    self.speakerHeaderLabel.textColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"headerTextColor"]];
    self.speakerLocationLabel.textColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"headerTextColor"]];
    self.selectedColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"headerBackground"]];
    self.selectedTextColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"sectionTextSelected"]];
    self.unSelectedColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"sectionFillUnselected"]];
    self.unSelectedTextColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"headerBackground"]];
}

- (void)setupHeadButtonViews:(NSInteger)type {
    switch (type) {
        case MTPSpeakerMemberPageTypeAbout: {
            self.aboutView.hidden = NO;
            self.speakingAtView.hidden = YES;
            self.aboutButton.backgroundColor = self.selectedColor;
            [self.aboutButton setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
            [self.speakingAtButton setTitleColor:self.unSelectedTextColor forState:UIControlStateNormal];
            self.speakingAtButton.backgroundColor = self.unSelectedColor;
        }
            break;
            
        case MTPSpeakerMemberPageTypeSpeakingAt: {
            self.aboutView.hidden = YES;
            self.speakingAtView.hidden = NO;
            [self.aboutButton setTitleColor:self.unSelectedTextColor forState:UIControlStateNormal];
            [self.speakingAtButton setTitleColor:self.selectedTextColor forState:UIControlStateNormal];
            self.speakingAtButton.backgroundColor = self.selectedColor;
            self.aboutButton.backgroundColor = self.unSelectedColor;
            
        }
            break;
        default:
            break;
    }
}

#pragma mark - IBActions

- (IBAction)toggleAboutButtonAction:(UIButton *)sender {
    [self setupHeadButtonViews:sender.tag];
}


#pragma mark - UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MTPSpeakerMemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MTPSpeakerMemberTableViewCell"];
    if (indexPath.row == 0) {
        [cell configureCell:self.speaker.company font:[UIFont fontWithName:@"Roboto-Regular" size:15.f] isCompany:YES];
    } else {
        [cell configureCell:self.speaker.bio font:[UIFont fontWithName:@"Roboto-Italic" size:12.f] isCompany:NO];
    }
    return  cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

}

#pragma mark - MTPSessionDataDelegate

- (void)sessionDataController:(MTPSessionDataViewController *)dataController didSelectionSession:(MTPSession *)session {
#warning NEED TO UPDATE TO SUPPORT WKWEBVIEW
    MAMWebViewController *sessionDetails = [[MAMWebViewController alloc] initWithNibName:NSStringFromClass([MAMWebViewController class]) bundle:nil];
    sessionDetails.customURL = [NSString stringWithFormat:[NSString sessionDetailsURL],session.schedule_id];
    sessionDetails.currentUser = self.currentUser;
    
    sessionDetails.themeOptionsManager = self.themeOptionsManager;
    sessionDetails.navigationRouter = self.navigationRouter;
    
    UIBarButtonItem *customBackButton = [UIButton refreshMenuButton:@{@"imageName": @"backIcon"}
                                                             target:sessionDetails
                                                           selector:@selector(returnPrevious:)];
    [customBackButton setTarget:sessionDetails];
    [customBackButton setAction:@selector(returnPrevious:)];
    
    [sessionDetails setCustomLeftBarItem:customBackButton];
    
    [self.navigationController pushViewController:sessionDetails animated:YES];
}

@end
