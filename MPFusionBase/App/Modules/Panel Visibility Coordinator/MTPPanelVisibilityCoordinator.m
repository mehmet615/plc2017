//
//  MTPPanelVisibilityCoordinator.m
//  PEAK16
//
//  Created by Michael Thongvanh on 4/21/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPPanelVisibilityCoordinator.h"
#import "MTPDLogDefine.h"

@interface MTPPanelVisibilityCoordinator ()
@property (strong, nonatomic, readwrite) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic, readwrite) NSLayoutConstraint *positionConstraint;

@property (assign, nonatomic) CGFloat startingPoint;
@property (assign, nonatomic) CGFloat visibileWidth;
@end

@implementation MTPPanelVisibilityCoordinator

- (instancetype)init
{
    if (self = [super init]) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    }
    return self;
}

- (void)addPan:(UIView *)panView constraint:(NSLayoutConstraint *)positionConstraint visibleWidth:(CGFloat)visibileWidth
{
    if (panView == nil) {
        return;
    }
    
    self.visibileWidth = visibileWidth;
    
    [panView addGestureRecognizer:self.panGesture];
    self.positionConstraint = positionConstraint;
}

- (void)didPan:(UIPanGestureRecognizer *)panGesture
{
    if (self.positionConstraint.constant != 0)
    {
        [self adjustConstraint:self.positionConstraint withPan:panGesture];
    }
    else
    {
        // both menus are closed
    }
}

- (void)adjustConstraint:(NSLayoutConstraint *)positionConstraint withPan:(UIPanGestureRecognizer *)panGesture
{
    CGFloat visibleArea = self.visibileWidth * CGRectGetWidth(panGesture.view.frame);
    
    CGFloat minimumPosition = -visibleArea;
    CGFloat maximumPosition = visibleArea;
    
    switch (panGesture.state)
    {
        case UIGestureRecognizerStateBegan:
        {
            self.startingPoint = self.positionConstraint.constant;
            break;
        }
        case UIGestureRecognizerStateEnded:
        {
            [self animateView:panGesture.view panelVisibility:self.positionConstraint minimum:minimumPosition maximum:maximumPosition];
            break;
        }
        default:
        {
            if (self.startingPoint > 0 && self.positionConstraint.constant < 0)
            {
                self.positionConstraint.constant = 0;
            }
            else if (self.startingPoint < 0 && self.positionConstraint.constant > 0)
            {
                self.positionConstraint.constant = 0;
            }
            else
            {
                CGFloat targetPoint = self.startingPoint + [panGesture translationInView:panGesture.view].x;

                if (targetPoint > minimumPosition && targetPoint < maximumPosition)
                {
                    self.positionConstraint.constant = targetPoint;
                }
            }

            break;
        }
    }
}

- (void)animateView:(UIView *)panView panelVisibility:(NSLayoutConstraint *)positionConstraint minimum:(CGFloat)minimumPosition maximum:(CGFloat)maximumPosition
{
    CGFloat finalTarget = 0;
    
    CGFloat endingPosition = positionConstraint.constant;
    if (endingPosition < 0)
    {
        // slid left
        if (endingPosition < (minimumPosition * 0.7))
        {
            finalTarget = minimumPosition;
        }
        else
        {
            finalTarget = 0;
        }
    }
    else
    {
        // panning right
        if (endingPosition > (maximumPosition * 0.7))
        {
            finalTarget = maximumPosition;
        }
        else
        {
            finalTarget = 0;
        }
    }
    
    __weak typeof(&*self)weakSelf = self;
    
    positionConstraint.constant = finalTarget;
    
    [UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [panView layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(panelCoordinator:didFinishAnimation:)])
        {
            [weakSelf.delegate panelCoordinator:weakSelf didFinishAnimation:positionConstraint];
        }
        else
        {
            DLog(@"delegate check failed %@",weakSelf.delegate);
        }
    }];
}

@end
