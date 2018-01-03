//
//  MAMConnectionsViewController.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/13/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMConnectionsViewController.h"

#import "User+Helpers.h"
#import "MAMConnectionDetailsViewController.h"
#import "MDMyConnectionManager.h"
#import "MAMConnectionsCollectionViewCell.h"
#import "MTPSponsorManager.h"

#import "MAMStoryboardIdentifiers.h"
#import "UIView+AutoLayoutHelper.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+MTPNavigationBar.h"
#import "UIColor+AppColors.h"

#import "NSObject+EventDefaultsHelpers.h"
#import "MTPNavigationRouter.h"
#import "UIViewController+NavigationItemSetup.h"

@interface MAMConnectionsViewController () <MTPConnectionCompletionDelegate>

@property (nonatomic, strong) NSArray *connectionsDataSource;
@property (nonatomic, strong) UIView *separatorLine;
@property (nonatomic, strong) NSCache *imageCache;
@property (nonatomic, strong) NSNumber *currentlyLoggedInUserID;
@property (nonatomic, strong) UIView *noConnectionsView;
@end

@implementation MAMConnectionsViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dataSource = [self setupDataSource];
    
    self.imageCache = [[NSCache alloc] init];
    
    self.dataSource.cellIdentifier = MAMConnectionsCollectionViewCellIdentifier;
    self.collectionView.dataSource = self;
    self.connectionsDataSource = [NSArray new];
    
    self.mainTitleLabel.textColor = [UIColor whiteColor];
    self.mainTitleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:18.f];
    
    self.connectionDescriptionTextView.font = [UIFont fontWithName:@"Roboto-Italic" size:12.f];
    
    self.connectionDescriptionTextView.backgroundColor = [UIColor clearColor];
    self.connectionDescriptionTextView.textColor = [UIColor whiteColor];
    self.connectionDescriptionTextView.userInteractionEnabled = false;
    
    [self configureWithDataSource:self.configurationDataSource];
    [self setupNoUsersBox];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(performFetch) name:MTP_DidFetchAllUsersNotification object:nil];
    
    [self setupNavigationItem:NO];
    
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [[self navigationItem] setRightBarButtonItem:[UIButton refreshMenuButton:nil target:self selector:@selector(performFetch)]];
    
    if (self.currentUser)
    {
        self.currentlyLoggedInUserID = self.currentUser.user_id;
        [self configureWithDataSource:self.configurationDataSource];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!self.separatorLine)
    {
        self.separatorLine = [self addSeparatorLine:self.mainTitleLabel];
        [self.mainTitleLabel addSubview:self.separatorLine];
    }
}

#pragma mark - Protocol Conformance
#pragma mark - IBActions
#pragma mark - Helper Methods
- (void)toggleMenu:(id)sender
{
    if (self.menuToggleDelegate && [self.menuToggleDelegate respondsToSelector:@selector(topViewControllerShouldToggleMenu:)])
    {
        [self.menuToggleDelegate topViewControllerShouldToggleMenu:nil];
    }
    else
    {
        DLog(@"no delegate found");
    }
}

#pragma mark - Initial Setup
- (MTPDataSource *)setupDataSource
{
    MTPDataSource *dataSource = [MTPDataSource dataSourceRootObjectContext:self.rootObjectContext
                                                             beaconManager:self.beaconManager
                                                         connectionManager:self.connectionManager];
    return dataSource;
}

- (void)configureWithDataSource:(MTPViewControllerDataSource *)controllerDataSource
{
    self.mainTitleLabel.text = [controllerDataSource pageHeaderText].capitalizedString;
    
    NSString *pageSubtitleText = [controllerDataSource pageSubtitleDescriptionText];
    if (pageSubtitleText.length > 0)
    {
        NSMutableParagraphStyle *textStyle = [NSMutableParagraphStyle new];
        textStyle.lineHeightMultiple = 1.25f;
        textStyle.alignment = NSTextAlignmentCenter;
        
        [self.connectionDescriptionTextView setAttributedText:[[NSAttributedString alloc] initWithString:pageSubtitleText attributes:@{NSParagraphStyleAttributeName: textStyle,
                                                                                                                                       NSForegroundColorAttributeName: [UIColor whiteColor],
                                                                                                                                       NSFontAttributeName: [UIFont fontWithName:@"Roboto-Regular" size:11.f]}]];
    }
    
    self.headerBackground.image = [UIImage imageNamed:[controllerDataSource pageHeaderBackgroundImage]];
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:[controllerDataSource pageContentBackgroundImage]]];
    
    if (self.collectionView)
    {
        [self performFetch];
    }
}

- (void)setupNoUsersBox
{
    [self.view addSubview:self.noConnectionsView];
    
    [self.view addConstraints:@[[self.noConnectionsView equalWidth:0.75],
                                [self.noConnectionsView alignCenterHorizontalSuperview],
                                [self.noConnectionsView alignCenterVerticalSuperview]]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.noConnectionsView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:200]];
    [self.view setNeedsUpdateConstraints];
}

- (void)performFetch
{
    self.noConnectionsView.hidden = true;
    
    self.connectionsDataSource = [NSArray new];
    [self.collectionView reloadData];
    
    __weak __typeof(&*self)weakSelf = self;
    [self.dataSource dataForTypes:self.configurationDataSource.dataSourceType
                         typeData:nil
               shouldFetchFromAPI:false
                completionHandler:^(NSArray *dataForTypes)
     {
         weakSelf.connectionsDataSource = [weakSelf.connectionsDataSource arrayByAddingObjectsFromArray:dataForTypes];
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf.collectionView reloadData];
         });
         [weakSelf checkConnectionDisplayCount:weakSelf.connectionsDataSource.count];
     } failureHandler:^(NSError *loadingError) {
         DLog(@"\nfailed %@", loadingError);
         [weakSelf checkConnectionDisplayCount:weakSelf.connectionsDataSource.count];
     }];
}

- (void)didCompleteConnection:(id)connection atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        });
    }
}

- (void)checkConnectionDisplayCount:(NSInteger)connectionCount
{
    if (connectionCount == 0)
    {
        if (self.configurationDataSource.dataSourceType | MTPDisplayStyleUsersNearby)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.noConnectionsView.hidden = false;
            });
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.noConnectionsView.hidden = true;
        });
        DLog(@"\nusers found %@", @(connectionCount));
    }
}

- (UIView *)noConnectionsView
{
    if (_noConnectionsView)
    {
        return _noConnectionsView;
    }
    
    _noConnectionsView = [[UIView alloc] initWithFrame:CGRectZero];
    _noConnectionsView.translatesAutoresizingMaskIntoConstraints = false;
    _noConnectionsView.backgroundColor = [UIColor whiteColor];
    _noConnectionsView.layer.shadowColor = [UIColor blackColor].CGColor;
    _noConnectionsView.layer.shadowOpacity = 0.2f;
    _noConnectionsView.layer.shadowRadius = 5.f;
    _noConnectionsView.hidden = true;
    
    UILabel *noConnectionsTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noConnectionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false;
    noConnectionsTitleLabel.textAlignment = NSTextAlignmentCenter;
    noConnectionsTitleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:30.f];
    noConnectionsTitleLabel.textColor = [UIColor appTintColor];
    noConnectionsTitleLabel.text = @"Are You Hiding?";
    [_noConnectionsView addSubview:noConnectionsTitleLabel];
    
    UILabel *noConnectionsDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    noConnectionsDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false;
    noConnectionsDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    noConnectionsDescriptionLabel.numberOfLines = 5;
    noConnectionsDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    noConnectionsDescriptionLabel.font = [UIFont fontWithName:@"Roboto" size:17.f];
    noConnectionsDescriptionLabel.textColor = [UIColor appTintColor];
    noConnectionsDescriptionLabel.text = @"We didn't find anyone near you. Approach a beacon and try searching again.";
    [_noConnectionsView addSubview:noConnectionsDescriptionLabel];
    
    UIButton *noConnectionsSearchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    noConnectionsSearchButton.translatesAutoresizingMaskIntoConstraints = false;
    [noConnectionsSearchButton setBackgroundColor:[UIColor appTintColor]];
    [noConnectionsSearchButton.titleLabel setFont:[UIFont fontWithName:@"Roboto-Regular" size:23.f]];
    [noConnectionsSearchButton setTitle:@"Search Again" forState:UIControlStateNormal];
    [noConnectionsSearchButton addTarget:self action:@selector(performFetch) forControlEvents:UIControlEventTouchUpInside];
    [_noConnectionsView addSubview:noConnectionsSearchButton];
    
    [_noConnectionsView addConstraints:@[[noConnectionsTitleLabel pinSide:NSLayoutAttributeTop constant:10],
                                         [noConnectionsTitleLabel equalHeight:0.25]
                                         ]];
    [_noConnectionsView addConstraints:[noConnectionsTitleLabel pinLeadingTrailing]];
    
    [_noConnectionsView addConstraints:@[[noConnectionsSearchButton pinSide:NSLayoutAttributeBottom constant:-10],
                                         [NSLayoutConstraint constraintWithItem:noConnectionsSearchButton
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:50]
                                         ]];
    [_noConnectionsView addConstraints:@[[noConnectionsSearchButton equalWidth:0.9],
                                         [noConnectionsSearchButton alignCenterHorizontalSuperview]]];
    
    [_noConnectionsView addConstraints:@[[noConnectionsDescriptionLabel equalWidth:0.9],
                                        [noConnectionsDescriptionLabel alignCenterHorizontalSuperview]]];
    
    [_noConnectionsView addConstraints:@[[NSLayoutConstraint constraintWithItem:noConnectionsDescriptionLabel
                                                                      attribute:NSLayoutAttributeTop
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:noConnectionsTitleLabel
                                                                      attribute:NSLayoutAttributeBottom
                                                                     multiplier:1
                                                                       constant:0],
                                         [NSLayoutConstraint constraintWithItem:noConnectionsDescriptionLabel
                                                                      attribute:NSLayoutAttributeBottom
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:noConnectionsSearchButton
                                                                      attribute:NSLayoutAttributeTop
                                                                     multiplier:1
                                                                       constant:0]
                                         ]];
    return _noConnectionsView;
}

@end

#pragma mark - Collection View Categories

@implementation MAMConnectionsViewController (CollectionViewCategories)

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.connectionsDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MAMConnectionsCollectionViewCell *dequeuedConnectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:MAMConnectionsCollectionViewCellIdentifier forIndexPath:indexPath];
    return [self layoutCell:dequeuedConnectionCell collectionView:collectionView indexPath:indexPath data:self.connectionsDataSource];
}

- (UICollectionViewCell *)layoutCell:(MAMConnectionsCollectionViewCell *)cell
                      collectionView:(UICollectionView *)collectionView
                           indexPath:(NSIndexPath *)indexPath
                                data:(id)cellData
{
    User *user = [cellData objectAtIndex:indexPath.item];
    
    cell.connectionNameLabel.text = [NSString stringWithFormat:@"%@ %@",user.first_name,user.last_name];
    cell.connectionNameTitle.text = user.jobtitle;
    
    [cell configureStatusButton:[self.connectionManager checkMyConnectionFor:user.user_id]
                     shouldHide:[user.user_id isEqualToNumber:self.currentUser.user_id]
     ];
    
    NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[self.userDefaults objectForKey:kProfileImageUrl],user.photo]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [cell.connectionImageView setImageWithURL:profileURL placeholderImage:[UIImage imageNamed:@"no_photo"]];
    });
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.connectionsDataSource.count < indexPath.row)
    {
        return;
    }
    
    MAMConnectionDetailsViewController *connectionDetails = [[UIStoryboard storyboardWithName:@"ConnectionDetails" bundle:nil]
                                                             instantiateViewControllerWithIdentifier:MAMConnectionDetailsViewControllerIdentifier];
    
    connectionDetails.connectionManager = self.connectionManager;
    connectionDetails.sponsorManager = self.sponsorManager;
    
    [connectionDetails performManagerSetup:nil];
    [connectionDetails setLoggedInUserID:self.currentUser.user_id];
    [connectionDetails setConnectionIndexPath:indexPath];
    
    connectionDetails.connectionCompletionDelegate = self;
    
    id connection = [self.connectionsDataSource objectAtIndex:indexPath.row];
    if (connection)
    {
        [connectionDetails displayConnectionData:connection];
        [connectionDetails configureWithDataSource:nil];
        
        [self.navigationController pushViewController:connectionDetails animated:true];

    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellWidth = (collectionView.bounds.size.width / 2.f) - 20.f;
    CGFloat cellHeight = cellWidth * 1.5;
    
    return CGSizeMake(cellWidth, cellHeight);
}
















@end