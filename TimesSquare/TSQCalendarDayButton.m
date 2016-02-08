//
//  TSQCalendarDayButton.m
//  TimesSquare
//
//  Created by Loretta Chan on 7/23/15.
//  Copyright (c) 2015 Square. All rights reserved.
//

#import "TSQCalendarDayButton.h"

@interface TSQCalendarDayButton ()

@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *subtitleSymbolLabel;

@end

@implementation TSQCalendarDayButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // default button type to normal day
        self.type = CalendarButtonTypeNormalDay;

        [self setTitleEdgeInsets:UIEdgeInsetsMake(-10, 0, 0, 0)];
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 65, 18)];
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.userInteractionEnabled = NO;
        self.subtitleLabel.adjustsFontSizeToFitWidth = NO;
        self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.subtitleLabel];
        
        self.subtitleSymbolLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 50, 8, 18)];
        self.subtitleSymbolLabel.userInteractionEnabled = NO;
        [self addSubview:self.subtitleSymbolLabel];
    }
    return self;
}

- (NSString *)subtitle
{
    return self.subtitleLabel.text;
}

- (void)setSubtitle:(NSString *)subtitle;
{
    if (![self.subtitleLabel.text isEqualToString:subtitle])
    {
        self.subtitleLabel.text = subtitle;
    }
}

- (NSString *)subtitleSymbol
{
    return self.subtitleSymbolLabel.text;
}

- (void)setSubtitleSymbol:(NSString *)subtitleSymbol
{
    if (![self.subtitleSymbolLabel.text isEqualToString:subtitleSymbol])
    {
        self.subtitleSymbolLabel.text = subtitleSymbol;
    }
}

- (UIFont *)subtitleFont
{
    return self.subtitleLabel.font;
}

- (void)updateSubtitleFont:(UIFont *)subtitleFont
{
    if (![self.subtitleFont isEqual:subtitleFont])
    {
        self.subtitleLabel.font = subtitleFont;
        self.subtitleSymbolLabel.font = subtitleFont;
    }
}

- (UIColor *)subtitleColor
{
    return self.subtitleLabel.textColor;
}

- (void)setSubtitleColor:(UIColor *)subtitleColor
{
    self.subtitleLabel.textColor = subtitleColor;
    self.subtitleSymbolLabel.textColor = subtitleColor;
}

- (BOOL)isForToday
{
    NSDate *today = [NSDate date];
    return [self isForDayIgnoringTime:today];
}

- (BOOL)isForDay:(NSDate *)day
{
    return [self isForDayIgnoringTime:day];
}

- (BOOL)isForDayIgnoringTime:(NSDate *)aDay
{
    if (aDay == nil || self.day == nil) {
        return NO;
    }

    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self.day];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:aDay];
    return ((components1.year == components2.year) &&
            (components1.month == components2.month) &&
            (components1.day == components2.day));
}

@end
