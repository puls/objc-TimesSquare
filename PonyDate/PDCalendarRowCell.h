//
//  PDCalendarRowCell.h
//  PonyDate
//
//  Created by Jim Puls on 11/14/12.
//  Copyright (c) 2012 Square, Inc. All rights reserved.
//

#import "PDCalendarCell.h"


@class PDCalendarView;


@interface PDCalendarRowCell : PDCalendarCell

@property (nonatomic, strong) NSDate *beginningDate;
@property (nonatomic, weak) PDCalendarView *calendarView;
@property (nonatomic, getter = isBottomRow) BOOL bottomRow;

@property (nonatomic, weak, readonly) UIImage *todayBackgroundImage;
@property (nonatomic, weak, readonly) UIImage *selectedBackgroundImage;
@property (nonatomic, weak, readonly) UIImage *notThisMonthBackgroundImage;
@property (nonatomic, weak, readonly) UIImage *backgroundImage;

- (void)selectButtonForDate:(NSDate *)date;

@end
