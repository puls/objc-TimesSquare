//
//  PDCalendarState.h
//  PonyDate
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <UIKit/UIKit.h>


@protocol PDCalendarViewDelegate;


@interface PDCalendarView : UIView

@property (nonatomic, strong) NSDate *firstDate;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, weak) id<PDCalendarViewDelegate> delegate;

@property (nonatomic, strong) Class headerCellClass;
@property (nonatomic, strong) Class rowCellClass;

@end


@protocol PDCalendarViewDelegate <NSObject>

@optional
- (BOOL)calendarView:(PDCalendarView *)calendarView shouldSelectDate:(NSDate *)date;
- (void)calendarView:(PDCalendarView *)calendarView didSelectDate:(NSDate *)date;

@end
