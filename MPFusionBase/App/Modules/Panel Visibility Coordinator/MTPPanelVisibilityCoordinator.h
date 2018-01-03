//
//  MTPPanelVisibilityCoordinator.h
//  PEAK16
//
//  Created by Michael Thongvanh on 4/21/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPPanelVisibilityCoordinator;

@protocol MTPPanelVisibilityDelegate <NSObject>
- (void)panelCoordinator:(MTPPanelVisibilityCoordinator *)panelCoordinator didFinishAnimation:(NSLayoutConstraint *)locationLeadingConstraint;
@end

@interface MTPPanelVisibilityCoordinator : NSObject

@property (weak, nonatomic) id <MTPPanelVisibilityDelegate> delegate;

@property (strong, nonatomic, readonly) UIPanGestureRecognizer *panGesture;
@property (strong, nonatomic, readonly) NSLayoutConstraint *positionConstraint;

- (void)addPan:(UIView *)panView constraint:(NSLayoutConstraint *)positionConstraint visibleWidth:(CGFloat)visibileWidth;

@end
