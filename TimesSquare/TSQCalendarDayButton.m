//
//  TSQCalendarDayButton.m
//  TimesSquare
//
//  Created by Loretta Chan on 7/23/15.
//  Copyright (c) 2015 Square. All rights reserved.
//

#import "TSQCalendarDayButton.h"

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
        self.tsqSubtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.tsqSubtitleLabel.textAlignment = NSTextAlignmentCenter;
        self.tsqSubtitleLabel.userInteractionEnabled = NO;
        self.tsqSubtitleLabel.adjustsFontSizeToFitWidth = NO;
        self.tsqSubtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self addSubview:self.tsqSubtitleLabel];
        
        self.subtitleSymbolLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.subtitleSymbolLabel.userInteractionEnabled = NO;
        [self addSubview:self.subtitleSymbolLabel];

        self.iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.iconImageView.userInteractionEnabled = NO;
        [self addSubview:self.iconImageView];

        [self registerForNotifications];
    }
    return self;
}

- (void)dealloc
{
    [self unregisterForNotifications];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat midX = CGRectGetMidX(self.bounds);
    CGFloat subtitleCenterY = 0.75f * CGRectGetMaxY(self.bounds);

    self.tsqSubtitleLabel.hidden = !([self.tsqSubtitleLabel.text length] > 0);
    self.subtitleSymbolLabel.hidden = !([self.subtitleSymbolLabel.text length] > 0);
    self.iconImageView.hidden = (self.iconImageView.image == nil);

    CGFloat iconWidth = self.iconImageView.image.size.width;
    CGFloat iconHeight = self.iconImageView.image.size.height;

    if (! self.tsqSubtitleLabel.hidden)
    {
        CGSize maxSubtitleSize = [self maxSubtitleSize];
        CGSize sizeThatFits = [self.tsqSubtitleLabel sizeThatFits:maxSubtitleSize];

        CGFloat subtitleWidth = fminf(sizeThatFits.width, maxSubtitleSize.width);
        CGFloat subtitleHeight = fminf(sizeThatFits.height, maxSubtitleSize.height);
        CGFloat originX = midX - subtitleWidth/2.0f;
        CGFloat originY = subtitleCenterY - subtitleHeight/2.0f;

        CGRect subtitleFrame = CGRectMake(floorf(originX),
                                          floorf(originY),
                                          subtitleWidth,
                                          subtitleHeight);
        self.tsqSubtitleLabel.frame = CGRectIntegral(subtitleFrame);
    }

    if (! self.subtitleSymbolLabel.hidden)
    {
        CGSize maxSymbolSize = [self maxSubtitleSymbolSize];
        CGSize sizeThatFits = [self.subtitleSymbolLabel sizeThatFits:maxSymbolSize];

        CGFloat symbolWidth = fminf(sizeThatFits.width, maxSymbolSize.width);
        CGFloat symbolHeight = fminf(sizeThatFits.height, maxSymbolSize.height);
        CGFloat originX = CGRectGetMaxX(self.bounds) - TSQCalendarRowCellSubtitleBuffer;
        CGFloat originY = subtitleCenterY - symbolHeight/2.0f;

        if (! self.tsqSubtitleLabel.hidden)
        {
            // when subtitle is showing, shift symbol to right of subtitle
            CGFloat symbolBuffer = (TSQCalendarRowCellSubtitleBuffer - symbolWidth)/2.0f;
            originX = CGRectGetMaxX(self.tsqSubtitleLabel.frame) + symbolBuffer;
        }

        CGRect symbolFrame = CGRectMake(floorf(originX),
                                        floorf(originY),
                                        symbolWidth,
                                        symbolHeight);
        self.subtitleSymbolLabel.frame = CGRectIntegral(symbolFrame);
    }

    if (! self.iconImageView.hidden)
    {
        CGFloat midX = CGRectGetMidX(self.bounds);

        CGFloat originX = midX - iconWidth/2.0f;
        CGFloat originY = subtitleCenterY - iconHeight/2.0f;

        if (! self.tsqSubtitleLabel.hidden)
        {
            // when subtitle is showing, shift icon to left of subtitle
            CGFloat iconBuffer = (TSQCalendarRowCellSubtitleBuffer - iconWidth)/2.0f;
            originX = self.tsqSubtitleLabel.frame.origin.x - iconWidth - iconBuffer;
        }

        CGRect iconFrame = CGRectMake(floorf(originX),
                                      floorf(originY),
                                      iconWidth,
                                      iconHeight);
        self.iconImageView.frame = CGRectIntegral(iconFrame);
    }
}

#pragma mark - Observations

- (void)registerForNotifications
{
    [self.tsqSubtitleLabel addObserver:self
                         forKeyPath:@"font"
                            options:NSKeyValueObservingOptionNew
                            context:nil];

    [self.tsqSubtitleLabel addObserver:self
                         forKeyPath:@"text"
                            options:NSKeyValueObservingOptionNew
                            context:nil];

    [self.subtitleSymbolLabel addObserver:self
                               forKeyPath:@"font"
                                  options:NSKeyValueObservingOptionNew
                                  context:nil];

    [self.subtitleSymbolLabel addObserver:self
                               forKeyPath:@"text"
                                  options:NSKeyValueObservingOptionNew
                                  context:nil];

    [self.iconImageView addObserver:self
                         forKeyPath:@"image"
                            options:NSKeyValueObservingOptionNew
                            context:nil];
}

- (void)unregisterForNotifications
{
    [self.tsqSubtitleLabel removeObserver:self forKeyPath:@"font"];
    [self.tsqSubtitleLabel removeObserver:self forKeyPath:@"text"];
    [self.subtitleSymbolLabel removeObserver:self forKeyPath:@"font"];
    [self.subtitleSymbolLabel removeObserver:self forKeyPath:@"text"];
    [self.iconImageView removeObserver:self forKeyPath:@"image"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    // relayout subviews when certain properties of the subtitle label, subtitle symbol label, or icon image view changes
    [self layoutSubviews];
}

#pragma mark - Helper Methods

- (CGSize)maxSubtitleSize
{
    CGFloat maxWidth = self.bounds.size.width - 2 * TSQCalendarRowCellSubtitleBuffer;
    return CGSizeMake(maxWidth, TSQCalendarRowCellMaxSubtitleHeight);
}

- (CGSize)maxSubtitleSymbolSize
{
    return CGSizeMake(8.0f, TSQCalendarRowCellMaxSubtitleHeight);
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
