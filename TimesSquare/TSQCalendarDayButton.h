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
    CalendarButtonTypeToday = 2,
    CalendarButtonTypeSelected = 3,
    CalendarButtonTypeInitial = 4,
};

@interface TSQCalendarDayButton : UIButton

@property (nonatomic, assign) CalendarButtonType type;

@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *subtitleSymbolLabel;

@end
