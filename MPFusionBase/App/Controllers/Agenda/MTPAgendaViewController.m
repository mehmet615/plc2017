//
//  MTPAgendaViewController.m
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 5/16/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPAgendaViewController.h"
#import "MTPSessionDataViewController.h"
#import "MTPNavigationRouter.h"
#import "MTPSessionManager.h"
#import "MTPSession.h"
#import "User.h"
#import "MTPThemeOptionsManager.h"
#import "UIViewController+NavigationItemSetup.h"
#import "MTPDLogDefine.h"
#import "MTPSessionDataSelectionCell.h"
#import "UIColor+AppColors.h"
#import "MAMWebViewController.h"
#import "NSString+MTPWebViewURL.h"
#import "UIButton+MTPNavigationBar.h"

@interface MTPAgendaViewController () <MTPSessionPickerDelegate,MTPSessionDataDelegate>

@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSString *selectedTrack;

@property (weak, nonatomic) IBOutlet UIView *dropdownParent;

@property (weak, nonatomic) IBOutlet UIView *agendaListContainer;
@property (weak, nonatomic) IBOutlet UITableView *sessionDataTable;

@property (strong, nonatomic) NSDictionary *agendaData;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@property (strong, nonatomic) IBOutlet MTPSessionPickerPresenter *sessionPickerPresenter;
@property (strong, nonatomic) MTPSessionPickerDataController *sessionPickerController;
@property (strong, nonatomic) IBOutlet MTPSessionDataViewController *sessionDataViewController;
@end

@implementation MTPAgendaViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterLongStyle;
    self.dateFormatter.timeStyle = NSDateFormatterNoStyle;

    [self setupViews];
    
    self.agendaData = [MTPSessionManager sortSessions:self.sessionManager.sessionCollection];
    [self.sessionDataViewController prepareSessionDataTable:self.sessionDataTable];
    self.sessionDataViewController.agendaAppearanceOptions = self.navigationRouter.themeOptionsManager.themeOptions[@"agenda"];
    [self.sessionDataViewController loadSessionData:self.agendaData];
    self.sessionDataViewController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupViews
{
    self.sessionPickerController = [MTPSessionPickerDataController new];
    self.sessionPickerController.sessionPickerPresenter = self.sessionPickerPresenter;
    self.sessionPickerController.sessionManager = self.sessionManager;
    self.sessionPickerController.delegate = self;
    self.sessionPickerController.themeOptions = self.themeOptionsManager.themeOptions;
    
    [self.sessionPickerPresenter toggleDateContainer:self.sessionManager.dates trackContainer:self.sessionManager.tracks];
    if ([[self.themeOptionsManager.themeOptions[@"agenda"] objectForKey:@"dropdownDisplay"] boolValue] == NO)
    {
        [self.sessionPickerPresenter displayHorizontalSelector:self.sessionPickerController];
    }
    if ([[self.themeOptionsManager.themeOptions[@"agenda"] objectForKey:@"showTrackSelection"] boolValue] == NO)
    {
        self.sessionPickerPresenter.trackSelectorHeight.constant = 0;
    }
    [self.sessionPickerPresenter setupPickerWithDelegate:self.sessionPickerController];
    
    UITapGestureRecognizer *dateTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.sessionPickerPresenter.dateSelectionContainer addGestureRecognizer:dateTap];
    UITapGestureRecognizer *trackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self.sessionPickerPresenter.trackSelectionContainer addGestureRecognizer:trackTap];
    
    self.sessionPickerPresenter.dateFormatter = self.dateFormatter;
    self.sessionPickerController.dateFormatter = self.dateFormatter;
    
    [self.view bringSubviewToFront:self.dropdownParent];
    
    for (UIView *containerView in @[self.sessionPickerPresenter.datesLabel.superview,self.sessionPickerPresenter.tracksLabel.superview])
    {
        containerView.layer.borderWidth = 0.5;
        containerView.layer.borderColor = [UIColor colorWithWhite:0.3 alpha:0.5].CGColor;
        containerView.layer.cornerRadius = 3.f;
        containerView.layer.masksToBounds = YES;
    }
}

- (IBAction)showSelector:(id)sender
{
    [self.sessionPickerPresenter togglePickerVisibilityView:self.view sender:sender];
}

- (void)didTap:(UITapGestureRecognizer *)tapGesture
{
    id sender;
    
    if (tapGesture.view == self.sessionPickerPresenter.dateSelectionContainer)
    {
        sender = self.sessionPickerPresenter.dateSelectorButton;
    }
    else if (tapGesture.view == self.sessionPickerPresenter.trackSelectionContainer)
    {
        sender = self.sessionPickerPresenter.trackSelectorButton;
    }
    
    if (sender)
    {
        [self.sessionPickerPresenter togglePickerVisibilityView:self.view sender:sender];
    }
}

#pragma mark - Protocol Conformance
- (void)sessionPicker:(MTPSessionPickerDataController *)sessionPicker pickerView:(id)pickerView didSelectDate:(NSDate *)date
{
    self.selectedDate = date;
    
    if (pickerView == self.sessionPickerPresenter.datePicker)
    {
        [self.sessionPickerPresenter updateDate:date];
        [self.sessionPickerPresenter togglePickerVisibilityView:self.view sender:pickerView];
    }
    [self updateDate:self.selectedDate andTrack:self.selectedTrack];
}

- (void)sessionPicker:(MTPSessionPickerDataController *)sessionPicker pickerView:(id)pickerView didSelectTrack:(NSString *)track
{
    if (pickerView == self.sessionPickerPresenter.trackPicker)
    {
        self.selectedTrack = track;
        [self.sessionPickerPresenter updateTrack:track];
        [self updateDate:self.selectedDate andTrack:self.selectedTrack];
        
        [self.sessionPickerPresenter togglePickerVisibilityView:self.view sender:pickerView];
    }
}

- (void)updateDate:(NSDate *)date andTrack:(NSString *)track
{
    NSDictionary *agenda = [self.sessionManager sortAgendaWithDate:date track:track];
    self.agendaData = agenda;
    [self.sessionDataViewController loadSessionData:self.agendaData];
}

- (void)sessionDataController:(MTPSessionDataViewController *)dataController didSelectionSession:(MTPSession *)session
{
#warning NEED TO UPDATE TO SUPPORT WKWEBVIEW
    MAMWebViewController *sessionDetails = [[MAMWebViewController alloc] initWithNibName:NSStringFromClass([MAMWebViewController class]) bundle:nil];
    sessionDetails.customURL = [NSString stringWithFormat:[NSString sessionDetailsURL],session.schedule_id];
    sessionDetails.currentUser = self.currentUser;
    
    sessionDetails.themeOptionsManager = self.themeOptionsManager;
    sessionDetails.navigationRouter = self.navigationRouter;
    
    UIBarButtonItem *customBackButton = [UIButton refreshMenuButton:@{@"imageName": @"backIcon"}
                                                             target:sessionDetails
                                                           selector:@selector(returnPrevious:)];
    [customBackButton setTarget:sessionDetails];
    [customBackButton setAction:@selector(returnPrevious:)];
    
    [sessionDetails setCustomLeftBarItem:customBackButton];
    
    [self.navigationController pushViewController:sessionDetails animated:YES];
}

- (void)toggleMenu:(id)sender
{
    if (self.menuToggler && [self.menuToggler respondsToSelector:@selector(topViewControllerShouldToggleMenu:)])
    {
        [self.menuToggler topViewControllerShouldToggleMenu:nil];
    }
    else
    {
        DLog(@"no delegate found");
    }
}

@end









#pragma mark - MTPSessionPickerPresenter
@implementation MTPSessionPickerPresenter

-(void)setupPickerWithDelegate:(id<UIPickerViewDelegate,UIPickerViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>)pickerDelegate
{
    if (self.datePicker == nil || self.trackPicker == nil)
    {
        DLog(@"\ndebugging message %@\n%@",self.datePicker,self.trackPicker);
        return;
    }
    
    for (UIPickerView *pickerView in @[self.datePicker,self.trackPicker])
    {
        pickerView.dataSource = pickerDelegate;
        pickerView.delegate = pickerDelegate;
        [pickerView reloadAllComponents];
    }
}

- (void)toggleDateContainer:(NSArray *)dates trackContainer:(NSArray *)tracks
{
    if (tracks.count < 2)
    {
        self.trackSelectorHeight.constant = 0;
    }
    
    if (dates.count < 2)
    {
        self.dateSelectorHeight.constant = 0;
    }
}

- (void)displayHorizontalSelector:(id<UICollectionViewDelegate,UICollectionViewDataSource>)delegate
{
    self.dateSelectorHeight.constant = 70;
    self.datesLabel.superview.hidden = YES;
    self.sessionDateCollectionView.hidden = NO;
    [self loadDateSelectionCollectionView:delegate];
}

- (void)loadDateSelectionCollectionView:(id<UICollectionViewDelegate,UICollectionViewDataSource>)delegate
{
    [self.sessionDateCollectionView registerNib:[UINib nibWithNibName:@"MTPSessionDataSelectionCell" bundle:nil] forCellWithReuseIdentifier:@"MTPSessionDataSelectionCell"];
    
    self.sessionDateCollectionView.dataSource = delegate;
    self.sessionDateCollectionView.delegate = delegate;
    
    [self.sessionDateCollectionView reloadData];
}

- (void)togglePickerVisibilityView:(UIView *)containerView sender:(id)sender
{
    NSLayoutConstraint *height;
    if (sender == self.dateSelectorButton || sender == self.datePicker)
    {
        height = self.datePickerHeight;
        self.trackPickerHeight.constant = 0;
    }
    else if (sender == self.trackSelectorButton || sender == self.trackPicker)
    {
        height = self.trackPickerHeight;
        self.datePickerHeight.constant = 0;
    }
    else
    {
        DLog(@"\ndebugging message %@",sender);
    }
    
    if (height)
    {
        [self animatePickerHeight:height containerView:containerView];
    }
}

- (void)animatePickerHeight:(NSLayoutConstraint *)heightConstraint containerView:(UIView *)layoutView
{
    heightConstraint.constant = heightConstraint.constant ? 0 : 220;
    [layoutView layoutIfNeeded];
    
    [UIView animateWithDuration:0.2 animations:^{
        [layoutView layoutIfNeeded];
    }];
}

- (void)updateDate:(NSDate *)date
{
    self.datesLabel.text = date ? [self.dateFormatter stringFromDate:date] : @"View All Dates";
}

- (void)updateTrack:(NSString *)track
{
    self.tracksLabel.text = track.length ? track : @"View All Tracks";
}
@end

#pragma mark - MTPSessionPickerDataController
@implementation MTPSessionPickerDataController
- (instancetype)init
{
    if (self = [super init])
    {
        _calendar = [NSCalendar currentCalendar];
    }
    return self;
}

#pragma mark UIPickerView Protocol
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView == self.sessionPickerPresenter.datePicker)
    {
        return self.sessionManager.dates.count + 1;
    }
    else if (pickerView == self.sessionPickerPresenter.trackPicker)
    {
        return self.sessionManager.tracks.count + 1;
    }
    else
    {
        return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == self.sessionPickerPresenter.datePicker)
    {
        return row == 0 ? @"View All Dates" : [self.dateFormatter stringFromDate:self.sessionManager.dates[row-1]];
    }
    else if (pickerView == self.sessionPickerPresenter.trackPicker)
    {
        return row == 0 ? @"View All Tracks" : self.sessionManager.tracks[row-1];
    }
    else
    {
        return @"";
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.sessionPickerPresenter.datePicker)
    {
        [self selectedDate:row == 0 ? nil : self.sessionManager.dates[row-1] pickerView:pickerView];
    }
    else
    {
        [self selectedTrack:row == 0 ? nil : self.sessionManager.tracks[row-1] pickerView:pickerView];
    }
}

- (void)selectedDate:(NSDate *)date pickerView:(id)pickerView
{    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sessionPicker:pickerView:didSelectDate:)])
    {
        [self.delegate sessionPicker:self pickerView:pickerView didSelectDate:date];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

- (void)selectedTrack:(NSString *)track pickerView:(id)pickerView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sessionPicker:pickerView:didSelectTrack:)])
    {
        [self.delegate sessionPicker:self pickerView:pickerView didSelectTrack:track];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}


#pragma mark UICollection View Protocol

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sessionManager.dates.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTPSessionDataSelectionCell *cell = (MTPSessionDataSelectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MTPSessionDataSelectionCell" forIndexPath:indexPath];
    
    NSDate *date = self.sessionManager.dates[indexPath.row];
    NSDateComponents *dateComponents = [self.calendar components:NSCalendarUnitDay|NSCalendarUnitWeekday fromDate:date];
    cell.dateNumberLabel.text = [NSString stringWithFormat:@"%@",@([dateComponents day])];
    cell.dateWeekdayLabel.text = [NSString stringWithFormat:@"%@",[[self.calendar shortWeekdaySymbols] objectAtIndex:([dateComponents weekday])]];
    
    UIColor *selectedColor = [UIColor mtp_colorFromString:[[self.themeOptions[@"agenda"] objectForKey:@"ellipsisStyle"] objectForKey:@"fillColor"]];
    cell.selectedColor = selectedColor;
    cell.dateWeekdayLabel.textColor = selectedColor;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = self.sessionManager.dates[indexPath.row];
    [self selectedDate:date pickerView:collectionView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize cellSize = CGSizeZero;
    if ([collectionViewLayout isKindOfClass:[UICollectionViewFlowLayout class]])
    {
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
        CGFloat height = CGRectGetHeight(collectionView.frame) - flowLayout.sectionInset.top - flowLayout.sectionInset.bottom;
        cellSize = CGSizeMake(height, height);
    }
    return cellSize;
}

@end