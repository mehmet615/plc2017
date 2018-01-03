//
//  MTPSession.m
//  MeetingPlayiBeaconStarter
//
//  Created by Michael Thongvanh on 4/7/15.
//  Copyright (c) 2015 MeetingPlay. All rights reserved.
//

#import "MTPSession.h"
#import "NSObject+MTPModelValidation.h"
#import <UIKit/NSAttributedString.h>
#import <UIKit/UIFont.h>

@implementation MTPSession

-(void)fillValuesFromResponseObject:(NSDictionary *)response
{
    self.location = [[response objectForKey:@"location"] mtp_stringValue];
    self.track = [[response objectForKey:@"track"] mtp_stringValue];
    self.modified = [[response objectForKey:@"modified"] mtp_stringValue];
    self.sessionDescription = [[response objectForKey:@"description"] mtp_stringValue];
    self.teaser = [[response objectForKey:@"teaser"] mtp_stringValue];
    self.session_id = [[response objectForKey:@"session_id"] mtp_numberValue];
    self.schedule_id = [[response objectForKey:@"schedule_id"] mtp_numberValue];
    self.end_time = [[response objectForKey:@"end_time"] mtp_stringValue];
    self.start_time = [[response objectForKey:@"start_time"] mtp_stringValue];
    self.created = [[response objectForKey:@"created"] mtp_stringValue];
    self.photo = [[response objectForKey:@"photo"] mtp_stringValue];
    self.sessionTitle = [[response objectForKey:@"title"] mtp_stringValue];
    self.goto_session_details = [[response objectForKey:@"goto_session_details"] mtp_numberValue];
    
    self.attributedSessionTitle = [self createAttributedString:self.sessionTitle bold:YES];
    self.attributedSessionTeaser = [self createAttributedString:self.teaser bold:NO];
    self.attributedSessionDescription = [self createAttributedString:self.sessionDescription bold:NO];
    
    if(self.start_time == nil) {
        self.start_time = [[response objectForKey:@"startdatetime"] mtp_stringValue];
    }
    
    if(self.end_time == nil) {
        self.end_time = [[response objectForKey:@"enddatetime"] mtp_stringValue];
    }
    
    if(self.track == nil) {
        self.track = [[response objectForKey:@"trackName"] mtp_stringValue];
    }
}

- (NSAttributedString *)createAttributedString:(NSString *)htmlText bold:(BOOL)bold
{
    if (htmlText.length == 0)
    {
        return nil;
    }
    
    UIFont *font = bold ? [UIFont fontWithName:@"Lato-Bold" size:15.f] : [UIFont fontWithName:@"Lato-Regular" size:13.f];
    
    NSData *htmlTextData = [htmlText dataUsingEncoding:NSUTF8StringEncoding];
    NSError *attributedStringCreationError = nil;
    NSMutableAttributedString *htmlAttributedText = [[NSMutableAttributedString alloc] initWithData:htmlTextData options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:&attributedStringCreationError];
    [htmlAttributedText addAttributes:@{NSFontAttributeName:font} range:NSMakeRange(0, htmlAttributedText.length)];
    
    return htmlAttributedText;
}

- (NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.formatterBehavior = [NSDateFormatter defaultFormatterBehavior];
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setDateFormat:@"MMMM, dd yyyy HH:mm:ss"];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    if (date == nil)
    {
        NSLog(@"\ndebugging message %@",self);
    }
    return date;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _location = [aDecoder decodeObjectForKey:@"location"];
        _track = [aDecoder decodeObjectForKey:@"track"];
        _modified = [aDecoder decodeObjectForKey:@"modified"];
        _sessionDescription = [aDecoder decodeObjectForKey:@"sessionDescription"];
        _teaser = [aDecoder decodeObjectForKey:@"teaser"];
        _session_id = [aDecoder decodeObjectForKey:@"session_id"];
        _schedule_id = [aDecoder decodeObjectForKey:@"schedule_id"];
        _allow_questions = [aDecoder decodeBoolForKey:@"allow_questions"];
        _end_time = [aDecoder decodeObjectForKey:@"end_time"];
        _start_time = [aDecoder decodeObjectForKey:@"start_time"];
        _created = [aDecoder decodeObjectForKey:@"created"];
        _photo = [aDecoder decodeObjectForKey:@"photo"];
        _sessionTitle = [aDecoder decodeObjectForKey:@"sessionTitle"];
        _beaconId = [aDecoder decodeObjectForKey:@"beaconId"];
        _goto_session_details = [aDecoder decodeObjectForKey:@"goto_session_details"];
        _attributedSessionTitle = [aDecoder decodeObjectForKey:@"attributedSessionTitle"];
        _attributedSessionTeaser = [aDecoder decodeObjectForKey:@"attributedSessionTeaser"];
        _attributedSessionDescription = [aDecoder decodeObjectForKey:@"attributedSessionDescription"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.track forKey:@"track"];
    [aCoder encodeObject:self.modified forKey:@"modified"];
    [aCoder encodeObject:self.sessionDescription forKey:@"sessionDescription"];
    [aCoder encodeObject:self.teaser forKey:@"teaser"];
    [aCoder encodeObject:self.session_id forKey:@"session_id"];
    [aCoder encodeObject:self.schedule_id forKey:@"schedule_id"];
    [aCoder encodeBool:self.allow_questions forKey:@"allow_questions"];
    [aCoder encodeObject:self.end_time forKey:@"end_time"];
    [aCoder encodeObject:self.start_time forKey:@"start_time"];
    [aCoder encodeObject:self.created forKey:@"created"];
    [aCoder encodeObject:self.photo forKey:@"photo"];
    [aCoder encodeObject:self.sessionTitle forKey:@"sessionTitle"];
    [aCoder encodeObject:self.beaconId forKey:@"beaconId"];
    [aCoder encodeObject:self.goto_session_details forKey:@"goto_session_details"];
    [aCoder encodeObject:self.attributedSessionTitle forKey:@"attributedSessionTitle"];
    [aCoder encodeObject:self.attributedSessionTeaser forKey:@"attributedSessionTeaser"];
    [aCoder encodeObject:self.attributedSessionDescription forKey:@"attributedSessionDescription"];
}

@end
