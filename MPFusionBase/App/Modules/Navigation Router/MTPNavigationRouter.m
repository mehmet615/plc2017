//
//  MTPNavigationRouter.m
//  MeetingPlayBaseiPhoneProject
//
//  Created by Michael Thongvanh on 11/19/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPNavigationRouter.h"
#import "MTPBaseNavigationController.h"
#import "MAMBaseViewController.h"

#import "MAMQuickLinksViewController+MTPNearbyHelper.h"
#import "MAMConnectionsViewController.h"
#import "MAMMapViewController.h"
#import "MAMQRReaderViewController.h"
#import "MAMWebViewController.h"
#import "MTPWebViewController.h"
#import "MAMConnectionsViewController.h"
#import "MAMCustomPhotoUploadViewController.h"
#import "MTPSearchResultsViewController.h"
#import "MTPAgendaViewController.h"
#import "MTPAttendeeListViewController.h"
#import "MTPSpeakersViewController.h"
#import "MTPGeneralInfoViewController.h"
#import "MAMLoginViewController.h"
#import "MTPLoginClient.h"
#import "MTPAPIDataInitializer.h"

#import "MTPNavigationRouter.h"
#import "MTPMenuItem.h"
#import <CoreData/NSManagedObjectContext.h>
#import "User+Helpers.h"

#import "MAMStoryboardIdentifiers.h"

#import "NSObject+EventDefaultsHelpers.h"
#import "EventKeys.h"
#import "MTPAppSettingsKeys.h"
#import "NSString+MTPAPIAddresses.h"
#import "NSString+MTPWebViewURL.h"
#import <WebKit/WebKit.h>
#import <EventKit/EventKit.h>

@interface MTPNavigationRouter ()
@property (strong, nonatomic) EKEventStore *eventStore;
@end

@implementation MTPNavigationRouter

- (instancetype)initWithRouterDelegate:(id<MTPNavigationRouterDelegate,MTPMainMenuTogglable>)routerDelegate
{
    self = [super init];
    
    if (self)
    {
        _routerDelegate = routerDelegate;
        _processPool = [[WKProcessPool alloc] init];
        _eventStore = [[EKEventStore alloc] init];
    }
    
    return self;
}

- (void)loadInitialViewController:(void (^)(UIViewController *))completionHandler
{
    UIViewController *loadedViewController = nil;
    
    NSNumber *currentUserID = self.currentUser.user_id;
    if (currentUserID)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:MTP_LoginNotification
                                                            object:nil
                                                          userInfo:@{@"user_id": currentUserID}];
        [self.currentUser fetchUpdatedInfo:nil];
        
        loadedViewController = [self loadMainScreen:self.currentUser];
    }
    else
    {
        loadedViewController = [self loadLogin:self.rootObjectContext];
    }
    
    if (completionHandler)
    {
        completionHandler(loadedViewController);
    }
}

- (void)forwardViewControllerLoading:(UIViewController *)viewControllerToLoad animated:(BOOL)animated
{
    if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(navigationRouter:didLoadViewController:animated:)])
    {
        [self.routerDelegate navigationRouter:self didLoadViewController:viewControllerToLoad animated:animated];
    }
}

- (void)loadViewController:(MTPMenuItem *)menuItem animated:(BOOL)animated
{
    UIViewController *rootViewController = [self configureViewController:menuItem
                                                             currentUser:self.currentUser
                                                    managedObjectContext:self.rootObjectContext];
    
    [self forwardViewControllerLoading:rootViewController animated:animated];
}

- (UIViewController *)configureViewController:(MTPMenuItem *)menuItem currentUser:(User *)currentUser managedObjectContext:(NSManagedObjectContext *)rootObjectContext
{
    UIViewController *selectedViewController = nil;
    
    switch (menuItem.contentType)
    {
        case MTPContentTypeWebViewLegacy:
        {
            MAMWebViewController *webViewController = [[MAMWebViewController alloc] initWithNibName:@"MAMWebViewController" bundle:nil];
            webViewController.customURL = menuItem.webviewURL;
            webViewController.currentUser = currentUser;
            
            webViewController.menuToggleDelegate = self.routerDelegate;
            
            webViewController.themeOptionsManager = self.themeOptionsManager;
            webViewController.navigationRouter = self;
            
            selectedViewController = webViewController;
            break;
        }
        case MTPContentTypeWebView:
        {
            MTPWebViewController *webViewController = [[MTPWebViewController alloc] initWithNibName:NSStringFromClass([MTPWebViewController class]) bundle:nil];
            webViewController.customURL = menuItem.webviewURL;
            webViewController.currentUser = currentUser;
            webViewController.processPool = self.processPool;
            
            webViewController.menuToggleDelegate = self.routerDelegate;
            
            webViewController.themeOptionsManager = self.themeOptionsManager;
            webViewController.navigationRouter = self;
            
            selectedViewController = webViewController;
            break;
        }
        case MTPContentTypeHome:
        {
            MAMQuickLinksViewController *quickLinks = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:MAMQuickLinksViewControllerIdentifier];
            quickLinks.navigationRouter = self;
            quickLinks.nearbyCoordinator = self.dataInitializer.nearbyCoordinator;
            quickLinks.menuToggler = self.routerDelegate;
            
            NSTimer *nearbyUpdateTimer = [NSTimer timerWithTimeInterval:25 target:quickLinks selector:@selector(updateNearby:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:nearbyUpdateTimer forMode:NSDefaultRunLoopMode];
            quickLinks.nearbyUpdateTimer = nearbyUpdateTimer;

            selectedViewController = quickLinks;
            break;
        }
        case MTPContentTypeAgenda:
        {
            MTPAgendaViewController *agenda = [[MTPAgendaViewController alloc] initWithNibName:NSStringFromClass([MTPAgendaViewController class]) bundle:nil];
            agenda.navigationRouter = self;
            agenda.currentUser = self.currentUser;
            agenda.themeOptionsManager = self.themeOptionsManager;
            agenda.sessionManager = self.dataInitializer.sessionManager;
            agenda.menuToggler = self.routerDelegate;
            
            selectedViewController = agenda;
            break;
        }
        case MTPContentTypePhotoUpload:
        {
            MAMCustomPhotoUploadViewController *photoUpload = [[UIStoryboard storyboardWithName:@"PhotoUpload" bundle:nil] instantiateViewControllerWithIdentifier:MAMCustomPhotoUploadViewControllerIdentifier];
            photoUpload.currentUser = currentUser;
            photoUpload.menuToggleDelegate = self.routerDelegate;
            photoUpload.themeOptionsManager = self.themeOptionsManager;
            
            selectedViewController = photoUpload;
            break;
        }
        case MTPContentTypeQRReader:
        {
            MAMQRReaderViewController *qrReader = [MAMQRReaderViewController new];
            qrReader.navigationRouter = self;
            qrReader.menuToggleDelegate = self.routerDelegate;
            
            selectedViewController = qrReader;
            break;
        }
        case MTPContentTypeAttendees:
        {
            MTPAttendeeListViewController *attendees = [[MTPAttendeeListViewController alloc] initWithNibName:@"MTPAttendeeListViewController" bundle:nil];
            attendees.navigationRouter = self;
            attendees.menuToggler = self.routerDelegate;
            attendees.currentUser = self.currentUser;
            attendees.themeOptionsManager = self.themeOptionsManager;
            [attendees loadData:self.dataInitializer.users];
            
            selectedViewController = attendees;
            break;
        }
        case MTPContentTypeSpeakers:
        {
            MTPSpeakersViewController *attendees = [[MTPSpeakersViewController alloc] initWithNibName:@"MTPSpeakersViewController" bundle:nil];
            attendees.navigationRouter = self;
            attendees.menuToggler = self.routerDelegate;
            attendees.currentUser = self.currentUser;
            attendees.themeOptionsManager = self.themeOptionsManager;
            
            selectedViewController = attendees;
            break;
        }
        case MTPContentTypeGeneralInfo:
        {
            MTPGeneralInfoViewController *generalInfoVC = [[MTPGeneralInfoViewController alloc] initWithNibName:@"MTPGeneralInfoViewController" bundle:nil];
            generalInfoVC.navigationRouter = self;
            generalInfoVC.menuToggler = self.routerDelegate;
            generalInfoVC.currentUser = self.currentUser;
            generalInfoVC.themeOptionsManager = self.themeOptionsManager;
            
            selectedViewController = generalInfoVC;
            break;
        }
        default: {
            DLog(@"\nunknown data source type! %@", menuItem);
            selectedViewController = nil;
        }
    }
    
    return selectedViewController;
}

- (UIViewController *)loadLogin:(NSManagedObjectContext *)rootObjectContext
{
    if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(navigationRouter:didLoadLogin:)])
    {
        MTPLoginClient *loginClient = [MTPLoginClient loginClient:rootObjectContext];
        MAMLoginViewController *loginViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:MAMLoginViewControllerIdentifier];
        loginViewController.loginClient = loginClient;
        loginViewController.navigationRouter = self;
        
        [self.routerDelegate navigationRouter:self didLoadLogin:loginViewController];
        return loginViewController;
    }
    else
    {
#ifdef DEBUG
        NSLog(@"delegate check failed");
#endif
        return nil;
    }
}

- (UIViewController *)loadMainScreen:(User *)currentUser
{
    if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(navigationRouter:didLoadMainScreen:)])
    {
        MAMQuickLinksViewController *quickLinksController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:MAMQuickLinksViewControllerIdentifier];
        quickLinksController.navigationRouter = self;
        quickLinksController.nearbyCoordinator = self.dataInitializer.nearbyCoordinator;
        quickLinksController.menuToggler = self.routerDelegate;
        
        NSTimer *nearbyUpdateTimer = [NSTimer timerWithTimeInterval:25 target:quickLinksController selector:@selector(updateNearby:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:nearbyUpdateTimer forMode:NSDefaultRunLoopMode];
        quickLinksController.nearbyUpdateTimer = nearbyUpdateTimer;

        [self.routerDelegate navigationRouter:self didLoadMainScreen:quickLinksController];
        return quickLinksController;
    }
    else
    {
#ifdef DEBUG
        NSLog(@"delegate check failed");
#endif
        return nil;
    }
}


#pragma mark - Alternate View Controller Loading
- (void)loadSearch:(NSString *)searchQuery
{
    MTPSearchResultsViewController *searchViewController = [MTPSearchResultsViewController new];
    searchViewController.userID = self.currentUser.user_id;
    searchViewController.themeOptionsManager = self.themeOptionsManager;
    searchViewController.searchQuery = searchQuery;
    searchViewController.menuToggler = self.routerDelegate;
    
    if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(navigationRouter:didLoadViewController:animated:)])
    {
        [self.routerDelegate navigationRouter:self didLoadViewController:searchViewController animated:NO];
    }
    else
    {
        DLog(@"\ndelegate check failed %@",self.routerDelegate);
    }
}

- (void)openPhotoUploads:(NSURL *)url profile:(BOOL)profileUpload video:(BOOL)videoUpload
{
    __block NSString *channel = nil;
    
    NSString *queryString = url.query;
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    [queryComponents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj rangeOfString:@"channel=" options:NSCaseInsensitiveSearch].length)
        {
            NSString *trimmedPath = [obj stringByReplacingOccurrencesOfString:@"channel=" withString:@""];
            channel = [trimmedPath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'"]];
            *stop = true;
        }
    }];
    
    MTPMenuItem *photoUploadItem = [MTPMenuItem new];
    photoUploadItem.contentType = MTPContentTypePhotoUpload;
    
    MAMCustomPhotoUploadViewController *photoUploadViewController = (MAMCustomPhotoUploadViewController *)[self configureViewController:photoUploadItem currentUser:self.currentUser managedObjectContext:self.rootObjectContext];
    photoUploadViewController.profile = profileUpload;
    photoUploadViewController.channel = channel;
    photoUploadViewController.videoUpload = videoUpload;
    
    if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(navigationRouter:didLoadPhotoUpload:)])
    {
        [self.routerDelegate navigationRouter:self didLoadPhotoUpload:photoUploadViewController];
    }
}

- (void)openQRCode
{
    MTPMenuItem *qrCodeItem = [MTPMenuItem new];
    qrCodeItem.contentType = MTPContentTypeQRReader;
    [self loadViewController:qrCodeItem animated:NO];
}

- (void)openPoll:(NSURL *)destinationUrl realTimePoll:(NSNumber *)realTimePoll
{
    MTPMenuItem *pollItem = [MTPMenuItem new];
    pollItem.contentType = MTPContentTypeWebView;
    pollItem.webviewURL = destinationUrl.absoluteString;
    [self loadViewController:pollItem animated:NO];
}

- (void)openSessionDetails:(NSString *)scheduleID
{
    MTPMenuItem *sessionDetails = [MTPMenuItem new];
    sessionDetails.contentType = MTPContentTypeWebView;
    sessionDetails.webviewURL = [NSString stringWithFormat:[NSString sessionDetailsURL],scheduleID];
    [self loadViewController:sessionDetails animated:NO];
}

- (void)openDocument:(NSURL *)url
{
    __block NSString *path = nil;
    
    NSString *queryString = url.query;
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    [queryComponents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj rangeOfString:@"path=" options:NSCaseInsensitiveSearch].length)
        {
            NSString *trimmedPath = [obj stringByReplacingOccurrencesOfString:@"path=" withString:@""];
            path = trimmedPath;
            *stop = true;
        }
    }];
    
    NSString *remoteUrlString = path;
    if (remoteUrlString.length == 0) {
        return;
    }
    
    if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(navigationRouter:didLoadDocument:)])
    {
        [self.routerDelegate navigationRouter:self didLoadDocument:[NSURL URLWithString:remoteUrlString]];
    }
    else
    {
        DLog(@"delegate check failed %@",self.routerDelegate);
    }
}

- (void)openPage:(NSURL *)url
{
    __block NSString *path = nil;
    
    NSString *queryString = url.query;
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    [queryComponents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj rangeOfString:@"path=" options:NSCaseInsensitiveSearch].length)
        {
            NSString *trimmedPath = [obj stringByReplacingOccurrencesOfString:@"path=" withString:@""];
            path = [trimmedPath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'"]];
            *stop = true;
        }
    }];
    
    if (path.length)
    {
        MTPMenuItem *sessionDetails = [MTPMenuItem new];
        sessionDetails.contentType = MTPContentTypeWebView;
        sessionDetails.webviewURL = path;
        [self loadViewController:sessionDetails animated:NO];
    }
}

- (void)pushPage:(NSURL *)url;
{
    __block NSString *path = nil;
    
    NSString *queryString = url.query;
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    [queryComponents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        if ([obj rangeOfString:@"path=" options:NSCaseInsensitiveSearch].length)
        {
            NSString *trimmedPath = [obj stringByReplacingOccurrencesOfString:@"path=" withString:@""];
            path = [trimmedPath stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'"]];
            *stop = true;
        }
    }];
    
    MAMWebViewController *webViewController = [self webViewWithURL:path];
    if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(navigationRouter:didPush:)])
    {
        [self.routerDelegate navigationRouter:self didPush:webViewController];
    }
    else
    {
        DLog(@"delegate check failed %@",self.routerDelegate);
    }
}

- (void)goBack
{
    if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(navigationRouterDidGoBack:)])
    {
        [self.routerDelegate navigationRouterDidGoBack:self];
    }
    else
    {
        DLog(@"delegate check failed %@",self.routerDelegate);
    }
}

- (void)dashboard
{
    MTPMenuItem *dashboard = [MTPMenuItem new];
    dashboard.contentType = MTPContentTypeHome;
    [self loadViewController:dashboard animated:NO];
}

- (void)scheduleEvent:(NSURL *)eventURL
{
    if ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized)
    {
        [self addEvent:eventURL];
    }
    else
    {
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error)
         {
             if (granted)
             {
                 [self addEvent:eventURL];
             }
             else
             {
                 SIAlertView *calendarAlert = [[SIAlertView alloc] initWithTitle:@"Calendar Error" andMessage:@"Please allow access to the calendar in order to add events."];
                 [calendarAlert addButtonWithTitle:@"Retry" type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView)
                  {
                      [self scheduleEvent:eventURL];
                  }];
                 [calendarAlert addButtonWithTitle:@"Cancel" type:SIAlertViewButtonTypeCancel handler:nil];
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [calendarAlert show];
                 });
             }
         }];
    }
}

- (EKCalendar *)calendar
{
    EKCalendar *moneyCalendar = [self.eventStore defaultCalendarForNewEvents];
    if (moneyCalendar)
    {
        return moneyCalendar;
    }
    
    // 1
    NSArray *calendars = [self.eventStore calendarsForEntityType:EKEntityTypeEvent];
    
    // 2
    NSString *calendarTitle = @"Calendar";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title matches %@", calendarTitle];
    NSArray *filtered = [calendars filteredArrayUsingPredicate:predicate];
    
    if ([filtered count])
    {
        moneyCalendar = [filtered firstObject];
    }
    else
    {
        // 3
        moneyCalendar = [self.eventStore defaultCalendarForNewEvents];
        if (moneyCalendar == nil)
        {
            moneyCalendar = [EKCalendar calendarForEntityType:EKEntityTypeEvent eventStore:self.eventStore];
            moneyCalendar.title = @"Events";
            moneyCalendar.source = self.eventStore.defaultCalendarForNewEvents.source;
            moneyCalendar.CGColor = [UIColor blueColor].CGColor;
        }
        
        // 4
        NSError *calendarErr = nil;
        BOOL calendarSuccess = [self.eventStore saveCalendar:moneyCalendar commit:YES error:&calendarErr];
        if (!calendarSuccess)
        {
            // Handle error
        }
    }
    return moneyCalendar;
}


- (void)addEvent:(NSURL *)eventURL
{
    __block NSString *title = nil;
    __block NSString *startTimeString = nil;
    __block NSString *startDateString = nil;
    
    __block NSString *endTimeString = nil;
    __block NSString *endDateString = nil;
    
    __block NSString *timezoneString = nil;
    
    NSString *queryString = eventURL.query;
    queryString = [queryString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    [queryComponents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
     {
         if ([obj rangeOfString:@"title=" options:NSCaseInsensitiveSearch].length)
         {
             title = [obj stringByReplacingOccurrencesOfString:@"title=" withString:@""];
         }
         else if ([obj rangeOfString:@"startTime=" options:NSCaseInsensitiveSearch].length)
         {
             startTimeString = [obj stringByReplacingOccurrencesOfString:@"startTime=" withString:@""];
         }
         else if ([obj rangeOfString:@"startDate=" options:NSCaseInsensitiveSearch].length)
         {
             startDateString = [obj stringByReplacingOccurrencesOfString:@"startDate=" withString:@""];
         }
         else if ([obj rangeOfString:@"endTime=" options:NSCaseInsensitiveSearch].length)
         {
             endTimeString = [obj stringByReplacingOccurrencesOfString:@"endTime=" withString:@""];
         }
         else if ([obj rangeOfString:@"endDate=" options:NSCaseInsensitiveSearch].length)
         {
             endDateString = [obj stringByReplacingOccurrencesOfString:@"endDate=" withString:@""];
         }
         else if ([obj rangeOfString:@"timezone=" options:NSCaseInsensitiveSearch].length)
         {
             timezoneString = [obj stringByReplacingOccurrencesOfString:@"timezone=" withString:@""];
         }
     }];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.formatterBehavior = NSDateFormatterBehaviorDefault;
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm"];
    
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:timezoneString];
    dateFormatter.timeZone = timeZone;
    
    NSDate *startDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",startDateString,startTimeString]];
    NSDate *endDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@",endDateString,endTimeString]];
    
    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
    event.startDate = startDate;
    event.endDate = endDate;
    event.title = title;
    
    event.calendar = [self calendar];
    
    NSError *saveError = nil;
    if ([self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&saveError])
    {
        DLog(@"\nsaved event %@",event);
        SIAlertView *eventSaveAlert = [[SIAlertView alloc] initWithTitle:@"Event Saved" andMessage:@"The event has been saved to your calendar."];
        [eventSaveAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeDefault handler:nil];
        [eventSaveAlert show];
    }
    else
    {
        SIAlertView *calendarAlert = [[SIAlertView alloc] initWithTitle:@"Calendar Error" andMessage:saveError.localizedDescription];
        [calendarAlert addButtonWithTitle:@"OK" type:SIAlertViewButtonTypeCancel handler:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [calendarAlert show];
        });
    }
}

- (MAMWebViewController *)webViewWithURL:(NSString *)urlString
{
    MAMWebViewController *webViewController = [[MAMWebViewController alloc] initWithNibName:@"MAMWebViewController" bundle:nil];
    webViewController.customURL = urlString;
    webViewController.currentUser = self.currentUser;
    
    webViewController.menuToggleDelegate = self.routerDelegate;
    
    webViewController.themeOptionsManager = self.themeOptionsManager;
    webViewController.navigationRouter = self;
    
    return webViewController;
}

// SSO Handling
- (void)handleLogin:(NSURL *)url
{
    if (self.routerDelegate && [self.routerDelegate respondsToSelector:@selector(navigationRouter:didLoginSSO:)])
    {
        [self.routerDelegate navigationRouter:self didLoginSSO:url];
    }
    else
    {
        DLog(@"delegate check error %@",self.routerDelegate);
    }
}

@end
