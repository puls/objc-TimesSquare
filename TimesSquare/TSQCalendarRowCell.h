//
//  TSQCalendarRowCell.h
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarCell.h"


@class TSQCalendarView;


@interface TSQCalendarRowCell : TSQCalendarCell

@property (nonatomic, strong) NSDate *beginningDate;
@property (nonatomic, weak) TSQCalendarView *calendarView;
@property (nonatomic, getter = isBottomRow) BOOL bottomRow;

@property (nonatomic, weak, readonly) UIImage *todayBackgroundImage;
@property (nonatomic, weak, readonly) UIImage *selectedBackgroundImage;
@property (nonatomic, weak, readonly) UIImage *notThisMonthBackgroundImage;
@property (nonatomic, weak, readonly) UIImage *backgroundImage;

- (void)selectButtonForDate:(NSDate *)date;

@end
