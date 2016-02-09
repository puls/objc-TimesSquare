//
//  TSQCalendarDayButton.h
//  TimesSquare
//
//  Created by Loretta Chan on 7/23/15.
//  Copyright (c) 2015 Square. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CalendarButtonType) {
    CalendarButtonTypeNormalDay = 0,
    CalendarButtonTypeOtherMonth = 1,
    CalendarButtonTypeSelected = 2,
};

@interface TSQCalendarDayButton : UIButton

@property (nonatomic, assign) CalendarButtonType type;
@property (nonatomic, strong) NSDate *day;
@property (nonatomic, readwrite) NSString *subtitle;
@property (nonatomic, readwrite) NSString *subtitleSymbol;
@property (nonatomic, readwrite) UIFont *subtitleFont;
@property (nonatomic, readwrite) UIColor *subtitleColor;
@property (nonatomic, readwrite) UIImage *icon;

- (BOOL)isForToday;
- (BOOL)isForDay:(NSDate *)date;

@end
