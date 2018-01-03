//
//  MTPLanguageSelectionViewController.h
//  PTC16
//
//  Created by Michael Thongvanh on 2/29/16.
//  Copyright (c) 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPLanguageSelectionViewController;

@protocol MTPLanguageSelectionDelegate <NSObject>
- (void)languageSelector:(MTPLanguageSelectionViewController *)languageSelector didSelectLanguage:(NSDictionary *)languageData;
@end

@interface MTPLanguageSelectionViewController : UIViewController

@property (weak, nonatomic) IBOutlet id <MTPLanguageSelectionDelegate> languageSelectionDelegate;

@end
