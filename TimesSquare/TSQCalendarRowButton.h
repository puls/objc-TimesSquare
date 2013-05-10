//
//  TSQCalendarButton.h
//  TimesSquare
//
//  Created by Simon Booth on 10/05/2013.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.


#import <UIKit/UIKit.h>

/** The `TSQCalendarRowButton` class is a button that represents single day in the calendar.
 
 The button contains an additional label which is used to display an event marker.
 */
@interface TSQCalendarRowButton : UIButton

/** A label used to display an event marker
 
 The marker is shown using the bullet character '•'
 
 */
@property (nonatomic, strong, readonly) UILabel *subtitleLabel;

@end
