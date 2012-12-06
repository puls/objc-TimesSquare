//
//  PDCalendarCell.m
//  PonyDate
//
//  Created by Jim Puls on 11/15/12.
//  Copyright (c) 2012 Square, Inc. All rights reserved.
//

#import "PDCalendarCell.h"


@interface PDCalendarCell ()

@property (nonatomic, assign) NSLocaleLanguageDirection layoutDirection;

@end


@implementation PDCalendarCell

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    _calendar = calendar;
    NSString *languageCode = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    self.layoutDirection = [NSLocale characterDirectionForLanguage:languageCode];
    
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
    
    CGFloat increment = floorf(self.bounds.size.width / self.daysInWeek);
    CGFloat margin = 1.0f;
    CGFloat __block start = 0.f;
    BOOL isHighRes = [UIScreen mainScreen].scale > 1.0f;
    if (isHighRes) {
        start = 0.5f;
        margin = 0.5f;
    }
    CGFloat height = self.bounds.size.height - 2 * margin;
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        CGFloat width = increment;
        if ((index == 0 || index == self.daysInWeek - 1) && isHighRes) {
            width += 0.5f;
        } else if (!isHighRes && index == self.daysInWeek - 1) {
            start -= 1.0f;
        }
        
        NSUInteger displayIndex = index;
        if (self.layoutDirection == NSLocaleLanguageDirectionRightToLeft) {
            displayIndex = self.daysInWeek - index - 1;
        }
        
        [self layoutViewsForColumnAtIndex:displayIndex inRect:CGRectMake(start, margin, width, height)];
        start += width + margin;
    }

}

@end


@implementation PDCalendarCell (Styling)

+ (UIColor *)standardTextColor;
{
    return [UIColor colorWithRed:0.47f green:0.5f blue:0.53f alpha:1.0f];
}

+ (UIColor *)backgroundColor;
{
    return [UIColor colorWithWhite:0.8f alpha:1.0f];
}

+ (CGSize)standardShadowOffset;
{
    static CGSize shadowOffset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shadowOffset = CGSizeMake(0.0f, 1.0f / UIScreen.mainScreen.scale);
    });
    return shadowOffset;
}

@end
