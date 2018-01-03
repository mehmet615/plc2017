//
//  MTPAgendaViewController.h
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 5/16/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPNavigationItemCustomizable.h"
#import "MTPMainMenuTogglable.h"

@class MTPNavigationRouter, MTPSessionManager, User, MTPThemeOptionsManager;

@interface MTPAgendaViewController : UIViewController <MTPNavigationItemCustomizable>

@property (nonatomic, weak) MTPNavigationRouter *navigationRouter;
@property (weak, nonatomic) MTPThemeOptionsManager *themeOptionsManager;
@property (weak, nonatomic) MTPSessionManager *sessionManager;
@property (weak, nonatomic) User *currentUser;

@property (weak, nonatomic) id <MTPMainMenuTogglable> menuToggler;

@property (nonatomic, strong) UIBarButtonItem *customLeftBarItem;
- (void)setupLeftBarButton;

@end

#pragma mark - MTPSessionPickerPresenter
@interface MTPSessionPickerPresenter : NSObject

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (weak, nonatomic) IBOutlet UILabel *datesLabel;
@property (weak, nonatomic) IBOutlet UIButton *dateSelectorButton;
@property (weak, nonatomic) IBOutlet UIView *dateSelectionContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateSelectorHeight;
@property (weak, nonatomic) IBOutlet UIPickerView *datePicker;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *datePickerHeight;

@property (weak, nonatomic) IBOutlet UICollectionView *sessionDateCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *tracksLabel;
@property (weak, nonatomic) IBOutlet UIButton *trackSelectorButton;
@property (weak, nonatomic) IBOutlet UIView *trackSelectionContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trackSelectorHeight;
@property (weak, nonatomic) IBOutlet UIPickerView *trackPicker;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trackPickerHeight;

- (void)setupPickerWithDelegate:(id<UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate>)pickerDelegate;
- (void)toggleDateContainer:(NSArray *)dates trackContainer:(NSArray *)tracks;
- (void)displayHorizontalSelector:(id<UICollectionViewDataSource,UICollectionViewDelegate>)delegate;
- (void)togglePickerVisibilityView:(UIView *)containerView sender:(id)sender;
- (void)animatePickerHeight:(NSLayoutConstraint *)heightConstraint containerView:(UIView *)layoutView;
- (void)updateDate:(NSDate *)date;
- (void)updateTrack:(NSString *)track;
@end


#pragma mark - MTPSessionPickerDataController

@class MTPSessionPickerDataController;
@protocol MTPSessionPickerDelegate <NSObject>
- (void)sessionPicker:(MTPSessionPickerDataController *)sessionPicker pickerView:(id)pickerView didSelectDate:(NSDate *)date;
- (void)sessionPicker:(MTPSessionPickerDataController *)sessionPicker pickerView:(id)pickerView didSelectTrack:(NSString *)track;
@end

@interface MTPSessionPickerDataController : NSObject <UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) id <MTPSessionPickerDelegate> delegate;
@property (weak, nonatomic) MTPSessionPickerPresenter *sessionPickerPresenter;
@property (weak, nonatomic) MTPSessionManager *sessionManager;
@property (weak, nonatomic) NSDictionary *themeOptions;
@property (strong, nonatomic) NSCalendar *calendar;
@end