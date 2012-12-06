//
//  PDTACalendarRowCell.m
//  PonyDate
//
//  Created by Jim Puls on 12/5/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "PDTACalendarRowCell.h"

@implementation PDTACalendarRowCell

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
