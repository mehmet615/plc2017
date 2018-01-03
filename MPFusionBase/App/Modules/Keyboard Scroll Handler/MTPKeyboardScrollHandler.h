//
//  MTPKeyboardScrollHandler.h
//  EXPERIENCE16
//
//  Created by Michael Thongvanh on 4/15/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTPKeyboardScrollHandler : NSObject

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *lowestView;
@property (strong, nonatomic) UIView *containerView;

- (instancetype)initWithScrollView:(UIScrollView *)scrollView lowestView:(UIView *)lowestView containerView:(UIView *)containerView;

@end
