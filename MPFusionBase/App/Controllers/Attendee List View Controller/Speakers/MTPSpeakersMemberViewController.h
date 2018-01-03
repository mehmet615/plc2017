//
//  MTPSpeakersMemberViewController.h
//  MPFusionBaseProject
//
//  Created by Admin on 8/18/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

#import "MTPSpeaker.h"

typedef NS_ENUM(NSInteger, MTPSpeakerMemberPageType) {
    MTPSpeakerMemberPageTypeAbout = 0,
    MTPSpeakerMemberPageTypeSpeakingAt = 1
};

@class MTPNavigationRouter, MTPSessionManager, User, MTPThemeOptionsManager;

@interface MTPSpeakersMemberViewController : UIViewController <MTPNavigationItemCustomizable>

@property (weak, nonatomic) IBOutlet UIView *speakerListHeaderContainer;

@property (weak, nonatomic) IBOutlet UILabel *speakerHeaderLabel;
@property (weak, nonatomic) IBOutlet UILabel *speakerLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *sessionTitleView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *aboutButton;
@property (weak, nonatomic) IBOutlet UIButton *speakingAtButton;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@property (retain, nonatomic) UIColor *selectedColor;
@property (retain, nonatomic) UIColor *selectedTextColor;
@property (retain, nonatomic) UIColor *unSelectedColor;
@property (retain, nonatomic) UIColor *unSelectedTextColor;

@property (nonatomic) BOOL isAbout;
@property (nonatomic, strong) MTPSpeaker *speaker;


@property (nonatomic, weak) MTPNavigationRouter *navigationRouter;
@property (retain, nonatomic) MTPThemeOptionsManager *themeOptionsManager;
@property (retain, nonatomic) MTPSessionManager *sessionManager;
@property (retain, nonatomic) User *currentUser;

@property (retain, nonatomic) id <MTPMainMenuTogglable> menuToggler;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;

@end
