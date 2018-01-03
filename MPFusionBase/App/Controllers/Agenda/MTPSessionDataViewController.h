//
//  MTPSessionDataViewController.h
//  MPFusionBaseProject
//
//  Created by Michael Thongvanh on 5/17/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTPSessionDataViewController, MTPSession;

@protocol MTPSessionDataDelegate <NSObject>
- (void)sessionDataController:(MTPSessionDataViewController *)dataController didSelectionSession:(MTPSession *)session;
@end

@interface MTPSessionDataViewController : NSObject <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) id <MTPSessionDataDelegate> delegate;

@property (weak, nonatomic) UITableView *sessionDataTable;
@property (readonly, nonatomic) NSDictionary *sessionsByDate;

@property (strong, nonatomic) NSDictionary *agendaAppearanceOptions;

- (void)prepareSessionDataTable:(UITableView *)tableView;
- (void)loadSessionData:(NSDictionary *)sessionData;

@end
