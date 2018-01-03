//
//  MAMConnectionsCollectionViewCell.m
//  MarriottMasters
//
//  Created by Michael Thongvanh on 4/16/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MAMConnectionsCollectionViewCell.h"
#import "EventKeys.h"
#import "UIColor+AppColors.h"

@interface MAMConnectionsCollectionViewCell ()
@property (nonatomic, strong) CAShapeLayer *circleBackground;
@property (weak, nonatomic) IBOutlet UIView *statusBackground;
@property (nonatomic, assign) CGRect previousBounds;
@end

@implementation MAMConnectionsCollectionViewCell

- (void)awakeFromNib
{
    // Initialization code
    self.circleBackground = [CAShapeLayer layer];
    
    self.connectionStatusLabel.backgroundColor = [UIColor clearColor];
    self.connectionStatusLabel.font = [UIFont fontWithName:@"FontAwesome" size:20.f];
    self.connectionStatusLabel.text = @"\uf00c";
    self.connectionStatusLabel.textColor = [UIColor whiteColor];
    self.connectionStatusLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5];
    self.connectionStatusLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    
    self.statusBackground.backgroundColor = [UIColor clearColor];
    [self.statusBackground.layer addSublayer:self.circleBackground];
    
    self.userDetailsBackground.backgroundColor = [UIColor appTintColor];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
//    self.connectionImageView.image = nil;
    self.connectionImageView.image = [UIImage imageNamed:@"no_profile"];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGRectEqualToRect(self.previousBounds, self.connectionStatusLabel.bounds))
    {
        self.previousBounds = self.connectionStatusLabel.bounds;
        
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:self.previousBounds];
        self.circleBackground.path = circlePath.CGPath;
    }
}

- (void)configureStatusButton:(NSString *)status shouldHide:(BOOL)shouldHide
{
    self.statusBackground.hidden = shouldHide;
    self.connectionStatusLabel.hidden = shouldHide;
    
    if (!status)
    {
        status = kMyConnectionNotConnected;
    }
    NSDictionary *connectionStatusDetails = [self connectionDetailsForStatus:status];
    
    UIColor *statusColor = [connectionStatusDetails objectForKey:@"color"];
    self.circleBackground.fillColor = statusColor.CGColor;
    self.circleBackground.strokeColor = statusColor.CGColor;
    
    self.connectionStatusLabel.text = [connectionStatusDetails objectForKey:@"icon"];
}

- (NSDictionary *)connectionDetailsForStatus:(NSString *)connectionStatus
{
    NSDictionary *connectionDetails = @{kMyConnectionConnected:@{@"icon": @"\uf0c1",
                                                                 @"text": @"Connected",
                                                                 @"color": kDarkGreen},
                                        
                                        kMyConnectionPending:@{@"icon": @"\uf017",
                                                               @"text": @"Pending",
                                                               @"color": kOrange},
                                        
                                        kMyConnectionNotConnected:@{@"icon": @"\uf127",
                                                                    @"text": @"Not Connected",
                                                                    @"color": kDarkBlue}
                                        };
    return [connectionDetails objectForKey:connectionStatus];
}

@end
