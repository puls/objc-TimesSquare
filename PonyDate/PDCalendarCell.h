//
//  PDCalendarCell.h
//  PonyDate
//
//  Created by Jim Puls on 11/15/12.
//  Copyright (c) 2012 Square, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDCalendarCell : UITableViewCell

+ (CGFloat)cellHeight;

@property (nonatomic, strong) NSDate *firstOfMonth;
@property (nonatomic, readonly) NSUInteger daysInWeek;
@property (nonatomic, strong) NSCalendar *calendar;

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;
- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;

@end

@interface PDCalendarCell (Styling)

+ (UIColor *)standardTextColor;
+ (UIColor *)backgroundColor;

+ (CGSize)standardShadowOffset;

@end
