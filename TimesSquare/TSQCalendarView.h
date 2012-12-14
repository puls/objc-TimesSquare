//
//  TSQCalendarState.h
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <UIKit/UIKit.h>


@protocol TSQCalendarViewDelegate;


@interface TSQCalendarView : UIView

@property (nonatomic, strong) NSDate *firstDate;
@property (nonatomic, strong) NSDate *lastDate;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, weak) id<TSQCalendarViewDelegate> delegate;
@property (nonatomic) UIEdgeInsets contentInset;

@property (nonatomic, strong) Class headerCellClass;
@property (nonatomic, strong) Class rowCellClass;

@end


@protocol TSQCalendarViewDelegate <NSObject>

@optional
- (BOOL)calendarView:(TSQCalendarView *)calendarView shouldSelectDate:(NSDate *)date;
- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date;

@end
