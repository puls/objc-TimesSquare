//
//  TSQCalendarRowCell.h
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarCell.h"

/** The `TSQCalendarRowCell` class is a cell that represents one week in the calendar.
 
 Each of the seven columns can represent a day that's in this month, a day that's not in this month, a selected day, today, or an unselected day. The cell uses several images placed strategically to achieve the effect.
 */
@interface TSQCalendarRowCell : TSQCalendarCell

/** @name Images */

/** The background image for the entire row.
 
 This image should be as wide as the entire view and include the grid lines between the columns. It will probably also include the grid line at the top of the row, but not the one at the bottom.
 
 You might, however, return a different image that includes both the grid line at the top and the one at the bottom if the `bottomRow` property is set to `YES`. You might even adjust the `cellHeight`.
 */
@property (nonatomic, weak, readonly) UIImage *backgroundImage;

/** The background image for a day that's selected.
 
 This is blue in the system's built-in Calendar app. You probably want to use a stretchable image.
 */
@property (nonatomic, weak, readonly) UIImage *selectedBackgroundImage;

/** The background image for a day that's "today".
 
 This is dark gray in the system's built-in Calendar app. You probably want to use a stretchable image.
 */
@property (nonatomic, weak, readonly) UIImage *todayBackgroundImage;

/** The background image for a day that's not this month.
 
 These are the trailing days from the previous month or the leading days from the following month. This can be `nil`.
 */
@property (nonatomic, weak, readonly) UIImage *notThisMonthBackgroundImage;

/** @name State Properties Set by Calendar View */

/** The date at the beginning of the week for this cell.
 
 Notice that it might be before the `firstOfMonth` property or it might be after.
 */
@property (nonatomic, strong) NSDate *beginningDate;

/** Whether this cell is the bottom row / last week for the month.
 
 You may find yourself using a different background image or laying out differently in the last row.
 */
@property (nonatomic, getter = isBottomRow) BOOL bottomRow;

/** Method to select a specific date within the week.

 This is funneled through and called by the calendar view, to facilitate deselection of other rows.
 
 @param date The date to select, or nil to deselect all columns.
 */
- (void)selectColumnForDate:(NSDate *)date;

@end
