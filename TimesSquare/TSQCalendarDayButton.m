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

static const CGFloat TSQCalendarRowCellMaxSubtitleHeight = 18.0f;
static const CGFloat TSQCalendarRowCellSubtitleBuffer = 15.0f;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // default button type to normal day
        self.type = CalendarButtonTypeNormalDay;

        [self setTitleEdgeInsets:UIEdgeInsetsMake(-10, 0, 0, 0)];
        self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subtitleLabel.userInteractionEnabled = NO;
        self.subtitleLabel.adjustsFontSizeToFitWidth = NO;
        self.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.subtitleLabel];
        
        self.subtitleSymbolLabel = [[UILabel alloc] initWithFrame:CGRectZero];
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

- (void)setSubtitleFont:(UIFont *)subtitleFont
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

- (CGSize)maxSubtitleSize
{
    CGFloat maxWidth = self.bounds.size.width - 2 * TSQCalendarRowCellSubtitleBuffer;
    return CGSizeMake(maxWidth, TSQCalendarRowCellMaxSubtitleHeight);
}

- (CGSize)maxSubtitleSymboleSize
{
    return CGSizeMake(8.0f, TSQCalendarRowCellMaxSubtitleHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat midX = CGRectGetMidX(self.bounds);
    CGFloat subtitleCenterY = 0.75f * CGRectGetMaxY(self.bounds);

    self.subtitleLabel.hidden = !([self.subtitleLabel.text length] > 0);
    self.subtitleSymbolLabel.hidden = !([self.subtitleSymbolLabel.text length] > 0);
    self.iconImageView.hidden = (self.iconImageView.image == nil);

    CGFloat iconWidth = self.iconImageView.image.size.width;
    CGFloat iconHeight = self.iconImageView.image.size.height;

    if (! self.subtitleLabel.hidden)
    {
        CGSize maxSubtitleSize = [self maxSubtitleSize];
        CGSize sizeThatFits = [self.subtitleLabel sizeThatFits:maxSubtitleSize];

        CGFloat subtitleWidth = fminf(sizeThatFits.width, maxSubtitleSize.width);
        CGFloat subtitleHeight = fminf(sizeThatFits.height, maxSubtitleSize.height);
        CGFloat originX = midX - subtitleWidth/2.0f;
        CGFloat originY = subtitleCenterY - subtitleHeight/2.0f;

        self.subtitleLabel.frame = CGRectMake(originX,
                                              originY,
                                              subtitleWidth,
                                              subtitleHeight);
    }

    if (! self.subtitleSymbolLabel.hidden)
    {
        CGSize maxSymbolSize = [self maxSubtitleSymboleSize];
        CGSize sizeThatFits = [self.subtitleSymbolLabel sizeThatFits:maxSymbolSize];

        CGFloat symbolWidth = fminf(sizeThatFits.width, maxSymbolSize.width);
        CGFloat symbolHeight = fminf(sizeThatFits.height, maxSymbolSize.height);
        CGFloat originX = CGRectGetMaxX(self.bounds) - TSQCalendarRowCellSubtitleBuffer;
        CGFloat originY = subtitleCenterY - symbolHeight/2.0f;

        if (! self.subtitleLabel.hidden)
        {
            // when subtitle is showing, shift symbol to right of subtitle
            CGFloat symbolBuffer = (TSQCalendarRowCellSubtitleBuffer - symbolWidth)/2.0f;
            originX = CGRectGetMaxX(self.subtitleLabel.frame) + symbolBuffer;
        }

        self.subtitleSymbolLabel.frame = CGRectMake(originX,
                                                    originY,
                                                    symbolWidth,
                                                    symbolHeight);
    }

    if (! self.iconImageView.hidden)
    {
        self.iconImageView.hidden = NO;

        CGFloat midX = CGRectGetMidX(self.bounds);

        CGFloat originX = midX - iconWidth/2.0f;
        CGFloat originY = subtitleCenterY - iconHeight/2.0f;

        if (! self.subtitleLabel.hidden)
        {
            // when subtitle is showing, shift icon to left of subtitle
            CGFloat iconBuffer = (TSQCalendarRowCellSubtitleBuffer - iconWidth)/2.0f;
            originX = self.subtitleLabel.frame.origin.x - iconWidth - iconBuffer;
        }

        self.iconImageView.frame = CGRectMake(originX,
                                              originY,
                                              iconWidth,
                                              iconHeight);
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
