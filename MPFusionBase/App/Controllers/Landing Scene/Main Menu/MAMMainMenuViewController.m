//
//  MAMMainMenuViewController.m
//
//  Created by MeetingPlay on 4/10/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMMainMenuViewController.h"
#import "UIView+AutoLayoutHelper.h"
#import "MAMMainMenuTableViewCell.h"
#import "MAMStoryboardIdentifiers.h"
#import "MTPMenuItem.h"
#import "MTPMenuIcon.h"
#import "MDMyConnectionManager.h"
#import "MTPNavigationMenuLoader.h"
#import "MTPMenuItemManager.h"

#import "User+Helpers.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "UIImageView+AFNetworking.h"
#import "UIColor+AppColors.h"
#import "NSURLSession+MTPCategory.h"
#import "NSString+MTPAPIAddresses.h"
#import "MTPAppSettingsKeys.h"
#import "CHAFontAwesome.h"
#import "MTPApplicationDefaultsConstants.h"

#import "MTPPassCreator.h"
#import <PassKit/PassKit.h>

#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"
#import "MTPThemeOptionsUpdater.h"
#import "MTPMenuItemManager.h"
#import "UIImageView+WebCache.h"

@interface MAMMainMenuViewController () <MTPMainMenuHeaderDelegate>
@property (strong, nonatomic) NSArray *temporaryMenuItems;
@property (readwrite, nonatomic) NSArray *mainMenuItems;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *dividerTitleLabelHeight;
@property (strong, nonatomic) UIColor *menuItemColor;
@property (strong, nonatomic) UIColor *menuItemTextColor;
@property (strong, nonatomic) UIColor *menuItemActiveColor;
@property (strong, nonatomic) UIColor *menuItemActiveTextColor;
@property (strong, nonatomic) UIColor *menuItemActiveBackgroundColor;
@property (strong, nonatomic) UIColor *menuBackgroundColor;
@property (strong, nonatomic) MTPPassCreator *passCreator;
@end

@implementation MAMMainMenuViewController

BOOL MTP_MENU_ITEM_IMAGE_TINTING = NO;

#pragma mark - View Life Cycle
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.visiblityState = MTPMainMenuVisibilityStateHidden;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
//    self.mainMenuItems = [self.navigationRouter.menuItemManager sideNavigationItems];
    
    self.menuTableView.estimatedRowHeight = 44.f;
    self.menuTableView.separatorInset = UIEdgeInsetsZero;
    if ([self.menuTableView respondsToSelector:@selector(layoutMargins)])
    {
        self.menuTableView.layoutMargins = UIEdgeInsetsZero;
    }

    [self setupViewConstraints];
    [self registerForNotifications];
    
    [self configureHeaderView];
    [self setupPageBackground];
    
    [self setupMenuColors];
    
    id visible = [self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_sideBar] objectForKey:@"dividerTitleVisible"];
    self.dividerTitleLabelHeight.constant = [visible boolValue] ? MTP_MAINMENUHEADER_DIVIDER_HEIGHT : 0;
    
    self.passCreator = [MTPPassCreator new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadAppearance
{
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self configureHeaderView];
        [self setupPageBackground];
        [self setupMenuColors];
        
        id visible = [self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_sideBar] objectForKey:@"dividerTitleVisible"];
        self.dividerTitleLabelHeight.constant = [visible boolValue] ? MTP_MAINMENUHEADER_DIVIDER_HEIGHT : 0;
    });
}

- (void)setupMenuColors
{
    self.menuItemColor = [UIColor mtp_colorFromString:[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color8]];
    self.menuItemTextColor = [UIColor mtp_colorFromString:[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color8]];
    
    self.menuItemActiveColor = [UIColor mtp_colorFromString:[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color11]];
    self.menuItemActiveTextColor = [UIColor mtp_colorFromString:[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color11]];
    
    self.menuItemActiveBackgroundColor = [UIColor mtp_colorFromString:[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color12]];
    
    self.menuBackgroundColor = [UIColor mtp_colorFromString:[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color13]];
    self.menuTableView.tableFooterView.backgroundColor = [UIColor mtp_colorFromString:[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color23]];
}

- (void)setupPageBackground
{
    self.mainMenuBackgroundImage.image = nil;
    UIColor *mainMenuBackgroundColor = [UIColor mtp_colorFromString:[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color13]];
    if (mainMenuBackgroundColor)
    {
        self.view.backgroundColor = mainMenuBackgroundColor;
    }
    
    MTPThemeOptionsManager *themeOptionsManager = self.navigationRouter.themeOptionsManager;
    NSString *pageBackground = [[themeOptionsManager.themeOptions objectForKey:MPFUSION_sideBar] objectForKey:@"background"];
    if (pageBackground.length == 0)
    {
        return;
    }
    
    if ([pageBackground rangeOfString:@"http"].location == NSNotFound)
    {
        [self.mainMenuBackgroundImage setImage:[UIImage imageNamed:pageBackground]];
    }
    else
    {
        __weak typeof(&*self)weakSelf = self;
        NSURL *pageBackgroundSaveURL = [MTPThemeOptionsManager saveURLForImage:pageBackground];
        [self configureWithImage:pageBackground saveURL:pageBackgroundSaveURL completion:^(UIImage *fetchedImage, NSError *error) {
            if (error)
            {
                [weakSelf.mainMenuBackgroundImage sd_setImageWithURL:[NSURL URLWithString:pageBackground] placeholderImage:[UIImage imageNamed:@"loginBackground"]];
            }
            else
            {
                weakSelf.mainMenuBackgroundImage.image = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakSelf.mainMenuBackgroundImage.image = fetchedImage;
                });
            }
        }];
    }
}

- (void)configureHeaderView
{
    self.headerView.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.headerView configureWithTheme:self.navigationRouter.themeOptionsManager.themeOptions];
    });
    
    MTPThemeOptionsManager *themeOptionsManager = self.navigationRouter.themeOptionsManager;
    NSString *sideBarImage = [[themeOptionsManager.themeOptions objectForKey:MPFUSION_sideBar] objectForKey:MPFUSION_sideBarImage];
    if (sideBarImage.length == 0)
    {
        self.headerView.eventTextDetailsContainer.hidden = NO;
        return;
    }
    
    self.headerView.eventTextDetailsContainer.hidden = YES;
    
    if ([sideBarImage rangeOfString:@"http"].location == NSNotFound)
    {
        self.headerView.sideBarImage.hidden = NO;
        [self.headerView loadSideBarImage:[UIImage imageNamed:sideBarImage]];
    }
    else
    {
        __weak typeof(&*self)weakSelf = self;
        NSURL *pageBackgroundSaveURL = [MTPThemeOptionsManager saveURLForImage:sideBarImage];
        [self configureWithImage:sideBarImage saveURL:pageBackgroundSaveURL completion:^(UIImage *fetchedImage, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    weakSelf.headerView.sideBarImage.hidden = YES;
                }
                else
                {
                    weakSelf.headerView.sideBarImage.hidden = NO;
                    [weakSelf.headerView loadSideBarImage:fetchedImage];
                }
            });
        }];
    }
}

- (void)configureWithImage:(NSString *)imageRemotePath saveURL:(NSURL *)localSaveURL completion:(void(^)(UIImage *fetchedImage, NSError *error))completionHandler
{
    MTPThemeOptionsManager *themeOptionsManager = self.navigationRouter.themeOptionsManager;
    [themeOptionsManager fetchImage:imageRemotePath saveURL:localSaveURL completion:^(UIImage *fetchedImage, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionHandler)
            {
                completionHandler(fetchedImage,error);
            }
        });
    }];
}

#pragma mark - Protocol Conformance

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.mainMenuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAMMainMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MAMMainMenuTableViewCellIdentifier
                                                                     forIndexPath:indexPath];
    
    cell = [self configureCell:cell dataSource:self.mainMenuItems atIndexPath:indexPath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    [self processTableView:tableView selection:indexPath tableData:self.mainMenuItems];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.menuTableView.estimatedRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.menuTableView.estimatedRowHeight;
}

- (void)mainMenuHeader:(MTPMainMenuHeaderView *)headerView didSearch:(NSString *)searchQuery
{
    [self.navigationRouter loadSearch:searchQuery];
}


#pragma mark - IBActions
#pragma mark - Helper Methods
- (MAMMainMenuTableViewCell *)configureCell:(MAMMainMenuTableViewCell *)cell
                                 dataSource:(id)dataSource
                                atIndexPath:(NSIndexPath *)indexPath
{
    cell.defaultBackgroundColor = self.menuBackgroundColor;
    
    cell.defaultIconColor = self.menuItemColor;
    cell.defaultTextColor = self.menuItemTextColor;
    
    cell.activeIconColor = self.menuItemActiveColor;
    cell.activeTextColor = self.menuItemActiveTextColor;
    cell.activeBackgroundColor = self.menuItemActiveBackgroundColor;
    
    cell.menuItem = dataSource[indexPath.row];
    cell.iconImage.image = nil;
    
    __weak MAMMainMenuTableViewCell *weakCell = cell;
    if (cell.menuItem.icon.length)
    {
        if ([cell.menuItem.icon rangeOfString:@"http"].location == NSNotFound)
        {
            UIImage *menuIcon = [UIImage imageNamed:cell.menuItem.icon];
            cell.iconImage.image = [menuIcon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [cell.iconImage sd_setImageWithURL:[NSURL URLWithString:cell.menuItem.icon] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                 
                 {
                     if (error)
                     {
                         weakCell.iconLabel.hidden = NO;
                         if (weakCell.menuItem.fontAwesome.length)
                         {
                             cell.iconLabel.text = [CHAFontAwesome icon:cell.menuItem.fontAwesome];
                         }
                     }
                     else
                     {
                         weakCell.iconLabel.hidden = YES;
                     }
                     
                     if (MTP_MENU_ITEM_IMAGE_TINTING)
                     {
                         weakCell.iconImage.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                     }
                 }];
            });
        }
    }
    else
    {
        cell.iconLabel.hidden = NO;
        cell.iconImage.hidden = YES;
        cell.iconLabel.text = [CHAFontAwesome icon:cell.menuItem.fontAwesome];
    }
    
    cell.menuItemLabel.text = cell.menuItem.title;
    
    return cell;
}

#pragma mark Menu Visibility
- (void)toggleMenu:(id)sender
{
    if (self.mainMenuDelegate && [self.mainMenuDelegate respondsToSelector:@selector(mainMenuDidToggleMenu:)])
    {
        [self.mainMenuDelegate mainMenuDidToggleMenu:self];
    }
    
    [self.view endEditing:YES];
}

- (void)menuSelectable:(BOOL)selectable
{
    self.headerView.hidden = !selectable;
    self.menuTableView.hidden = !selectable;
    self.menuFooterView.hidden = !selectable;
    
    [self.menuTableView reloadData];
}

#pragma mark Menu Item Loading
- (void)processTableView:(UITableView *)tableView
               selection:(NSIndexPath *)indexPath
               tableData:(id)tableData
{
    if ([tableData isKindOfClass:[NSArray class]])
    {
        [self loadMainMenuItem:tableData[indexPath.row]];
    }
}

- (void)loadMainMenuItem:(MTPMenuItem *)menuItem
{
    if (menuItem.contentType == MTPContentTypeLogout)
    {
        NSIndexPath *indexOfLogout = [NSIndexPath indexPathForRow:[self.mainMenuItems indexOfObject:menuItem] inSection:0];
        [self.menuTableView deselectRowAtIndexPath:indexOfLogout animated:YES];
        [[NSNotificationCenter defaultCenter] postNotificationName:MTP_LogoutNotification object:nil];
        [self.navigationRouter loadLogin:self.navigationRouter.rootObjectContext];
        self.menuTableView.contentOffset = CGPointZero;
    }
    if (menuItem.contentType == MTPContentTypePassKit)
    {
        if ([PKAddPassesViewController canAddPasses])
        {
            [self.passCreator processPassRequest:self.navigationRouter.currentUser.user_id feedbackView:self.view presentationTarget:self];
        }
        else
        {
            [self showAddPassError];
        }
    }
    else
    {
        [self.navigationRouter loadViewController:menuItem animated:NO];
    }
}

- (void)showAddPassError
{
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:@"Pass Creation Error" andMessage:@"We were unable to add a pass because your device lack support"];
    [alert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
    [alert show];
}

- (void)reloadMainMenuData:(void(^)(NSArray *menuItemCollection))reloadCompletionHandler
{
    if (reloadCompletionHandler)
    {
        reloadCompletionHandler(nil);
    }
}

- (IBAction)didPressEditProfile:(id)sender
{
    if (self.editProfilePresentationTarget && [self.editProfilePresentationTarget respondsToSelector:@selector(toggleEditProfileVisibility)])
    {
        [self.editProfilePresentationTarget toggleEditProfileVisibility];
    }
}

#pragma mark - Initial Setup
- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginNotificationReceived:) name:MTP_LoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTheme:) name:@"MTP_ThemeOptionsDidUpdateNotification" object:nil];
}

- (void)loginNotificationReceived:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configureHeaderView];
        [self updateNavigationItems];
        [self setupMenuColors];
    });
}

- (void)reloadTheme:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self configureHeaderView];
        [self updateNavigationItems];
        [self setupMenuColors];
    });
}

- (void)updateNavigationItems
{
    NSDictionary *conferenceDetails = [[NSUserDefaults standardUserDefaults] objectForKey:MTP_ConferenceMenuDetails];
    
    NSString *meetingName = [conferenceDetails objectForKey:MTP_ConferenceMenuRemoteFolder];
    NSAssert(meetingName.length != 0,@"Remote Menu Folder Name is missing from EventDefaults");
    NSString *menuName = [conferenceDetails objectForKey:MTP_ConferenceMenuRemoteFilename];
    NSAssert(menuName.length != 0,@"Remote Menu File Name is missing from EventDefaults");
    
    __weak typeof(&*self)weakSelf = self;
    
    [self.navigationRouter.menuItemManager.menuLoader availableMeeting:meetingName navigationMenu:menuName lastUpdate:[NSDate date] completionHandler:^(BOOL menuUpdateAvailable, NSError *availabilityCheckError)
     {
         if (menuUpdateAvailable)
         {
             [weakSelf beginMenuUpdate:meetingName meetingName:menuName];
         }
         else
         {
             DLog(@"\nNo menu update was available");
         }
     }];
}

- (void)beginMenuUpdate:(NSString *)menuName meetingName:(NSString *)meetingName
{
    __weak typeof(&*self)weakSelf = self;
    
    [self.navigationRouter.menuItemManager fetchMenuItemsForMeeting:menuName menuFilename:meetingName completion:^(NSArray *navigationItems, NSArray *quickLinksItems, NSError *error)
     {
         NSArray *menuItems = navigationItems;
         if (error || navigationItems.count == 0)
         {
             DLog(@"\nfetch error %@",error);
             menuItems = [weakSelf.navigationRouter.menuItemManager sideNavigationItems];
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             weakSelf.mainMenuItems = menuItems;
             [weakSelf.menuTableView reloadData];
         });
     }];
}

- (void)setupViewConstraints
{
    return;
}







@end
