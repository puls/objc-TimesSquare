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

- (void)selectButtonForDate:(NSDate *)date;

@end
