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

@property (nonatomic, strong) UIImageView *iconImageView;

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

        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.iconImageView.userInteractionEnabled = NO;
        [self addSubview:self.iconImageView];
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
        [self layoutSubviews];
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
        [self layoutSubviews];
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
        [self layoutSubviews];
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

- (UIImage *)icon
{
    return self.iconImageView.image;
}

- (void)setIcon:(UIImage *)icon
{
    if (![self.iconImageView.image isEqual:icon])
    {
        self.iconImageView.image = icon;
        [self layoutSubviews];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat subtitleCenterY = 0.75f * CGRectGetMaxY(self.bounds);
    self.iconImageView.hidden = (self.iconImageView.image == nil);
    if (! self.iconImageView.hidden)
    {
        self.iconImageView.hidden = NO;

        CGFloat iconWidth = self.iconImageView.image.size.width;
        CGFloat iconHeight = self.iconImageView.image.size.height;

        CGFloat midX = CGRectGetMidX(self.bounds);

        CGFloat originX = midX - iconWidth/2.0f;
        CGFloat originY = subtitleCenterY - iconHeight/2.0f;

        self.iconImageView.frame = CGRectMake(originX,
                                              originY,
                                              iconWidth,
                                              iconHeight);

#warning need to layout icon differently if subtitle is displayed
    }
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
