//
//  MTPQuickLinkCoordinator.m
//  MPFusionBaseProject
//
//  Created by MeetingPlay on 2/1/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import "MTPQuickLinkCoordinator.h"
#import "MAMQuickLinkCollectionCell.h"
#import "MTPMenuItem.h"

#import "MAMStoryboardIdentifiers.h"
#import "MTPAppSettingsKeys.h"
#import "CHAFontAwesome.h"
#import "UIImageView+WebCache.h"
#import "UIColor+AppColors.h"
#import "MTPDLogDefine.h"

@interface MTPQuickLinkCoordinator ()
@property (nonatomic, strong) NSNumber *customCellWidth;
@property (strong, nonatomic) UICollectionViewFlowLayout *listLayout;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *circleLayout;
@property (strong, nonatomic) MTPListLayoutDelegateHandler *listLayoutHandler;
@end

@implementation MTPQuickLinkCoordinator

- (void)setupCollectionView:(UICollectionView *)collectionView inView:(UIView *)parentView
{
    self.quickLinksCollectionView = collectionView;
    
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.backgroundColor = [UIColor clearColor];
    
    if (self.listLayout == nil)
    {
        self.listLayout = [[UICollectionViewFlowLayout alloc] init];
    }
    
    if (self.listLayoutHandler == nil)
    {
        self.listLayoutHandler = [MTPListLayoutDelegateHandler new];
    }
}

- (void)loadQuickLinks:(NSArray *)quickLinks
{
    self.quickLinks = quickLinks;
    self.listLayoutHandler.quickLinksData = self.quickLinks;
    
    [self.quickLinksCollectionView reloadData];
}

- (void)configureQuickLinksAppearance
{
    switch (self.appearanceManager.displayStyle)
    {
        case MTPHomePageDisplayList:
        {
            self.quickLinksCollectionView.collectionViewLayout = self.listLayout;
            break;
        }
        case MTPHomePageDisplayCircle:
        {
            self.quickLinksCollectionView.collectionViewLayout = self.circleLayout;
            break;
        }
        case MTPHomePageDisplaySquare:
        {
            self.quickLinksCollectionView.collectionViewLayout = self.circleLayout;
            break;
        }
        default:
            break;
    }
}

#pragma mark - Protocol Conformance
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.quickLinks.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = MAMQuickLinkCell;
    if (collectionView.collectionViewLayout == self.listLayout) {
        cellIdentifier = @"MAMQuickLinkListCell";
    }
    MAMQuickLinkCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.circleInset = (collectionView.collectionViewLayout == self.listLayout) ? 0 : 8;
    
    return [self configureCell:cell dataSource:self.quickLinks forIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:true];
    [self didSelectMenuItem:self.quickLinks[indexPath.row]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeZero;
    
    if (collectionViewLayout == self.listLayout)
    {
        cellSize = [self.listLayoutHandler collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    else
    {
        if (!self.customCellWidth)
        {
            CGFloat cellSpacing = 11 * 2;
            CGFloat sectionInsets = 11 * 2;
            
            CGFloat collectionViewWidth = CGRectGetWidth(collectionView.frame);
            
            CGFloat cellWidth = MIN((collectionViewWidth - cellSpacing - sectionInsets) / 3.f, 200);
            self.customCellWidth = @(cellWidth);
        }
        
        cellSize = CGSizeMake(self.customCellWidth.floatValue, self.customCellWidth.floatValue + (self.customCellWidth.floatValue * 0.5));
    }
    
    return cellSize;
}


#pragma mark - Helper Methods
- (MAMQuickLinkCollectionCell *)configureCell:(MAMQuickLinkCollectionCell *)cell dataSource:(NSArray *)dataSource forIndexPath:(NSIndexPath *)indexPath
{
    MTPMenuItem *menuItem = [dataSource objectAtIndex:indexPath.row];
    
    if (menuItem.icon.length)
    {
        __weak MAMQuickLinkCollectionCell *weakCell = cell;
        [cell.iconImage sd_setImageWithURL:[NSURL URLWithString:menuItem.icon] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (error)
            {
                weakCell.iconLabel.hidden = NO;
            }
            else
            {
                if (image)
                {
                    weakCell.iconLabel.hidden = YES;
                    // uncomment the line below to add a tint color:
                    //                    weakCell.iconImage.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                }
                else
                {
                    weakCell.iconLabel.hidden = NO;
                }
            }
        }];
    }
    else
    {
        cell.iconLabel.text = [CHAFontAwesome icon:menuItem.fontAwesome];
    }
    
    cell.quickLinkTitle.text = menuItem.title;
    
    cell.quickLinkTitle.textColor = self.appearanceManager.cellTextColor;
    cell.iconImage.tintColor = self.appearanceManager.cellImageTintColor;
    cell.iconLabel.textColor = self.appearanceManager.cellImageTintColor;
    cell.borderColor = self.appearanceManager.cellBorderColor;
    
    [cell setCircleColor:self.appearanceManager.cellBackgroundColor];
    
    return cell;
}

- (void)didSelectMenuItem:(MTPMenuItem *)selectedMenuItem
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(quickLinkCoordinator:didSelectMenuItem:)])
    {
        [self.delegate quickLinkCoordinator:self didSelectMenuItem:selectedMenuItem];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}
@end


@implementation MTPQuickLinksAppearanceManager

- (instancetype)initWithThemeOptions:(NSDictionary *)themeOptions
{
    if (self = [super init])
    {
        [self configureWithThemeOptions:themeOptions];
    }
    return self;
}

- (void)configureWithThemeOptions:(NSDictionary *)themeOptions
{
    _eventName = [themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventName];
    NSString *location = [themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventLocation];
    NSString *date = [themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventDate];
    _eventDetails = [NSString stringWithFormat:@"%@%@",
                     location.length ? location : @"",
                     date.length ? [NSString stringWithFormat:@" / %@",date] : @""];
    
    _bellyEventNameColor = [UIColor mtp_colorFromString:[themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color4]];
    _bellyEventDateColor = [UIColor mtp_colorFromString:[themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color4]];
    
    _cellBackgroundColor = [UIColor mtp_colorFromString:[themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color5]];
    _cellTextColor = [UIColor mtp_colorFromString:[themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color6]];
    _cellImageTintColor = [UIColor mtp_colorFromString:[themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color7]];
    _cellBorderColor = [UIColor mtp_colorFromString:[themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color5]];
    
    _backgroundImageRemote = [themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageBackgroundImage];
    _backgroundTextureRemote = [themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageBackgroundTexture];
    
    _featuredImageRemote = [themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageFeaturedImage];
    _bellyImageRemote = [themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageBellyImage];
    _bellyBackgroundColor = [UIColor mtp_colorFromString:[themeOptions[MPFUSION_colors] objectForKey:MPFUSION_color3]];
    _showBelly = [[themeOptions[MPFUSION_homePageAppearance] objectForKey:@"showBelly"] boolValue];
    
    _displayStyle = [MTPThemeOptionsManager displayStyleForKey:[themeOptions[MPFUSION_homePageAppearance] objectForKey:MPFUSION_homePageMenuDisplayStyle]];
}

@end


@implementation MTPListLayoutDelegateHandler

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeZero;
    
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]])
    {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
        CGFloat cellWidth = CGRectGetWidth(collectionView.frame) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - flowLayout.minimumLineSpacing;
        CGFloat cellHeight = 50;
        
        cellSize = CGSizeMake(cellWidth, cellHeight);
    }
    
    return cellSize;
}
@end