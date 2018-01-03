//
//  MAMMapViewController.m
//  PrudentialIIC
//
//  Created by Michael Thongvanh on 5/28/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMMapViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "UIView+AutoLayoutHelper.h"
#import "UIButton+MTPNavigationBar.h"
#import "MTPAppSettingsKeys.h"

#import "UIViewController+NavigationItemSetup.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "MTPNavigationRouter.h"

@interface MAMMapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) CLLocationCoordinate2D venueLocation;
@end

@implementation MAMMapViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self startUpdates];
    [self setupMapView];
    [self setupConstraints];
    
    [self setupNavigationItem:NO];
    
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationItem] setRightBarButtonItem:[UIButton refreshMenuButton:nil target:self selector:@selector(showVenue:)]];
}

#pragma mark - Protocol Conformance
#pragma mark CLLocation Manager Delegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    CLLocation *recentLocation = [locations firstObject];
    if (recentLocation)
    {
        self.mapView.centerCoordinate = CLLocationCoordinate2DMake(recentLocation.coordinate.latitude,
                                                                   recentLocation.coordinate.longitude);
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized)
    {
        [manager startUpdatingLocation];
    }
}

#pragma mark - IBActions
#pragma mark - Helper Methods
- (void)toggleMenu:(id)sender
{
    if (self.menuToggleDelegate && [self.menuToggleDelegate respondsToSelector:@selector(topViewControllerShouldToggleMenu:)])
    {
        [self.menuToggleDelegate topViewControllerShouldToggleMenu:nil];
    }
    else
    {
        DLog(@"no delegate found");
    }
}

- (void)showVenue:(id)sender
{
    [self.mapView setCenterCoordinate:self.venueLocation animated:true];
}

#pragma mark - Initial Setup
- (void)startUpdates
{
    if (self.locationManager == nil)
    {
        self.locationManager = [CLLocationManager new];
    }
    
    self.locationManager.delegate = self;
    
    self.locationManager.pausesLocationUpdatesAutomatically = true;
    self.locationManager.activityType = CLActivityTypeFitness;
    
    [self.locationManager startMonitoringSignificantLocationChanges];
}

- (void)setupMapView
{
    self.mapView = [MKMapView new];
    self.mapView.translatesAutoresizingMaskIntoConstraints = false;
    [self.view addSubview:self.mapView];
    
    NSNumber *latitude = [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_BaseOptions] objectForKey:MTP_MapCenterX];
    NSNumber *longitude = [[[NSUserDefaults standardUserDefaults] objectForKey:MTP_BaseOptions] objectForKey:MTP_MapCenterY];
    
    CLLocationCoordinate2D eventVenue = CLLocationCoordinate2DMake(latitude.floatValue, longitude.floatValue);
    
    self.venueLocation = CLLocationCoordinate2DMake(eventVenue.latitude, eventVenue.longitude);
    MKCoordinateRegion initialRegion = MKCoordinateRegionMakeWithDistance(self.venueLocation, 300, 300);
    
    [self.mapView setRegion:initialRegion];
    [self.mapView setMapType:MKMapTypeHybrid];
    [self.mapView showsUserLocation];
    [self.mapView showsPointsOfInterest];
    [self.mapView showsBuildings];


}
#pragma mark - Auto Layout Setup
- (void)setupConstraints
{
    [self.view addConstraints:[self.mapView pinToSuperviewBounds]];
}

@end
