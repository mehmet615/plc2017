//
//  MAMQuickLinksViewController.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/10/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMQuickLinksViewController.h"
#import "MAMQuickLinkCollectionCell.h"
#import "MAMStoryboardIdentifiers.h"
#import "UIView+AutoLayoutHelper.h"
#import "NSObject+EventDefaultsHelpers.h"
#import "MTPMenuItem.h"
#import "MTPMenuIcon.h"
#import "UIButton+MTPNavigationBar.h"
#import "UINavigationBar+MTPHelper.h"
#import "CHAFontAwesome.h"
#import "MTPAppSettingsKeys.h"
#import "MTPNavigationRouter.h"
#import "UIViewController+NavigationItemSetup.h"
#import "UIColor+AppColors.h"
#import "NSObject+MTPModelValidation.h"
#import "NSString+MTPAPIAddresses.h"
#import "MTPQuickLinkCoordinator.h"
#import "MTPWebKitCoordinator.h"
#import "User.h"
#import "NSString+MTPWebViewURL.h"
#import "MTPApplicationDefaultsConstants.h"
#import "MAMQuickLinksViewController+MTPNearbyHelper.h"

#import "MTPMatchCoordinator.h"
#import "MTPNearbyCoordinator.h"
#import "MTPAttendeeListCoordinator.h"

#import "MTPThemeOptionsUpdater.h"
#import "UINavigationBar+MTPHelper.h"
#import "MTPMenuItemManager.h"
#import "MTPThemeOptionsManager.h"
#import "UIImageView+WebCache.h"

@interface MAMQuickLinksViewController () <MTPQuickLinkCoordinatorDelegate>
@property (strong, nonatomic) NSLayoutConstraint *sectionHeaderBackgroundAspectRatio;
@property (weak, nonatomic) IBOutlet UIImageView *quickLinksBackgroundImage;

@property (strong, nonatomic) MTPQuickLinkCoordinator *quickLinkCoordinator;
@property (strong, nonatomic) MTPQuickLinksAppearanceManager *appearanceManager;
@property (strong, nonatomic) MTPWebKitCoordinator *webKitCoordinator;
@property (weak, nonatomic) IBOutlet UIView *pulseFeedContainer;

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDateLabel;

@property (weak, nonatomic) IBOutlet UIView *nearMeContainer;
@end

@implementation MAMQuickLinksViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupConstraints];
    
    self.appearanceManager = [[MTPQuickLinksAppearanceManager alloc] initWithThemeOptions:self.navigationRouter.themeOptionsManager.themeOptions];
    
    if ([[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:@"quickLinksEnabled"] boolValue])
    {
        self.quickLinks = [self prepareDataSource];
        
        self.quickLinkCoordinator = [MTPQuickLinkCoordinator new];
        self.quickLinkCoordinator.delegate = self;
        [self.quickLinkCoordinator loadQuickLinks:self.quickLinks];
        self.quickLinkCoordinator.appearanceManager = self.appearanceManager;
        [self.quickLinkCoordinator setupCollectionView:self.quickLinksCollectionView inView:nil];
        
        self.quickLinksCollectionView.hidden = NO;
        self.pulseFeedContainer.hidden = YES;
    }
    else
    {
        self.webKitCoordinator = [[MTPWebKitCoordinator alloc] init:self.navigationRouter.currentUser.user_id processPool:self.navigationRouter.processPool];
        [self.webKitCoordinator setupWebView:self.pulseFeedContainer margin:@0];
        [self.webKitCoordinator loadCustomURL:[NSURL URLWithString:[NSString pulseFeedWebView]] forceReload:YES];
        
        self.pulseFeedContainer.hidden = NO;
        self.quickLinksCollectionView.hidden = YES;
    }
    
    [self reloadAppearance];
    
    [self setupNotifications];
    
    [self setupLeftBarButton];
    
    [self.navigationRouter.themeOptionsManager checkVersion];
    
    if (MTP_ATTENDEES_NEAR_ME_ENABLED)
    {
        [self setupNearbyAttendees];
        self.nearMeContainer.hidden = NO;
    }
    else
    {
        self.nearMeContainer.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    [self setupNavigationBar];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initial Setup

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateQuickLinks:) name:MTP_NavigationMenuDidUpdate object:nil];
}

- (void)reloadAppearance
{
    [self setupNavigationBar];
    
    [self setupNavigationItem:[[self.navigationRouter.themeOptionsManager.themeOptions[MPFUSION_eventInformation] objectForKey:MPFUSION_eventQREnabled] boolValue]];

    [self setupBackgroundImage];
    [self configureHeroRatio];
    [self configureBellyImage];
}

- (void)setupNavigationBar
{
    [[self.navigationController navigationBar] setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [[self.navigationController navigationBar] setShadowImage:[UIImage new]];
}

- (void)setupLeftBarButton
{
    if (self.customLeftBarItem)
    {
        [self setupLeftBarButton:self.customLeftBarItem];
    }
}

- (void)setupBackgroundImage
{
    __weak typeof(&*self)weakSelf = self;
    
    if (self.appearanceManager.backgroundImageRemote.length)
    {
        if ([self.appearanceManager.backgroundImageRemote rangeOfString:@"http"].location == NSNotFound)
        {
            UIImage *backgroundImage = [UIImage imageNamed:self.appearanceManager.backgroundImageRemote];
            [self.backgroundImage setImage:backgroundImage];
        }
        else
        {
            [self configureImage:self.appearanceManager.backgroundImageRemote completion:^(UIImage *fetchedImage, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (error)
                    {
                        DLog(@"\nerror %@",error);
                    }
                    else
                    {
                        if (fetchedImage == nil)
                        {
                            [weakSelf.backgroundImage setImage:[UIImage imageNamed:@"loginBackground"]];
                        }
                        else
                        {
                            [weakSelf.backgroundImage setImage:fetchedImage];
                        }
                    }
                });
            }];
        }
    }
    else
    {
        self.backgroundImage.image = nil;
    }
}

- (void)configureHeroRatio
{
    __weak typeof(&*self)weakSelf = self;

    if (self.appearanceManager.featuredImageRemote.length)
    {
        if ([self.appearanceManager.featuredImageRemote rangeOfString:@"http"].location == NSNotFound)
        {
            UIImage *featuredImage = [UIImage imageNamed:self.appearanceManager.featuredImageRemote];
            CGFloat aspectRatio = featuredImage.size.width/featuredImage.size.height;
            [self configureSectionHeaderSize:aspectRatio];
            [self.headerBackgroundImage setImage:featuredImage];
        }
        else
        {
            [self configureImage:self.appearanceManager.featuredImageRemote completion:^(UIImage *fetchedImage, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (error)
                    {
                        DLog(@"\nerror %@",error);
                    }
                    else
                    {
                        if (fetchedImage)
                        {
                            CGFloat aspectRatio = fetchedImage.size.width/fetchedImage.size.height;
                            [weakSelf configureSectionHeaderSize:aspectRatio];
                            [weakSelf.headerBackgroundImage setImage:fetchedImage];
                        }
                        else
                        {
                            UIImage *quickLinksHeader = [UIImage imageNamed:@"quicklinksHeaderBackground"];
                            [weakSelf.headerBackgroundImage setImage:quickLinksHeader];
                        }
                    }
                });
            }];
        }
    }
    else
    {
        [self.headerBackgroundImage setImage:[UIImage imageNamed:@"quicklinksHeaderBackground"]];
    }
}

- (void)configureBellyImage
{
    __weak typeof(&*self)weakSelf = self;
    
    if (self.appearanceManager.bellyBackgroundColor)
    {
        self.bellyContainer.backgroundColor = self.appearanceManager.bellyBackgroundColor;
    }
    
    if (self.appearanceManager.eventName.length)
    {
        self.eventNameLabel.text = self.appearanceManager.eventName;
    }
    
    if (self.appearanceManager.eventDetails.length)
    {
        self.eventDateLabel.text = self.appearanceManager.eventDetails;
    }
    
    self.eventNameLabel.textColor = self.appearanceManager.bellyEventNameColor;
    self.eventDateLabel.textColor = self.appearanceManager.bellyEventDateColor;
    
    if (self.appearanceManager.bellyImageRemote.length)
    {
        if ([self.appearanceManager.bellyImageRemote rangeOfString:@"http"].location == NSNotFound)
        {
            UIImage *backgroundImage = [UIImage imageNamed:self.appearanceManager.bellyImageRemote];
            [self.bellyImage setImage:backgroundImage];
        }
        else
        {
            [self configureImage:self.appearanceManager.bellyImageRemote completion:^(UIImage *fetchedImage, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (error)
                    {
                        DLog(@"\nerror %@",error);
                    }
                    else
                    {
                        if (fetchedImage)
                        {
                            [weakSelf.bellyImage setImage:fetchedImage];
                        }
                        else
                        {
                            weakSelf.bellyImage.hidden = YES;
                        }
                    }
                });
            }];
        }
    }
    else
    {
        self.bellyImage.hidden = YES;
    }
    
    self.bellyHeight.constant = self.appearanceManager.showBelly ? MTP_QUICKLINKS_BELLY_HEIGHT : 0;
}

- (void)configureImage:(NSString *)remoteImagePath completion:(void(^)(UIImage *,NSError *))completionHandler
{
    if (remoteImagePath.length == 0)
    {
        if (completionHandler)
        {
            completionHandler(nil,[NSError errorWithDomain:@"com.MeetingPlay.MPFusion.ImageFetch" code:3001 userInfo:@{NSLocalizedDescriptionKey: @"No remote image path found."}]);
        }
        return;
    }
    
    NSURL *imageSaveURL = [MTPThemeOptionsManager saveURLForImage:remoteImagePath];
    if (imageSaveURL.path.length)
    {
        [self.navigationRouter.themeOptionsManager fetchImage:remoteImagePath saveURL:imageSaveURL completion:completionHandler];
    }
    else
    {
        if (completionHandler)
        {
            completionHandler(nil,[NSError errorWithDomain:@"com.MeetingPlay.MPFusion.ImageFetch" code:3002 userInfo:@{NSLocalizedDescriptionKey: @"No local save path found for image."}]);
        }
    }
}

- (NSArray *)prepareDataSource
{
    return [self.navigationRouter.menuItemManager homepageItems];
}

- (void)updateQuickLinks:(NSNotification *)notification
{
    [self prepareDataSource];

    NSArray *quickLinks = [[notification userInfo] objectForKey:MTP_QuickLinksItems];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.quickLinks = quickLinks;
        [self.quickLinkCoordinator loadQuickLinks:self.quickLinks];
    });
}

#pragma mark - Protocol Conformance
- (void)quickLinkCoordinator:(MTPQuickLinkCoordinator *)quickLinkCoordinator didSelectMenuItem:(MTPMenuItem *)menuItem
{
    if (menuItem)
    {
        [self.navigationRouter loadViewController:menuItem animated:YES];
    }
}

#pragma mark - IBActions
- (IBAction)openQRCode:(id)sender
{
    MTPMenuItem *qrCodeItem = [MTPMenuItem new];
    qrCodeItem.contentType = MTPContentTypeQRReader;
    if (qrCodeItem)
    {
        [self.navigationRouter loadViewController:qrCodeItem animated:YES];
    }
    else
    {
        DLog(@"\nqr code dictionary not found");
    }
}

- (void)toggleMenu:(id)sender
{    
    if (self.menuToggler && [self.menuToggler respondsToSelector:@selector(topViewControllerShouldToggleMenu:)])
    {
        [self.menuToggler topViewControllerShouldToggleMenu:nil];
    }
}

#pragma Auto Layout Setup
- (void)setupConstraints
{
    [self.sectionHeaderContainer.superview addConstraints:@[[self.sectionHeaderContainer pinToTopLayoutGuide:self]]];
    [self.sectionHeaderContainer.superview addConstraints:[self.sectionHeaderContainer pinLeadingTrailing]];
    
    CGFloat multiplier = 1;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        multiplier = 1.5;
    }
    else
    {
        multiplier = 2.0;
    }
    
    [self configureSectionHeaderSize:multiplier];
}

- (void)configureSectionHeaderSize:(CGFloat)aspectRatio
{
    [self.sectionHeaderContainer removeConstraint:self.sectionHeaderBackgroundAspectRatio];
    
    if (isnan(aspectRatio))
    {
        aspectRatio = 1;
    }
    
    self.sectionHeaderBackgroundAspectRatio = [NSLayoutConstraint constraintWithItem:self.sectionHeaderContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.sectionHeaderContainer attribute:NSLayoutAttributeHeight multiplier:aspectRatio constant:0];
    
    [self.sectionHeaderContainer addConstraint:self.sectionHeaderBackgroundAspectRatio];
}

@end



