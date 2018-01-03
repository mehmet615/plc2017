//
//  MTPSessionDataViewController.m
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 5/17/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPSessionDataViewController.h"
#import "MTPSessionTableViewCell.h"
#import "MTPSession.h"
#import "UIColor+AppColors.h"
#import "MTPDLogDefine.h"

@interface MTPSessionDataViewController ()
@property (strong, nonatomic) NSArray *sortedDates;
@property (readwrite) NSDictionary *sessionsByDate;

@property (strong, nonatomic) NSDateFormatter *sectionDateFormatter;
@property (strong, nonatomic) NSDateFormatter *startEndDateFormatter;

@property (strong, nonatomic) UIColor *ellipsisColor;
@property (strong, nonatomic) UIColor *ellipsisBorderColor;
@end

@implementation MTPSessionDataViewController

NSString *const MTPSessionTableViewCellIdentifier = @"MTPSessionTableViewCell";

- (instancetype)init
{
    if (self = [super init])
    {
        _sectionDateFormatter = [NSDateFormatter new];
        _sectionDateFormatter.dateStyle = NSDateFormatterLongStyle;
        _sectionDateFormatter.timeStyle = NSDateFormatterNoStyle;
        
        _startEndDateFormatter = [NSDateFormatter new];
        _startEndDateFormatter.dateStyle = NSDateFormatterNoStyle;
        _startEndDateFormatter.timeStyle = NSDateFormatterShortStyle;
    }
    
    return self;
}

- (void)prepareSessionDataTable:(UITableView *)tableView
{
    self.sessionDataTable = tableView;
    self.sessionDataTable.dataSource = self;
    self.sessionDataTable.delegate = self;
    
    self.sessionDataTable.estimatedRowHeight = 100;
    
    [self.sessionDataTable registerNib:[UINib nibWithNibName:NSStringFromClass([MTPSessionTableViewCell class]) bundle:nil]
                  forCellReuseIdentifier:MTPSessionTableViewCellIdentifier];
}

- (void)loadSessionData:(NSDictionary *)sessionData
{
    self.sessionsByDate = sessionData;
    
    NSArray *sortedDateKeys = [[sessionData allKeys] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2)
    {
        return [obj1 compare:obj2];
    }];
    
    self.sortedDates = [NSArray arrayWithArray:sortedDateKeys];
    
    [self.sessionDataTable reloadData];
}
#pragma mark - Table View Protocol Conformance
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sortedDates.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sessionForDate = self.sessionsByDate[self.sortedDates[section]];
    return sessionForDate.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTPSessionTableViewCell *cell = (MTPSessionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:MTPSessionTableViewCellIdentifier forIndexPath:indexPath];
    cell.layoutMargins = UIEdgeInsetsZero;
    NSDate *sessionDate = self.sortedDates[indexPath.section];
    MTPSession *session = [self.sessionsByDate[sessionDate] objectAtIndex:indexPath.row];
    [self configureTableView:tableView cell:cell session:session atIndexPath:indexPath];
    
    return cell;
}

- (void)configureTableView:(UITableView *)tableView cell:(MTPSessionTableViewCell *)cell session:(MTPSession *)session atIndexPath:(NSIndexPath *)indexPath
{
    cell.sessionTitleLabel.attributedText = session.attributedSessionTitle;
    
    if ([self.agendaAppearanceOptions[@"showTeaser"] boolValue] && session.attributedSessionTeaser.length)
    {
        cell.sessionTeaserHeight.constant = 150;
        cell.sessionTeaserLabel.attributedText = session.attributedSessionTeaser;
    }
    else
    {
        cell.sessionTeaserLabel.attributedText = nil;
        cell.sessionTeaserHeight.constant = 0;
    }
    
    if ([self.agendaAppearanceOptions[@"showLocation"] boolValue] && session.location.length)
    {
        cell.sessionLocationLabel.text = session.location;
        cell.sessionLocationContainerHeight.constant = 25;
    }
    else
    {
        cell.sessionLocationLabel.text = nil;
        cell.sessionLocationContainerHeight.constant = 0;
    }
    
    if ([self.agendaAppearanceOptions[@"showTime"] boolValue] && session.start_time.length)
    {
        NSString *startTime = [self.startEndDateFormatter stringFromDate:[session dateFromString:session.start_time]];
        cell.timeLabel.text = startTime;
        
        NSString *endTime = [self.startEndDateFormatter stringFromDate:[session dateFromString:session.end_time]];
        endTime = endTime.length ? [NSString stringWithFormat:@" - %@",endTime] : @"";
        cell.sessionTimeLabel.text = [NSString stringWithFormat:@"%@%@",startTime,endTime];
    }
    else
    { 
        cell.sessionTimeContainerHeight.constant = 0;
    }
    
    if ([self.agendaAppearanceOptions[@"showTrack"] boolValue])
    {
        UIColor *colorForTrack = [UIColor mtp_colorFromString:[self.agendaAppearanceOptions[@"trackColors"] objectForKey:session.track]];
        cell.sessionTrackButton.backgroundColor = colorForTrack;
        [cell.sessionTrackButton setTitle:session.track forState:UIControlStateNormal];
        cell.sessionTrackContainerHeight.constant = 35.f;
    }
    else
    {
        cell.sessionTrackButton.hidden = YES;
        cell.sessionTrackContainerHeight.constant = 10;
    }
    
    if ([[self.agendaAppearanceOptions[@"ellipsisStyle"] objectForKey:@"fillColor"] length])
    {
        cell.ellipsisLabel.backgroundColor = [UIColor mtp_colorFromString:[self.agendaAppearanceOptions[@"ellipsisStyle"] objectForKey:@"fillColor"]];
    }
    else
    {
        cell.ellipsisLabel.backgroundColor = [UIColor lightGrayColor];
    }
    
    if ([self.agendaAppearanceOptions[@"showEllipse"] boolValue])
    {
        cell.sessionEllipsisLabel.constant = 40.0;
    }
    else
    {
        cell.sessionEllipsisLabel.constant = 0.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MTPSession *session = [self.sessionsByDate[self.sortedDates[indexPath.section]] objectAtIndex:indexPath.row];
    [self selectedSession:session];
}

- (void)selectedSession:(MTPSession *)session
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sessionDataController:didSelectionSession:)])
    {
        [self.delegate sessionDataController:self didSelectionSession:session];
    }
    else
    {
        DLog(@"delegate check failed %@",self.delegate);
    }
}

/*
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[MTPSessionTableViewCell class]])
    {
        NSArray *sessions = self.sessionsByDate[self.sortedDates[indexPath.section]];
        // check the previous session, if the start time is the same then dont display the time label
        if (indexPath.row - 1 > 0)
        {
            MTPSession *displayedSession = sessions[indexPath.row-1];
            NSString *startTime = [self.startEndDateFormatter stringFromDate:[displayedSession dateFromString:displayedSession.start_time]];
            MTPSession *nextSession = sessions[indexPath.row];
            NSString *nextSessionStart = [self.startEndDateFormatter stringFromDate:[nextSession dateFromString:nextSession.start_time]];
            
            [[(MTPSessionTableViewCell *)cell timeLabelHeight] setConstant:[startTime isEqualToString:nextSessionStart] ? 0 : 30];
        }
    }
}
*/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark Section Header
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *labelContainer = [UIView new];
    labelContainer.backgroundColor = [UIColor mtp_colorFromString:self.agendaAppearanceOptions[@"sectionBackgroundColor"]];
    
    UILabel *sectionLabelName = [UILabel new];
    sectionLabelName.translatesAutoresizingMaskIntoConstraints = NO;
    sectionLabelName.textColor = [UIColor whiteColor];
    sectionLabelName.font = [UIFont fontWithName:@"Lato-Light" size:20.f];
    NSDate *sectionDate = self.sortedDates[section];
    sectionLabelName.text = [self.sectionDateFormatter stringFromDate:sectionDate];
    
    [labelContainer addSubview:sectionLabelName];
    [labelContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sectionLabelName]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(sectionLabelName)]];
    [labelContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[sectionLabelName]-margin-|" options:0 metrics:@{@"margin":@10} views:NSDictionaryOfVariableBindings(sectionLabelName)]];
    
    return labelContainer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}



@end
