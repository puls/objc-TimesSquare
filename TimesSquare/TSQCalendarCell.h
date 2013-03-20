//
//  TSQCalendarCell.h
//  TimesSquare
//
//  Created by Jim Puls on 11/15/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <UIKit/UIKit.h>


@class TSQCalendarView;


/** The `TSQCalendarCell` class is an abstract superclass to the two cell types used for display in a `TSQCalendarView`.
 
 Most of its interface deals with display properties. The most interesting method is `-layoutViewsForColumnAtIndex:inRect:`, which is a simple way of handling seven columns.
 */
@interface TSQCalendarCell : UITableViewCell

/** @name State Properties Set by Calendar View */

/** The first day of the month this cell is currently representing.
 
 This can be useful for calculations and for display.
 */
@property (nonatomic, strong) NSDate *firstOfMonth;

/** How many days there are in a week.
 
 This is usually 7.
 */
@property (nonatomic, readonly) NSUInteger daysInWeek;

/** The calendar type we're displaying.
 
 This is whatever the owning `TSQCalendarView`'s `calendar` property is set to; it's likely `[NSCalendar currentCalendar]`.
 */
@property (nonatomic, strong) NSCalendar *calendar;

/** The owning calendar view.
 
 This is a weak reference.
 */
@property (nonatomic, weak) TSQCalendarView *calendarView;

/** @name Display Properties */

/** The preferred height for instances of this cell.
 
 The built-in implementation in `TSQCalendarCell` returns `46.0f`. Your subclass may want to return another value.
 */
+ (CGFloat) cellHeight;

/** The text color.
 
 This is used for all text the cell draws; if a date is disabled, then it will draw in this color, but at 50% opacity.
 */
@property (nonatomic, strong) UIColor *textColor;

/** The text shadow offset.
 
 This is as you would set on `UILabel`.
 */
@property (nonatomic) CGSize shadowOffset;

/** The spacing between columns.
 
 This defaults to one pixel or `1.0 / [UIScreen mainScreen].scale`.
 */
@property (nonatomic) CGFloat columnSpacing;

/** @name Initialization */

/** Initializes the cell.
 
 @param calendar The `NSCalendar` the cell is representing
 @param reuseIdentifier A string reuse identifier, as used by `UITableViewCell`
 */
- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;

/** Seven-column layout helper.
 
 @param index The index of the column we're laying out, probably in the range [0..6]
 @param rect The rect relative to the bounds of the cell's content view that represents the column.
 
 Feel free to adjust the rect before moving views and to vertically position them within the column. (In fact, you could ignore the rect entirely; it's just there to help.)
 */
- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;

@end
