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


/** The `TSQCalendarView` class displays a monthly calendar in a self-contained scrolling view. It supports any calendar that `NSCalendar` supports.
 
 The implementation and usage are very similar to `UITableView`: the app provides reusable cells via a data source and controls behavior via a delegate. See `TSQCalendarCell` for a cell superclass.
 */
@interface TSQCalendarView : UIView

/** @name Date Setup */

/** The earliest month the calendar view displays.
 
 Set this property to any `NSDate`; `TSQCalendarView` will only look at the month and year.
 Must be set for the calendar to be useful.
 */
@property (nonatomic, strong) NSDate *firstDate;

/** The latest month the calendar view displays.
 
 Set this property to any `NSDate`; `TSQCalendarView` will only look at the month and year.
 Must be set for the calendar to be useful.
 */
@property (nonatomic, strong) NSDate *lastDate;

/** The currently-selected date on the calendar.
 
 Set this property to any `NSDate`; `TSQCalendarView` will only look at the month, day, and year.
 You can read and write this property; the delegate method `calendarView:didSelectDate:` will be called both when a new date is selected from the UI and when this method is called manually.
 */
@property (nonatomic, strong) NSDate *selectedDate;

/** @name Calendar Configuration */

/** The calendar type to use when displaying.
 
 If not set, this defaults to `[NSCalendar currentCalendar]`.
 */
@property (nonatomic, strong) NSCalendar *calendar;

/** @name Visual Configuration */

/** The delegate of the calendar view.
 
 The delegate must adopt the `TSQCalendarViewDelegate` protocol.
 The `TSQCalendarView` class, which does not retain the delegate, invokes each protocol method the delegate implements.
 */
@property (nonatomic, weak) id<TSQCalendarViewDelegate> delegate;

/** Whether to pin the header to the top of the view.
 
 If you're trying to emulate the built-in calendar app, set this to `YES`. Default value is `NO`.
 */
@property (nonatomic) BOOL pinsHeaderToTop;

/** Whether or not the calendar snaps to begin a month at the top of its bounds.
 
 This property is roughly equivalent to the one defined on `UIScrollView` except the snapping is to months rather than integer multiples of the view's bounds.
 */
@property (nonatomic) BOOL pagingEnabled;

/** The distance from the edges of the view to where the content begins.
 
 This property is equivalent to the one defined on `UIScrollView`.
 */
@property (nonatomic) UIEdgeInsets contentInset;

/** The point on the calendar where the currently-visible region starts.
 
 This property is equivalent to the one defined on `UIScrollView`.
 */
@property (nonatomic) CGPoint contentOffset;

/** The cell class to use for month headers.
 
 Since there's very little configuration to be done for each cell, this can be set as a shortcut to implementing a data source.
 The class should be a subclass of `TSQCalendarMonthHeaderCell` or at least implement all of its methods.
 */
@property (nonatomic, strong) Class headerCellClass;

/** The cell class to use for week rows.
 
 Since there's very little configuration to be done for each cell, this can be set as a shortcut to implementing a data source.
 The class should be a subclass of `TSQCalendarRowCell` or at least implement all of its methods.
 */
@property (nonatomic, strong) Class rowCellClass;

/** Scrolls the receiver until the specified date month is completely visible.

 @param date A date that identifies the month that will be visible.
 @param animated YES if you want to animate the change in position, NO if it should be immediate.
 */
- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated;

@end

/** The methods in the `TSQCalendarViewDelegate` protocol allow the adopting delegate to either prevent a day from being selected or respond to it.
 */
@protocol TSQCalendarViewDelegate <NSObject>

@optional

/** @name Responding to Selection */

/** Asks the delegate whether a particular date is selectable.
 
 This method should be relatively efficient, as it is called repeatedly to appropriate enable and disable individual days on the calendar view.
 
 @param calendarView The calendar view that is selecting a date.
 @param date Midnight on the date being selected.
 @return Whether or not the date is selectable.
 */
- (BOOL)calendarView:(TSQCalendarView *)calendarView shouldSelectDate:(NSDate *)date;

/** Tells the delegate that a particular date was selected.
 
 @param calendarView The calendar view that is selecting a date.
 @param date Midnight on the date being selected.
 */
- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date;

@end
