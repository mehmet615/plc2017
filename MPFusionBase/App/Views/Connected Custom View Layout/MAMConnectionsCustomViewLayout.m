//
//  MAMConnectionsCustomViewLayout.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/16/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMConnectionsCustomViewLayout.h"

@interface MAMConnectionsCustomViewLayout ()
@property (nonatomic, strong) NSArray *cellBasePositions;
@property (nonatomic, assign) CGSize largeCellSize;
@property (nonatomic, assign) CGSize smallCellSize;
@property (nonatomic, strong) NSArray *customLayoutAttributes;
@property (nonatomic, assign) CGRect previousLayoutFrame;
@end

@implementation MAMConnectionsCustomViewLayout

const NSInteger CELLS_PER_ROW = 5;
const CGFloat CELL_ROW_MARGIN = 5;
const CGFloat CELL_SPACING_MARGIN = 5;

- (void)prepareLayout
{
    [super prepareLayout];
    if (!self.customLayoutAttributes)
    {
        self.customLayoutAttributes = [NSArray new];
    }
    
    self.cellBasePositions = [self calculateCellDimensionsForContainer:self.collectionView.frame.size.width];
    
    NSInteger totalItems = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger counter = 0; counter < totalItems; counter++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:counter inSection:0];
        UICollectionViewLayoutAttributes *attributeItems = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        attributeItems.frame = [self calculateCellLocationForIndexPath:indexPath];
        attributeItems.center = CGPointMake(CGRectGetMidX(attributeItems.frame),CGRectGetMidY(attributeItems.frame));
        attributeItems.size = attributeItems.frame.size;
        self.customLayoutAttributes = [self.customLayoutAttributes arrayByAddingObject:attributeItems];
    }
}

- (CGSize)collectionViewContentSize
{
    NSInteger itemsCount = [self.collectionView.dataSource collectionView:self.collectionView numberOfItemsInSection:0];
    NSInteger rowsForLayout = floor(itemsCount / CELLS_PER_ROW);
    
    CGSize contentSize = CGSizeMake(self.collectionView.bounds.size.width,
                                    rowsForLayout * self.largeCellSize.height);
    return contentSize;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect // return an array layout attributes instances for all the views in the given rect
{
    NSMutableArray *layoutAttributesForRect = [NSMutableArray new];
    for (UICollectionViewLayoutAttributes *layoutAttributes in self.customLayoutAttributes)
    {
        if (CGRectContainsPoint(rect, layoutAttributes.frame.origin))
        {
            [layoutAttributesForRect addObject:layoutAttributes];
        }
    }
    return layoutAttributesForRect;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.customLayoutAttributes[indexPath.item];
}


- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGRect oldBounds = self.collectionView.bounds;
    if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds))
    {
        return true;
    }
    return false;
}

#pragma mark - Helpers
- (NSArray *)calculateCellDimensionsForContainer:(CGFloat)containerWidth
{
    CGFloat widthSpacingMarginTotal = ceil(2.f * CELL_SPACING_MARGIN);
    CGFloat widthMinusMargins = containerWidth - widthSpacingMarginTotal;
    
    CGFloat largeCellWidth = widthMinusMargins * 0.5f;
    CGFloat largeCellHeight = largeCellWidth + (largeCellWidth * 0.66);
    
    CGFloat smallCellWidth = (widthMinusMargins - largeCellWidth) / 2.f;
    CGFloat smallCellHeight = (largeCellHeight - CELL_SPACING_MARGIN) / 2.f;
    
    
    CGFloat largeWidthOffset = largeCellWidth + CELL_SPACING_MARGIN;
    CGFloat smallWidthOffset = smallCellWidth + CELL_SPACING_MARGIN;
    
    CGFloat smallHeightOffset = smallCellHeight + CELL_SPACING_MARGIN;
    
    self.smallCellSize = CGSizeMake(smallCellWidth, smallCellHeight);
    self.largeCellSize = CGSizeMake(largeCellWidth, largeCellHeight);
    
    return @[[NSValue valueWithCGPoint:CGPointZero],
             [NSValue valueWithCGPoint:CGPointMake(largeWidthOffset, 0)],
             [NSValue valueWithCGPoint:CGPointMake(largeWidthOffset+smallWidthOffset, 0)],
             [NSValue valueWithCGPoint:CGPointMake(largeWidthOffset, smallHeightOffset)],
             [NSValue valueWithCGPoint:CGPointMake(largeWidthOffset+smallWidthOffset, smallHeightOffset)],
             [NSValue valueWithCGPoint:CGPointZero],
             [NSValue valueWithCGPoint:CGPointMake(smallWidthOffset, 0)],
             [NSValue valueWithCGPoint:CGPointMake(2.f*smallWidthOffset, 0)],
             [NSValue valueWithCGPoint:CGPointMake(0, smallHeightOffset)],
             [NSValue valueWithCGPoint:CGPointMake(smallWidthOffset, smallHeightOffset)]];
}

- (CGRect)calculateCellLocationForIndexPath:(NSIndexPath *)indexPath
{
     NSInteger rowNumber = floor(indexPath.row / CELLS_PER_ROW);
     
     NSValue *cgPointValue = self.cellBasePositions[indexPath.item % 10];
     if (![cgPointValue isKindOfClass:[NSValue class]])
     {
     return CGRectZero;
     }
     
     CGPoint basePosition = [cgPointValue CGPointValue];
     CGFloat verticalOffset = rowNumber * (self.largeCellSize.height + CELL_ROW_MARGIN);
     
     CGSize cellSizeForRow;
     if (indexPath.row % 10 == 0 || indexPath.row % 10 == 7)
     {
         cellSizeForRow = self.largeCellSize;
     }
     else
     {
         cellSizeForRow = self.smallCellSize;
     }
    
     CGRect cellLocation = CGRectMake(basePosition.x, basePosition.y + verticalOffset, cellSizeForRow.width, cellSizeForRow.height);
     return cellLocation;
}

@end
