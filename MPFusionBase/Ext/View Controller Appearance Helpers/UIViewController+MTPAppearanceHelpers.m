//
//  UIViewController+MTPAppearanceHelpers.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/9/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "UIViewController+MTPAppearanceHelpers.h"

@implementation UIViewController (MTPAppearanceHelpers)

- (void)addTexture:(UIImage *)texture targetView:(UIView *)texturedView
{
    NSParameterAssert(texture != nil);
    NSParameterAssert(texturedView != nil);
    
    [texturedView setBackgroundColor:[UIColor colorWithPatternImage:texture]];
}

@end
