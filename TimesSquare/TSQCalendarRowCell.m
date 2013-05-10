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
#import "TSQCalendarRowButton.h"

@interface TSQCalendarRowCell ()

@property (nonatomic, strong) NSArray *dayButtons;
@property (nonatomic, strong) NSArray *notThisMonthButtons;
@property (nonatomic, strong) TSQCalendarRowButton *todayButton;
@property (nonatomic, strong) TSQCalendarRowButton *selectedButton;

@property (nonatomic, assign) NSInteger indexOfTodayButton;
@property (nonatomic, assign) NSInteger indexOfSelectedButton;

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
    
    return self;
}

- (void)configureButton:(TSQCalendarRowButton *)button;
{
    button.titleLabel.shadowOffset = self.shadowOffset;
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    button.subtitleLabel.shadowOffset = self.shadowOffset;
}

- (void)createDayButtons;
{
    NSMutableArray *dayButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        TSQCalendarRowButton *button = [[TSQCalendarRowButton alloc] initWithFrame:self.contentView.bounds];
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
        TSQCalendarRowButton *button = [[TSQCalendarRowButton alloc] initWithFrame:self.contentView.bounds];
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
    self.todayButton = [[TSQCalendarRowButton alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.todayButton];
    [self configureButton:self.todayButton];
    [self.todayButton addTarget:self action:@selector(todayButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    [self.todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.todayButton setBackgroundImage:[self todayBackgroundImage] forState:UIControlStateNormal];
    [self.todayButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];

    self.todayButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
}

- (void)createSelectedButton;
{
    self.selectedButton = [[TSQCalendarRowButton alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.selectedButton];
    [self configureButton:self.selectedButton];
    
    [self.selectedButton setAccessibilityTraits:UIAccessibilityTraitSelected|self.selectedButton.accessibilityTraits];
    
    self.selectedButton.enabled = NO;
    [self.selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.selectedButton setBackgroundImage:[self selectedBackgroundImage] forState:UIControlStateNormal];
    [self.selectedButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];
    
    self.selectedButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    self.indexOfSelectedButton = -1;
}

- (void)setBeginningDate:(NSDate *)date;
{
    _beginningDate = date;
    
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = 1;

    self.todayButton.hidden = YES;
    self.indexOfTodayButton = -1;
    self.selectedButton.hidden = YES;
    self.indexOfSelectedButton = -1;
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        NSString *title = [self.dayFormatter stringFromDate:date];
        NSString *subTitle = [self.calendarView shouldDisplayEventMarkerForDate:date] ? @"•" : nil;
        NSString *accessibilityLabel = [self.accessibilityFormatter stringFromDate:date];
        [self.dayButtons[index] setTitle:title forState:UIControlStateNormal];
        [self.dayButtons[index] setAccessibilityLabel:accessibilityLabel];
        [[self.dayButtons[index] subtitleLabel] setText:subTitle];
        [self.notThisMonthButtons[index] setTitle:title forState:UIControlStateNormal];
        [self.notThisMonthButtons[index] setAccessibilityLabel:accessibilityLabel];
        [[self.notThisMonthButtons[index] subtitleLabel] setText:subTitle];
        
        NSDateComponents *thisDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
        
        [self.dayButtons[index] setHidden:YES];
        [self.notThisMonthButtons[index] setHidden:YES];

        NSInteger thisDayMonth = thisDateComponents.month;
        if (self.monthOfBeginningDate != thisDayMonth) {
            [self.notThisMonthButtons[index] setHidden:NO];
        } else {

            if ([self.todayDateComponents isEqual:thisDateComponents]) {
                self.todayButton.hidden = NO;
                [self.todayButton setTitle:title forState:UIControlStateNormal];
                [self.todayButton setAccessibilityLabel:accessibilityLabel];
                [self.todayButton.subtitleLabel setText:subTitle];
                self.indexOfTodayButton = index;
            } else {
                TSQCalendarRowButton *button = self.dayButtons[index];
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
    self.calendarView.selectedDate = selectedDate;
}

- (IBAction)todayButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = self.indexOfTodayButton;
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
    self.calendarView.selectedDate = selectedDate;
}

- (void)layoutSubviews;
{
    if (!self.dayButtons) {
        [self createDayButtons];
        [self createNotThisMonthButtons];
        [self createTodayButton];
        [self createSelectedButton];
    }
    
    if (!self.backgroundView) {
        [self setBottomRow:NO];
    }
    
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
}

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
{
    TSQCalendarRowButton *dayButton = self.dayButtons[index];
    TSQCalendarRowButton *notThisMonthButton = self.notThisMonthButtons[index];
    
    dayButton.frame = rect;
    notThisMonthButton.frame = rect;

    if (self.indexOfTodayButton == (NSInteger)index) {
        self.todayButton.frame = rect;
    }
    if (self.indexOfSelectedButton == (NSInteger)index) {
        self.selectedButton.frame = rect;
    }
}

- (void)selectColumnForDate:(NSDate *)date;
{
    if (!date && self.indexOfSelectedButton == -1) {
        return;
    }

    NSInteger newIndexOfSelectedButton = -1;
    if (date) {
        NSInteger thisDayMonth = [self.calendar components:NSMonthCalendarUnit fromDate:date].month;
        if (self.monthOfBeginningDate == thisDayMonth) {
            newIndexOfSelectedButton = [self.calendar components:NSDayCalendarUnit fromDate:self.beginningDate toDate:date options:0].day;
            if (newIndexOfSelectedButton >= (NSInteger)self.daysInWeek) {
                newIndexOfSelectedButton = -1;
            }
        }
    }

    self.indexOfSelectedButton = newIndexOfSelectedButton;
    
    if (newIndexOfSelectedButton >= 0) {
        self.selectedButton.hidden = NO;
        [self.selectedButton setTitle:[self.dayButtons[newIndexOfSelectedButton] currentTitle] forState:UIControlStateNormal];
        [self.selectedButton setAccessibilityLabel:[self.dayButtons[newIndexOfSelectedButton] accessibilityLabel]];
        [self.selectedButton.subtitleLabel setText:[[self.dayButtons[newIndexOfSelectedButton] subtitleLabel] text]];
    } else {
        self.selectedButton.hidden = YES;
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
