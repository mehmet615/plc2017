//
//  MTPSpeakerMemberTableViewCell.m
//  MPFusionBaseProject
//
//  Created by Admin on 8/18/17.
//  Copyright © 2017 MeetingPlay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "MTPSpeakerMemberTableViewCell.h"

#import "CHAFontAwesome.h"

@implementation MTPSpeakerMemberTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    
    CAShapeLayer *shape = [CAShapeLayer layer];
    [self.imageContentView.layer addSublayer:shape];
    shape.opacity = 0.7;
    shape.lineJoin = kCALineJoinMiter;
    shape.strokeColor = [[UIColor clearColor] CGColor];
    shape.fillColor = [[UIColor grayColor] CGColor];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(35, 0)];
    [path addLineToPoint:CGPointMake(50, self.imageContentView.frame.size.height / 2.0)];
    [path addLineToPoint:CGPointMake(35, self.imageContentView.frame.size.height)];
    [path addLineToPoint:CGPointMake(0, self.imageContentView.frame.size.height)];
    
    [path closePath];
    shape.path = [path CGPath];
    
    [self.imageContentView bringSubviewToFront:self.imageLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureCell:(NSString *)string font:(UIFont *)font isCompany:(BOOL)isCompany
{
    NSString *htmlString = string;//[self flattenHTML:string];
    NSAttributedString *attributedString = [[NSAttributedString alloc]
                                            initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding]
                                            options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                            documentAttributes:nil
                                            error:nil];
    
    if (isCompany)
    {
        self.titleLabel.text = @"COMPANY";
        self.detailTextView.text = string;
        self.imageLabel.text = [CHAFontAwesome icon:@"fa-briefcase"];
    }
    else
    {
        self.titleLabel.text = @"BIOGRAPHY";
        self.detailTextView.text = attributedString.string;
        self.imageLabel.text = [CHAFontAwesome icon:@"fa-book"];
    }
    
    self.detailLabelFont = font;
}

#pragma mark - draw rect

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.detailTextView setFont:self.detailLabelFont];
}

@end
