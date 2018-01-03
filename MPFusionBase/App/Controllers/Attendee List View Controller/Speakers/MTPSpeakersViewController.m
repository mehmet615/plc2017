//
//  MTPSpeakersViewController.m
//
//  Created by MeetingPlay on 8/8/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPSpeakersViewController.h"
#import "MTPSpeakersListCell.h"
#import "MTPAttendeeSectionCell.h"
#import "User.h"
#import "MTPSpeaker.h"
#import "MTPSpeakerCoordinator.h"
#import "MTPSpeakersMemberViewController.h"

#import "MTPAPIDataInitializer.h"
#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"

#import "UIColor+AppColors.h"
#import "UIViewController+NavigationItemSetup.h"
#import "MTPDLogDefine.h"
#import "MTPAppSettingsKeys.h"

#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

@interface MTPSpeakersViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSArray *sectionKeys;
@property (strong, nonatomic) NSDictionary *speakersBySection;
@property (assign, nonatomic) BOOL sectionInitiatedScroll;

@property (strong, nonatomic) UIColor *ellipsisBorderColor;
@property (strong, nonatomic) UIColor *ellipsisFillColor;
@property (strong, nonatomic) UIColor *ellipsisColor;

@property (strong, nonatomic) UIColor *sectionCellSelectedColor;
@property (strong, nonatomic) UIColor *sectionCellSelectedTextColor;
@property (strong, nonatomic) UIColor *sectionCellunselectedColor;
@property (strong, nonatomic) UIColor *sectionCellunselectedTextColor;
@end

@implementation MTPSpeakersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sectionInitiatedScroll = NO;
    
    [self configureWithThemeOptions:self.themeOptionsManager.themeOptions];
    [self.sectionSelectionCollectionView setAllowsMultipleSelection:NO];
    [self.sectionSelectionCollectionView registerNib:[UINib nibWithNibName:@"MTPAttendeeSectionCell" bundle:nil] forCellWithReuseIdentifier:@"MTPAttendeeSectionCell"];
    [self.speakerListCollectionView registerNib:[UINib nibWithNibName:@"MTPSpeakersListCell" bundle:nil] forCellWithReuseIdentifier:@"MTPSpeakersListCell"];
    
    [self setupNavigationItem:[[self.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(&*self)weakSelf = self;
    [self.navigationRouter.dataInitializer.speakerCoordinator fetchSpeakers:YES completion:^(NSArray *speakers, NSError *error)
    {
        if (error)
        {
            DLog(@"\ndebugging message %@",error);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf loadData:speakers];
            
            [weakSelf.sectionSelectionCollectionView reloadData];
            [weakSelf.speakerListCollectionView reloadData];
            
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
    NSDictionary *speakerOptions = themeOptions[@"speakers"];
    self.speakerListHeaderContainer.backgroundColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"headerBackground"]];
    self.speakerListHeader.textColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"headerTextColor"]];
    self.sectionCellSelectedColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"sectionFillSelected"]];
    self.sectionCellSelectedTextColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"sectionTextSelected"]];
    self.sectionCellunselectedColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"sectionFillUnselected"]];
    self.sectionCellunselectedTextColor = [UIColor mtp_colorFromString:[speakerOptions objectForKey:@"sectionTextUnselected"]];
}

- (void)loadData:(NSArray *)attendeeData
{
    NSMutableDictionary *lastNameSections = [NSMutableDictionary new];
    [attendeeData enumerateObjectsUsingBlock:^(MTPSpeaker *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.lastname.length > 1)
        {
            NSString *firstLetter = [obj.lastname substringToIndex:1];
            if (firstLetter.length)
            {
                NSArray *namesInSection = lastNameSections[firstLetter];
                if (namesInSection.count == 0)
                {
                    namesInSection = [NSArray new];
                }
                namesInSection = [namesInSection arrayByAddingObject:obj];
                [lastNameSections setObject:namesInSection forKey:firstLetter];
            }
        }
    }];
    
    NSArray *sortedKeys = [[lastNameSections allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }];
    self.sectionKeys = sortedKeys;
    
    NSMutableDictionary *speakerLetterSection = [NSMutableDictionary new];
    for (NSString *letterSection in sortedKeys)
    {
        NSArray *sectionAttendees = [lastNameSections[letterSection] sortedArrayUsingComparator:^NSComparisonResult(MTPSpeaker * _Nonnull obj1, MTPSpeaker * _Nonnull obj2) {
            return [obj1.lastname compare:obj2.lastname options:NSCaseInsensitiveSearch];
        }];
        if (sectionAttendees.count)
        {
            [speakerLetterSection setObject:sectionAttendees forKey:letterSection];
        }
    }
    self.speakersBySection = [NSDictionary dictionaryWithDictionary:speakerLetterSection];
}

#pragma mark - Protocol Conformance
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (collectionView == self.sectionSelectionCollectionView)
    {
        return 1;
    }
    
    return self.sectionKeys.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == self.sectionSelectionCollectionView)
    {
        return self.sectionKeys.count;
    }
    
    NSArray *sectionAttendees = self.speakersBySection[self.sectionKeys[section]];
    NSInteger count = sectionAttendees.count;
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.sectionSelectionCollectionView)
    {
        MTPAttendeeSectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MTPAttendeeSectionCell" forIndexPath:indexPath];
        NSString *sectionIndicator = self.sectionKeys[indexPath.row];
        cell.sectionIndicator.text = sectionIndicator;
        
        cell.selectedColor = self.sectionCellSelectedColor;
        cell.selectedTextColor = self.sectionCellSelectedTextColor;
        cell.unselectedColor = self.sectionCellunselectedColor;
        cell.unselectedTextColor = self.sectionCellunselectedTextColor;
        
        return cell;
    }
    else
    {
        MTPSpeakersListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MTPSpeakersListCell" forIndexPath:indexPath];
        NSString *section = self.sectionKeys[indexPath.section];
        NSArray *sectionAttendees = self.speakersBySection[section];
        NSInteger indexRow = indexPath.row;

        MTPSpeaker *speaker = sectionAttendees[indexRow];
        cell = [self configureSpeakerCell:cell speaker:speaker indexPath:indexPath];
        
        return cell;
    }
}

- (MTPSpeakersListCell *)configureSpeakerCell:(MTPSpeakersListCell *)cell speaker:(MTPSpeaker *)attendee indexPath:(NSIndexPath *)indexPath
{
    cell.initialsLabel.text = [NSString stringWithFormat:@"%c%c",[attendee.firstname characterAtIndex:0],[attendee.lastname characterAtIndex:0]];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@, %@",attendee.lastname,attendee.firstname];
    cell.detailLabel.text = [NSString stringWithFormat:@"%@",attendee.company];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@",attendee.jobTitle];
    
    [cell.imageView setImage:[UIImage new]];
    if (attendee.photo.length)
    {
        NSString *profileImageURL = [[NSString stringWithFormat:@"%@%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"MTPL_SpeakersProfileURL"],attendee.photo] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:profileImageURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (image)
                 {
                     MTPSpeakersListCell *speakerCell = (MTPSpeakersListCell *)[self.speakerListCollectionView cellForItemAtIndexPath:indexPath];
                     speakerCell.imageView.image = image;
                 }
             });
         }];
    }
    
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
        if (collectionView == self.sectionSelectionCollectionView)
        {
            height = CGRectGetHeight(collectionView.frame) - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom;
            width = height + 5;
            cellSize = CGSizeMake(width, height);
        }
        else
        {
            width = CGRectGetWidth(collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right;
            height = 70;
            cellSize = CGSizeMake(width, height);
        }
    }
    
    return cellSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == self.sectionSelectionCollectionView)
    {
        self.sectionInitiatedScroll = YES;
        [self.speakerListCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.row] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
    else if (collectionView == self.speakerListCollectionView)
    {
        NSString *section = self.sectionKeys[indexPath.section];
        NSArray *sectionSpeakers = self.speakersBySection[section];
        NSInteger indexRow = indexPath.row;
        
        MTPSpeaker *speaker = sectionSpeakers[indexRow];
        [self loadAttendee:speaker];
        
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

- (void)loadAttendee:(MTPSpeaker *)attendee
{
    
    MTPSpeakersMemberViewController *memberVC = [[MTPSpeakersMemberViewController alloc] initWithNibName:@"MTPSpeakersMemberViewController" bundle:nil];
    memberVC.speaker = attendee;
    memberVC.themeOptionsManager = self.themeOptionsManager;
    memberVC.navigationRouter = self.navigationRouter;
    [self.navigationController pushViewController:memberVC animated:YES];
    /*
    MAMWebViewController *webViewController = [[MAMWebViewController alloc] initWithNibName:@"MAMWebViewController" bundle:nil];
    webViewController.customURL = [[NSString attendeeProfile:attendee.user_id] stringByAppendingString:@"?source=nativeAgenda"];
    webViewController.currentUser = self.navigationRouter.currentUser;
    
    webViewController.menuToggleDelegate = self.navigationRouter.routerDelegate;
    
    webViewController.themeOptionsManager = self.themeOptionsManager;
    webViewController.navigationRouter = self.navigationRouter;
    
    [self.navigationController pushViewController:webViewController animated:YES];
     */
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.speakerListCollectionView)
    {
        if (self.sectionInitiatedScroll == NO)
        {
            NSArray *visibleCells = [[self.speakerListCollectionView indexPathsForVisibleItems] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                return [obj1 compare:obj2];
            }];
            
            if (visibleCells.count)
            {
                NSIndexPath *firstCellIndex = [visibleCells firstObject];
                [self.sectionSelectionCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:firstCellIndex.section inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            }
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.sectionInitiatedScroll = NO;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.sectionInitiatedScroll = NO;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
