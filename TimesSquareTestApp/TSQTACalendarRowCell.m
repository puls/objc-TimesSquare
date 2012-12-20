//
//  TSQTACalendarRowCell.m
//  TimesSquare
//
//  Created by Jim Puls on 12/5/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQTACalendarRowCell.h"

@implementation TSQTACalendarRowCell

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
{
    // Move down for the row at the top
    rect.origin.y += self.columnSpacing;
    rect.size.height -= (self.bottomRow ? 2.0f : 1.0f) * self.columnSpacing;
    [super layoutViewsForColumnAtIndex:index inRect:rect];
}

- (UIImage *)todayBackgroundImage;
{
    return [[UIImage imageNamed:@"CalendarTodaysDate.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

- (UIImage *)selectedBackgroundImage;
{
    return [[UIImage imageNamed:@"CalendarSelectedDate.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

- (UIImage *)notThisMonthBackgroundImage;
{
    return [[UIImage imageNamed:@"CalendarPreviousMonth.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
}

- (UIImage *)backgroundImage;
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"CalendarRow%@.png", self.bottomRow ? @"Bottom" : @""]];
}

@end
