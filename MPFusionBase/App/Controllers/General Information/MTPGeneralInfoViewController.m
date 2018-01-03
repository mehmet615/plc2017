//
//  MTPGeneralInfoViewController.m
//  MPFusionBaseProject
//
//  Created by Admin on 8/20/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPGeneralInfoViewController.h"
#import "MTPGeneralInfoListCell.h"
#import "MTPGeneralInfoCoordinator.h"
#import "MTPGeneralInformation.h"
#import "MTPGeneralMemberViewController.h"

#import "MTPAPIDataInitializer.h"
#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"

#import "UIColor+AppColors.h"
#import "UIViewController+NavigationItemSetup.h"
#import "MTPDLogDefine.h"
#import "MTPAppSettingsKeys.h"
#import "UIButton+MTPNavigationBar.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface MTPGeneralInfoViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) NSArray *generalInfos;

@end

@implementation MTPGeneralInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self configureWithThemeOptions:self.themeOptionsManager.themeOptions];
    
    [self setupNavigationItem:[[self.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];
    
    [self.generalInfoCollectionView setAllowsMultipleSelection:NO];
    [self.generalInfoCollectionView registerNib:[UINib nibWithNibName:@"MTPGeneralInfoListCell" bundle:nil] forCellWithReuseIdentifier:@"MTPGeneralInfoListCell"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(&*self)weakSelf = self;
    [self.navigationRouter.dataInitializer.generalInfoCoordinator fetchGeneralInfo:YES completion:^(NSArray *generalInfos, NSError *error)
     {
         if (error)
         {
             DLog(@"\ndebugging message %@",error);
         }
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf loadData:generalInfos];
             
             [weakSelf.generalInfoCollectionView reloadData];
             
             [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
         });
     }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
}

- (void)configureWithThemeOptions:(NSDictionary *)themeOptions
{
    NSDictionary *speakerOptions = themeOptions[@"generalInfo"];
    self.generalInfoHeaderContainer.backgroundColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"headerBackground"]];
    self.headerTitleLabel.textColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"headerTextColor"]];
    self.headerTitleLabel.font = [UIFont fontWithName:@"Lato-Bold" size:17.0];
}


- (void)loadData:(NSArray *)attendeeData {
    NSArray *sortedArray = [attendeeData sortedArrayUsingComparator:^NSComparisonResult(MTPGeneralInformation  *obj1, MTPGeneralInformation  *obj2) {
        return [obj1.sortOrderID compare:obj2.sortOrderID];
    }];
    
    self.generalInfos = sortedArray;
}

- (void)loadAttendee:(MTPGeneralInformation *)attendee
{
    MTPGeneralMemberViewController *memberVC = [[MTPGeneralMemberViewController alloc] initWithNibName:@"MTPGeneralMemberViewController" bundle:nil];
    memberVC.generalInfo = attendee;
    memberVC.themeOptionsManager = self.themeOptionsManager;
    memberVC.navigationRouter = self.navigationRouter;
    [self.navigationController pushViewController:memberVC animated:YES];
}

#pragma mark - Protocol Conformance
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.generalInfos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTPGeneralInfoListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MTPGeneralInfoListCell" forIndexPath:indexPath];
    NSInteger indexRow = indexPath.row;
    
    MTPGeneralInformation *generalInfo = self.generalInfos[indexRow];
    cell = [self configureSpeakerCell:cell generalInfo:generalInfo indexPath:indexPath];
    return cell;
}

- (MTPGeneralInfoListCell *)configureSpeakerCell:(MTPGeneralInfoListCell *)cell generalInfo:(MTPGeneralInformation *)attendee indexPath:(NSIndexPath *)indexPath
{
    cell.infoNameLabel.text = attendee.title;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeZero;
    CGFloat width = 0;
    CGFloat height = 0;
    
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]])
    {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
        width = CGRectGetWidth(collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
        height = 60;
        cellSize = CGSizeMake(width, height);
    }
    
    return cellSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger indexRow = indexPath.row;
    
    MTPGeneralInformation *generalInfo = self.generalInfos[indexRow];
    [self loadAttendee:generalInfo];
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

#pragma mark - Other
- (void)toggleMenu:(id)sender
{
    if (self.menuToggler && [self.menuToggler respondsToSelector:@selector(topViewControllerShouldToggleMenu:)])
    {
        [self.menuToggler topViewControllerShouldToggleMenu:nil];
    }
    else
    {
        DLog(@"no delegate found");
    }
}

@end
