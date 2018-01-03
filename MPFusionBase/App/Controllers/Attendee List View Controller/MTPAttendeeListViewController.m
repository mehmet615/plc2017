//
//  MTPAttendeeListViewController.m
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 8/8/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPAttendeeListViewController.h"
#import "MTPAttendeeListCell.h"
#import "MTPAttendeeSectionCell.h"
#import "User.h"
#import "MTPNavigationRouter.h"
#import "MTPThemeOptionsManager.h"
#import "UIViewController+NavigationItemSetup.h"
#import "MTPDLogDefine.h"

@interface MTPAttendeeListViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSArray *sectionKeys;
@property (strong, nonatomic) NSDictionary *attendeesBySection;
@property (assign, nonatomic) BOOL sectionInitiatedScroll;
@end

@implementation MTPAttendeeListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.sectionInitiatedScroll = NO;
    
    [self.sectionSelectionCollectionView registerNib:[UINib nibWithNibName:@"MTPAttendeeSectionCell" bundle:nil] forCellWithReuseIdentifier:@"MTPAttendeeSectionCell"];
    [self.attendeeListCollectionView registerNib:[UINib nibWithNibName:@"MTPAttendeeListCell" bundle:nil] forCellWithReuseIdentifier:@"MTPAttendeeListCell"];
    
    dispatch_async(dispatch_get_main_queue(), ^{
                [self.sectionSelectionCollectionView reloadData];
                [self.attendeeListCollectionView reloadData];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
}

- (void)loadData:(NSArray *)attendeeData
{
    __block NSArray *data = nil;
    NSFetchRequest *allUsersRequest = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    __block NSError *fetchError = nil;
    [self.navigationRouter.rootObjectContext performBlockAndWait:^{
        data = [self.navigationRouter.rootObjectContext executeFetchRequest:allUsersRequest error:&fetchError];
        if (fetchError)
        {
            DLog(@"\nfetch %@",fetchError);
        }
    }];
    
    attendeeData = data;
    
    NSMutableDictionary *lastNameSections = [NSMutableDictionary new];
    [attendeeData enumerateObjectsUsingBlock:^(User *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.last_name.length > 1)
        {
            NSString *firstLetter = [obj.last_name substringToIndex:1];
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
    
    NSMutableDictionary *attendeeLetterSection = [NSMutableDictionary new];
    for (NSString *letterSection in sortedKeys)
    {
        NSArray *sectionAttendees = [lastNameSections[letterSection] sortedArrayUsingComparator:^NSComparisonResult(User * _Nonnull obj1, User * _Nonnull obj2) {
            return [obj1.last_name compare:obj2.last_name options:NSCaseInsensitiveSearch];
        }];
        if (sectionAttendees.count)
        {
            [attendeeLetterSection setObject:sectionAttendees forKey:letterSection];
        }
    }
    self.attendeesBySection = [NSDictionary dictionaryWithDictionary:attendeeLetterSection];
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
    
    NSArray *sectionAttendees = self.attendeesBySection[self.sectionKeys[section]];
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
        return cell;
    }
    else
    {
        MTPAttendeeListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MTPAttendeeListCell" forIndexPath:indexPath];
        NSString *section = self.sectionKeys[indexPath.section];
        NSArray *sectionAttendees = self.attendeesBySection[section];
        NSInteger indexRow = indexPath.row;

        User *attendee = sectionAttendees[indexRow];
        cell.initialsLabel.text = [NSString stringWithFormat:@"%c%c",[attendee.first_name characterAtIndex:0],[attendee.last_name characterAtIndex:0]];
        cell.nameLabel.text = [NSString stringWithFormat:@"%@, %@",attendee.last_name,attendee.first_name];
        cell.detailLabel.text = [NSString stringWithFormat:@"%@",attendee.company];
        
        return cell;
    }
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
            height = 60;
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
        [self.attendeeListCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.row] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.attendeeListCollectionView)
    {
        if (self.sectionInitiatedScroll == NO)
        {
            NSArray *visibleCells = [[self.attendeeListCollectionView indexPathsForVisibleItems] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
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
