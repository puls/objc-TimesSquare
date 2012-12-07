//
//  TSQCalendarCell.h
//  TimesSquare
//
//  Created by Jim Puls on 11/15/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <UIKit/UIKit.h>

@interface TSQCalendarCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, strong) NSDate *firstOfMonth;
@property (nonatomic, readonly) NSUInteger daysInWeek;
@property (nonatomic, strong) NSCalendar *calendar;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) CGSize shadowOffset;

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;
- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;

@end
