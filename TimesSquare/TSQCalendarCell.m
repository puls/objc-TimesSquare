//
//  TSQCalendarCell.m
//  TimesSquare
//
//  Created by Jim Puls on 11/15/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarCell.h"
#import "TSQCalendarView.h"


@interface TSQCalendarCell ()

@property (nonatomic, assign) NSLocaleLanguageDirection layoutDirection;

@end


@implementation TSQCalendarCell

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    _calendar = calendar;
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    self.layoutDirection = [NSLocale characterDirectionForLanguage:languageCode];
    self.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    
    static CGSize shadowOffset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shadowOffset = CGSizeMake(0.0f, onePixel);
    });
    self.shadowOffset = shadowOffset;
    self.columnSpacing = onePixel;
    self.textColor = [UIColor colorWithRed:0.47f green:0.5f blue:0.53f alpha:1.0f];

    return self;
}

+ (CGFloat)cellHeight;
{
    return 46.0f;
}

- (NSUInteger)daysInWeek;
{
    static NSUInteger daysInWeek = 0;
    if (daysInWeek == 0) {
        daysInWeek = [self.calendar maximumRangeOfUnit:NSWeekdayCalendarUnit].length;
    }
    return daysInWeek;
}

- (UITableViewCellSelectionStyle)selectionStyle;
{
    return UITableViewCellSelectionStyleNone;
}

- (void)setHighlighted:(BOOL)selected animated:(BOOL)animated;
{
    // do nothing
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated;
{
    // do nothing
}

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
{
    // for subclass to implement
}

- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    UIEdgeInsets insets = self.calendarView.contentInset;
    
    
    CGRect insetRect = UIEdgeInsetsInsetRect(self.bounds, insets);
    insetRect.origin.y = CGRectGetMinY(self.bounds);
    insetRect.size.height = CGRectGetHeight(self.bounds);
    CGFloat increment = (CGRectGetWidth(insetRect) - (self.daysInWeek - 1) * self.columnSpacing) / self.daysInWeek;
    increment = roundf(increment);
    CGFloat __block start = insets.left;
    
    CGFloat extraSpace = (CGRectGetWidth(insetRect) - (self.daysInWeek - 1) * self.columnSpacing) - (increment * self.daysInWeek);
    
    // Divide the extra space out over the outer columns in increments of the column spacing
    NSInteger columnsWithExtraSpace = (NSInteger)fabsf(extraSpace / self.columnSpacing);
    NSInteger columnsOnLeftWithExtraSpace = columnsWithExtraSpace / 2;
    NSInteger columnsOnRightWithExtraSpace = columnsWithExtraSpace - columnsOnLeftWithExtraSpace;
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        CGFloat width = increment;
        if (index < columnsOnLeftWithExtraSpace || index >= self.daysInWeek - columnsOnRightWithExtraSpace) {
            width += (extraSpace / columnsWithExtraSpace);
        }
        
        NSUInteger displayIndex = index;
        if (self.layoutDirection == NSLocaleLanguageDirectionRightToLeft) {
            displayIndex = self.daysInWeek - index - 1;
        }
        
        CGRect columnBounds = self.bounds;
        columnBounds.origin.x = start;
        columnBounds.size.width = width;
        [self layoutViewsForColumnAtIndex:displayIndex inRect:columnBounds];
        start += width + self.columnSpacing;
    }

}

@end
