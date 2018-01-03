//
//  MTPAttendeeListCoordinator.m
//  CPC2016
//
//  Created by MeetingPlay on 11/22/16.
//  Copyright © 2016 MeetingPlay. All rights reserved.
//

#import "MTPAttendeeListCoordinator.h"
#import "User+Helpers.h"
#import "UIImageView+WebCache.h"
#import "MTPDLogDefine.h"

@interface MTPAttendeeListCoordinator ()
@property (strong, nonatomic) NSArray *displayedAttendees;
@end

@implementation MTPAttendeeListCoordinator

- (void)loadAttendees:(NSArray *)attendees
{
    self.displayedAttendees = attendees;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.displayedAttendees.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MTPQuickLinkAttendeeCell *cell = (MTPQuickLinkAttendeeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MTPAttendeeListCell" forIndexPath:indexPath];
    cell.attendeeImageView.image = nil;
    cell.attendeeImageView.hidden = YES;
    
    User *attendee = self.displayedAttendees[indexPath.row];
    NSURL *imageURL = [attendee displayImageURL];
    if (imageURL)
    {
        cell.showImage = YES;
        [cell.attendeeImageView sd_setImageWithURL:imageURL];
    }
    else
    {
        cell.showImage = NO;
    }
    
    NSString *firstName = attendee.first_name;
    NSString *lastName = attendee.last_name.length ? [NSString stringWithFormat:@"%@.",[attendee.last_name substringToIndex:1]] : @"";
    
    NSString *displayName = [NSString stringWithFormat:@"%@%@",
                             firstName.length ? firstName : @"",
                             firstName.length ? [NSString stringWithFormat:@" %@",lastName] : lastName];
    
    cell.attendeeNameLabel.text = displayName;
    cell.initialsLabel.text = [NSString stringWithFormat:@"%@%@",
                               firstName.length ? [firstName substringToIndex:1] : @"",
                               lastName.length ? [lastName substringToIndex:1] : @""];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.attendeeDelegate && [self.attendeeDelegate respondsToSelector:@selector(attendeeCoordinatorDidSelectAttendee:)])
    {
        User *attendee = self.displayedAttendees[indexPath.row];
        [self.attendeeDelegate attendeeCoordinatorDidSelectAttendee:attendee];
    }
    else
    {
        DLog(@"delegate check failed %@",self.attendeeDelegate);
    }
}

@end


@implementation MTPQuickLinkAttendeeCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.attendeeImageView setImage:[UIImage new]];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.attendeeImageView.layer.masksToBounds = YES;
    self.initialsLabel.layer.masksToBounds = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.attendeeImageView.hidden = !self.showImage;
    
    self.attendeeImageView.layer.cornerRadius = CGRectGetWidth(self.attendeeImageView.frame) / 2.f;
    self.initialsLabel.layer.cornerRadius = CGRectGetWidth(self.attendeeImageView.frame) / 2.f;
}

@end
