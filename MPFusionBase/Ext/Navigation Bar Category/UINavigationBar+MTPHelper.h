//
//  UINavigationBar+MTPHelper.h
//  PTC16
//
//  Created by Michael Thongvanh on 2/29/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (MTPHelper)
- (void)addBackgroundGradient:(NSString *)colorString;
- (UIImage *)backgroundImage:(NSString *)baseColorString;
@end
