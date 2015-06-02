//
//  TSQCalendarRowCell.m
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarRowCell.h"
#import "TSQCalendarView.h"


@interface TSQCalendarRowCell ()

@property (nonatomic, strong) NSArray *dayButtons;
@property (nonatomic, strong) NSArray *notThisMonthButtons;
@property (nonatomic, strong) UIButton *todayButton;
@property (nonatomic, strong) NSArray *selectedButtons;

@property (nonatomic, assign) NSInteger indexOfTodayButton;
@property (nonatomic, strong) NSMutableIndexSet *indexesOfSelectedButtons;

@property (nonatomic, strong) NSDateFormatter *dayFormatter;
@property (nonatomic, strong) NSDateFormatter *accessibilityFormatter;

@property (nonatomic, strong) NSDateComponents *todayDateComponents;
@property (nonatomic) NSInteger monthOfBeginningDate;

@end


@implementation TSQCalendarRowCell

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithCalendar:calendar reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    _indexesOfSelectedButtons = [NSMutableIndexSet indexSet];
    
    return self;
}


- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.selectedButtons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
        obj.hidden = YES;
    }];
    
    self.todayButton.hidden = YES;
}

- (void)configureButton:(UIButton *)button;
{
    button.titleLabel.font = [UIFont boldSystemFontOfSize:19.f];
    button.titleLabel.shadowOffset = self.shadowOffset;
    button.adjustsImageWhenDisabled = NO;
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)createDayButtons;
{
    NSMutableArray *dayButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        [button addTarget:self action:@selector(dateButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [dayButtons addObject:button];
        [self.contentView addSubview:button];
        [self configureButton:button];
        [button setTitleColor:[self.textColor colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    }
    self.dayButtons = dayButtons;
}

- (void)createNotThisMonthButtons;
{
    NSMutableArray *notThisMonthButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        [notThisMonthButtons addObject:button];
        [self.contentView addSubview:button];
        [self configureButton:button];

        button.enabled = NO;
        UIColor *backgroundPattern = [UIColor colorWithPatternImage:[self notThisMonthBackgroundImage]];
        button.backgroundColor = backgroundPattern;
        button.titleLabel.backgroundColor = backgroundPattern;
    }
    self.notThisMonthButtons = notThisMonthButtons;
}

- (void)createTodayButton;
{
    self.todayButton = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.todayButton];
    [self configureButton:self.todayButton];
    [self.todayButton addTarget:self action:@selector(todayButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    [self.todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.todayButton setBackgroundImage:[self todayBackgroundImage] forState:UIControlStateNormal];
    [self.todayButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];

    self.todayButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
}

- (void)createSelectedButtons;
{
    NSMutableArray *selectedButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        
        UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        button.hidden = YES;
        [self.contentView addSubview:button];
        [self configureButton:button];
        
        [button setAccessibilityTraits:UIAccessibilityTraitSelected|button.accessibilityTraits];
        
        button.enabled = NO;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[self selectedBackgroundImage] forState:UIControlStateNormal];
        [button setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];
        
        button.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
        
        [selectedButtons addObject:button];
    }
    
    self.selectedButtons = selectedButtons;
    self.indexesOfSelectedButtons = [NSMutableIndexSet indexSet];
}

- (void)setBeginningDate:(NSDate *)date;
{
    _beginningDate = date;
  
    if (!self.dayButtons) {
        [self createDayButtons];
        [self createNotThisMonthButtons];
        [self createTodayButton];
        [self createSelectedButtons];
    }

    NSDateComponents *offset = [NSDateComponents new];
    offset.day = 1;

    self.todayButton.hidden = YES;
    self.indexOfTodayButton = -1;
    [self.indexesOfSelectedButtons removeAllIndexes];
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        NSString *title = [self.dayFormatter stringFromDate:date];
        NSString *accessibilityLabel = [self.accessibilityFormatter stringFromDate:date];
        [self.dayButtons[index] setTitle:title forState:UIControlStateNormal];
        [self.dayButtons[index] setAccessibilityLabel:accessibilityLabel];
        [self.notThisMonthButtons[index] setTitle:title forState:UIControlStateNormal];
        [self.notThisMonthButtons[index] setTitle:title forState:UIControlStateDisabled];
        [self.notThisMonthButtons[index] setAccessibilityLabel:accessibilityLabel];
        
        NSDateComponents *thisDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
        
        [self.dayButtons[index] setHidden:YES];
        [self.notThisMonthButtons[index] setHidden:YES];

        NSInteger thisDayMonth = thisDateComponents.month;
        if (self.monthOfBeginningDate != thisDayMonth || [self.calendarView.firstSelectableDate compare:date] == NSOrderedDescending) {
            [self.notThisMonthButtons[index] setHidden:NO];
        } else {

            if ([self.todayDateComponents isEqual:thisDateComponents]) {
                self.todayButton.hidden = NO;
                [self.todayButton setTitle:title forState:UIControlStateNormal];
                [self.todayButton setAccessibilityLabel:accessibilityLabel];
                self.indexOfTodayButton = index;
            } else {
                UIButton *button = self.dayButtons[index];
                button.enabled = ![self.calendarView.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)] || [self.calendarView.delegate calendarView:self.calendarView shouldSelectDate:date];
                button.hidden = NO;
            }
        }

        date = [self.calendar dateByAddingComponents:offset toDate:date options:0];
    }
}

- (void)setBottomRow:(BOOL)bottomRow;
{
    UIImageView *backgroundImageView = (UIImageView *)self.backgroundView;
    if ([backgroundImageView isKindOfClass:[UIImageView class]] && _bottomRow == bottomRow) {
        return;
    }

    _bottomRow = bottomRow;
    
    self.backgroundView = [[UIImageView alloc] initWithImage:self.backgroundImage];
    
    [self setNeedsLayout];
}

- (IBAction)dateButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = [self.dayButtons indexOfObject:sender];
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
    
    if (self.calendarView.selectionMode == TSQSelectionModeMultiple) {
        
        NSMutableArray *tmp = [self.calendarView.selectedDates mutableCopy];
        
        if ([tmp containsObject:selectedDate]) {
            [tmp removeObject:selectedDate];
        } else {
            [tmp addObject:selectedDate];
        }
        
        self.calendarView.selectedDates = tmp;
    } else {
        self.calendarView.selectedDate = selectedDate;
    }
}

- (IBAction)todayButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = self.indexOfTodayButton;
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
    
    if (self.calendarView.selectionMode == TSQSelectionModeMultiple) {
        
        NSMutableArray *tmp = [self.calendarView.selectedDates mutableCopy];
        
        if ([tmp containsObject:selectedDate]) {
            [tmp removeObject:selectedDate];
        } else {
            [tmp addObject:selectedDate];
        }
        
        self.calendarView.selectedDates = tmp;
    } else {
        self.calendarView.selectedDate = selectedDate;
    }
}

- (void)layoutSubviews;
{
    if (!self.backgroundView) {
        [self setBottomRow:NO];
    }
    
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
}

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
{
    UIButton *dayButton = self.dayButtons[index];
    UIButton *notThisMonthButton = self.notThisMonthButtons[index];
    
    dayButton.frame = rect;
    notThisMonthButton.frame = rect;

    if (self.indexOfTodayButton == (NSInteger)index) {
        self.todayButton.frame = rect;
    }
    
    [self.indexesOfSelectedButtons enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        if (idx == index) {
            [self.selectedButtons[idx] setFrame:rect];
        }
    }];
}

- (void)selectColumnForDate:(NSDate *)date;
{
    if (!date && self.indexesOfSelectedButtons == nil) {
        return;
    }

    NSInteger newIndexOfSelectedButton = NSNotFound;
    if (date) {
        NSInteger thisDayMonth = [self.calendar components:NSMonthCalendarUnit fromDate:date].month;
        if (self.monthOfBeginningDate == thisDayMonth) {
            newIndexOfSelectedButton = [self.calendar components:NSDayCalendarUnit fromDate:self.beginningDate toDate:date options:0].day;
            if (newIndexOfSelectedButton >= (NSInteger)self.daysInWeek || newIndexOfSelectedButton < 0) {
                newIndexOfSelectedButton = NSNotFound;
            }
        }
    }
    
    // if this row has no selected date then unselect all dates
    if (newIndexOfSelectedButton == NSNotFound) {
        if (self.calendarView.selectionMode == TSQSelectionModeSingle) {
            [self.selectedButtons enumerateObjectsUsingBlock:^(UIButton *obj, NSUInteger idx, BOOL *stop) {
                obj.hidden = YES;
            }];
        }
        return;
    }

    UIButton *button = self.selectedButtons[newIndexOfSelectedButton];
    
    // remove previous selection if single selection mode
    if (self.calendarView.selectionMode == TSQSelectionModeSingle && self.indexesOfSelectedButtons.count > 0) {
        UIButton *previousSelectedButton = self.selectedButtons[self.indexesOfSelectedButtons.firstIndex];
        previousSelectedButton.hidden = YES;
        
        // remove all indexes
        [self.indexesOfSelectedButtons removeAllIndexes];
    }
    
    if ([self.indexesOfSelectedButtons containsIndex:newIndexOfSelectedButton]) {
        // remove index and un-select button
        [self.indexesOfSelectedButtons removeIndex:newIndexOfSelectedButton];
        
        button.hidden = YES;
        
    } else {
        // add index and select button
        [self.indexesOfSelectedButtons addIndex:newIndexOfSelectedButton];
        
        NSString *newTitle = [self.dayButtons[newIndexOfSelectedButton] currentTitle];
        [button setTitle:newTitle forState:UIControlStateNormal];
        [button setTitle:newTitle forState:UIControlStateDisabled];
        [button setAccessibilityLabel:[self.dayButtons[newIndexOfSelectedButton] accessibilityLabel]];
        
        button.hidden = NO;
    }
    
    [self setNeedsLayout];
}

- (NSDateFormatter *)dayFormatter;
{
    if (!_dayFormatter) {
        _dayFormatter = [NSDateFormatter new];
        _dayFormatter.calendar = self.calendar;
        _dayFormatter.dateFormat = @"d";
    }
    return _dayFormatter;
}

- (NSDateFormatter *)accessibilityFormatter;
{
    if (!_accessibilityFormatter) {
        _accessibilityFormatter = [NSDateFormatter new];
        _accessibilityFormatter.calendar = self.calendar;
        _accessibilityFormatter.dateStyle = NSDateFormatterLongStyle;
    }
    return _accessibilityFormatter;
}

- (NSInteger)monthOfBeginningDate;
{
    if (!_monthOfBeginningDate) {
        _monthOfBeginningDate = [self.calendar components:NSMonthCalendarUnit fromDate:self.firstOfMonth].month;
    }
    return _monthOfBeginningDate;
}

- (void)setFirstOfMonth:(NSDate *)firstOfMonth;
{
    [super setFirstOfMonth:firstOfMonth];
    self.monthOfBeginningDate = 0;
}

- (NSDateComponents *)todayDateComponents;
{
    if (!_todayDateComponents) {
        self.todayDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:[NSDate date]];
    }
    return _todayDateComponents;
}

@end
