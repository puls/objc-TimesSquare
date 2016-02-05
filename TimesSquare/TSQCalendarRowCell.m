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
#import "TSQCalendarDayButton.h"

@interface TSQCalendarRowCell ()

@property (nonatomic, strong) NSArray *dayButtons;
@property (nonatomic, strong) NSArray *notThisMonthButtons;
@property (nonatomic, strong) TSQCalendarDayButton *todayButton;
@property (nonatomic, strong) TSQCalendarDayButton *selectedButton;

@property (nonatomic, assign) NSInteger indexOfTodayButton;
@property (nonatomic, assign) NSInteger indexOfSelectedButton;

@property (nonatomic, strong) NSDateFormatter *dayFormatter;
@property (nonatomic, strong) NSDateFormatter *accessibilityFormatter;

@property (nonatomic, strong) NSDateComponents *todayDateComponents;
@property (nonatomic) NSInteger monthOfBeginningDate;

@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) NSArray *shiftNotes;

@end


@implementation TSQCalendarRowCell

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithCalendar:calendar reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    return self;
}

#pragma mark - Fonts

- (UIFont *)dayOfMonthFont
{
    return [UIFont boldSystemFontOfSize:19.0f];
}

- (UIFont *)subtitleFont
{
    return [UIFont boldSystemFontOfSize:12.0f];
}

#pragma mark - Colors

- (UIColor *)todayTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)subtitleTextColor
{
    return [UIColor blackColor];
}

- (UIColor *)selectedTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)selectedSubtitleTextColor
{
    return [UIColor whiteColor];
}

- (UIColor *)textShadowColor
{
    return [UIColor whiteColor];
}

- (UIColor *)todayTextShadowColor
{
    return [UIColor colorWithWhite:0.0f alpha:0.75f];
}

- (UIColor *)selectedTextShadowColor
{
    return [UIColor colorWithWhite:0.0f alpha:0.75f];
}

- (UIColor *)todaySubtitleTextColor
{
    return [self subtitleTextColor];
}

#pragma mark - Buttons

- (void)configureButton:(TSQCalendarDayButton *)button isSelected: (BOOL) selected;
{
    button.titleLabel.font = [self dayOfMonthFont];
    button.subtitleLabel.font = [self subtitleFont];
    button.subtitleSymbolLabel.font = [self subtitleFont];
    if (!selected) {
        button.subtitleLabel.textColor = [self subtitleTextColor];
        button.subtitleSymbolLabel.textColor = [self subtitleTextColor];
    } else {
        button.subtitleLabel.textColor = [self selectedSubtitleTextColor];
        button.subtitleSymbolLabel.textColor = [self selectedSubtitleTextColor];
    }
    button.subtitleLabel.adjustsFontSizeToFitWidth = NO;
    button.subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    button.titleLabel.shadowOffset = self.shadowOffset;
    button.adjustsImageWhenDisabled = NO;
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button setTitleShadowColor:[self textShadowColor] forState:UIControlStateNormal];

}

- (void)createDayButtons;
{
    NSMutableArray *dayButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        TSQCalendarDayButton *button = [[TSQCalendarDayButton alloc] initWithFrame:self.contentView.bounds];
        [button addTarget:self action:@selector(dateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [dayButtons addObject:button];
        [self.contentView addSubview:button];
        [self configureButton:button isSelected:NO];
        [button setTitleColor:[self.textColor colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    }
    self.dayButtons = dayButtons;
}

- (void)createNotThisMonthButtons;
{
    NSMutableArray *notThisMonthButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        TSQCalendarDayButton *button = [[TSQCalendarDayButton alloc] initWithFrame:self.contentView.bounds];
        [notThisMonthButtons addObject:button];
        [self.contentView addSubview:button];
        [self configureButton:button isSelected: NO];
        [button setTitleColor:[self.textColor colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
        button.enabled = NO;
        UIColor *backgroundPattern = [UIColor colorWithPatternImage:[self notThisMonthBackgroundImage]];
        button.backgroundColor = backgroundPattern;
    }
    self.notThisMonthButtons = notThisMonthButtons;
}

- (void)createTodayButton;
{
    self.todayButton = [[TSQCalendarDayButton alloc] initWithFrame:self.contentView.bounds];
  
    [self.contentView addSubview:self.todayButton];
    [self configureButton:self.todayButton isSelected:NO];
    [self.todayButton addTarget:self action:@selector(todayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.todayButton setTitleColor:[self todayTextColor] forState:UIControlStateNormal];
    [self.todayButton setBackgroundImage:[self todayBackgroundImage] forState:UIControlStateNormal];
    [self.todayButton setTitleShadowColor:[self todayTextShadowColor] forState:UIControlStateNormal];

    self.todayButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
}

- (void)createSelectedButton;
{
    self.selectedButton = [[TSQCalendarDayButton alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.selectedButton];
    [self configureButton:self.selectedButton isSelected:YES];
    [self.selectedButton setAccessibilityTraits:UIAccessibilityTraitSelected|self.selectedButton.accessibilityTraits];
    self.selectedButton.enabled = NO;
    [self.selectedButton setTitleColor:[self selectedTextColor] forState:UIControlStateNormal];
    [self.selectedButton setBackgroundImage:[self selectedBackgroundImage] forState:UIControlStateNormal];
    [self.selectedButton setTitleShadowColor:[self selectedTextShadowColor] forState:UIControlStateNormal];
    
    self.selectedButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    self.indexOfSelectedButton = -1;
}

- (void)updateButton:(TSQCalendarDayButton *)button
          buttonType:(CalendarButtonType)buttonType
             forDate:(NSDate *)date
{
    UIColor *dateColor = nil;
    UIColor *disabledDateColor = nil;

    // update button type
    button.type = buttonType;

    // prefer the delegate date color over everything else; this will always be
    // used if the delegate returns a color
    
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:dateColorForDate:)])
    {
        dateColor = [self.calendarView.delegate calendarView:self.calendarView dateColorForDate:date];
    }
    
    
    
    // prefer the delegate disabledDate color over everything else; this will
    // always be used if the delegate returns a color (except for other month
    // buttons)
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:disabledDateColorForDate:)])
    {
        disabledDateColor = [self.calendarView.delegate calendarView:self.calendarView disabledDateColorForDate:date];
    }

    
    
    // if the delegate doesn't return a date color, fall back to some sane defaults,
    // which can still be overridden in subclasses
    if (! dateColor)
    {
        if (buttonType == CalendarButtonTypeToday)
        {
            dateColor = [self todayTextColor];
        }
        else if (buttonType == CalendarButtonTypeSelected)
        {
            dateColor = [self selectedTextColor];
        }
        else if (buttonType == CalendarButtonTypeNormalDay)
        {
            dateColor = self.textColor;
        }
        else
        {
            dateColor = [self.textColor colorWithAlphaComponent:0.5f];
        }
    }
    
    
    
    // if the delegate doesn't return a disabled date color, fall back to a sane
    // default.  Other month buttons will always get this disabled color.
    if ((! disabledDateColor) || (buttonType == CalendarButtonTypeOtherMonth))
    {
        disabledDateColor = [self.textColor colorWithAlphaComponent:0.5f];
    }
    
    [button setTitleColor:dateColor forState:UIControlStateNormal];
    [button setTitleColor:disabledDateColor forState:UIControlStateDisabled];
    
    
    
    button.subtitleLabel.text = nil;
    button.subtitleSymbolLabel.text = nil;
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:subtitleForDate:)])
    {
        NSString *subtitle = [self.calendarView.delegate calendarView:self.calendarView subtitleForDate:date];
        button.subtitleLabel.text = subtitle;
        
        UIColor *subtitleColor = nil;
        
        // only check the color if the delegate also responds to the subtitle
        // delegate method.  Prefer this subtitle color returned by the delegate,
        // except for other month buttons.
        if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:subtitleColorForDate:)])
        {
            subtitleColor = [self.calendarView.delegate calendarView:self.calendarView subtitleColorForDate:date];
        }
        
        // if the delegate doesn't return a subtitle color, fall back to sane
        // defaults
        if (! subtitleColor)
        {
            if (buttonType == CalendarButtonTypeToday)
            {
                subtitleColor = [self todaySubtitleTextColor];
            }
            else if (buttonType == CalendarButtonTypeSelected)
            {
                subtitleColor = [self selectedSubtitleTextColor];
            }
            else
            {
                subtitleColor = [self subtitleTextColor];
            }
        }
        
        // prefer a disabled color for other month buttons, even if the delegate
        // returned a color
        if (buttonType == CalendarButtonTypeOtherMonth)
        {
            subtitleColor = [self.textColor colorWithAlphaComponent:0.5f];
        }
        
        button.subtitleLabel.textColor = subtitleColor;
        
        
        if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:subtitleTrailingSymbolForDate:)])
        {
            NSString *symbolString = [self.calendarView.delegate calendarView:self.calendarView subtitleTrailingSymbolForDate:date];
            button.subtitleSymbolLabel.text = symbolString;
            button.subtitleSymbolLabel.textColor = subtitleColor;
        }
    }
}

- (void)setBeginningDate:(NSDate *)date;
{
    _beginningDate = date;
    
    if (!self.dayButtons) {
        [self createDayButtons];
        [self createNotThisMonthButtons];
        [self createTodayButton];
        [self createSelectedButton];
    }

    NSDateComponents *offset = [NSDateComponents new];
    offset.day = 1;

    self.todayButton.hidden = YES;
    self.indexOfTodayButton = -1;
    self.selectedButton.hidden = YES;
    self.indexOfSelectedButton = -1;
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        NSString *title = [self.dayFormatter stringFromDate:date];
        NSString *accessibilityLabel = [self.accessibilityFormatter stringFromDate:date];
        
        TSQCalendarDayButton *currentDayButton = self.dayButtons[index];
        TSQCalendarDayButton *currentNotThisMonthButton = self.notThisMonthButtons[index];
        [currentDayButton setTitle:title forState:UIControlStateNormal];
        [currentDayButton setTitle:title forState:UIControlStateDisabled];
        [currentDayButton setAccessibilityLabel:accessibilityLabel];
        [currentNotThisMonthButton setTitle:title forState:UIControlStateNormal];
        [currentNotThisMonthButton setTitle:title forState:UIControlStateDisabled];
        [currentNotThisMonthButton setAccessibilityLabel:accessibilityLabel];
        
        NSDateComponents *thisDateComponents = [self.calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:date];
        
        [currentDayButton setHidden:YES];
        [currentNotThisMonthButton setHidden:YES];

        NSInteger thisDayMonth = thisDateComponents.month;
        if (self.monthOfBeginningDate != thisDayMonth)
        {
            [currentNotThisMonthButton setHidden:NO];
        }
        else
        {
            BOOL buttonEnabled = YES;
            if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)])
            {
                buttonEnabled = [self.calendarView.delegate calendarView:self.calendarView shouldSelectDate:date];
            }
            
            if ([self.todayDateComponents isEqual:thisDateComponents])
            {
                self.todayButton.hidden = NO;
                [self.todayButton setTitle:title forState:UIControlStateNormal];
                [self.todayButton setAccessibilityLabel:accessibilityLabel];
                self.indexOfTodayButton = index;
                self.todayButton.enabled = buttonEnabled;
                
                [self updateButton:self.todayButton
                        buttonType:CalendarButtonTypeToday
                           forDate:date];
            }
            else
            {
                UIButton *button = self.dayButtons[index];
                button.enabled = buttonEnabled;
                button.hidden = NO;
            }
        }
        
        [self updateButton:currentDayButton
                buttonType:CalendarButtonTypeNormalDay
                   forDate:date];
        
        [self updateButton:currentNotThisMonthButton
                buttonType:CalendarButtonTypeOtherMonth
                   forDate:date];

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
    if (!self.backgroundView) {
        [self setBottomRow:NO];
    }
    
    [super layoutSubviews];
    
    // Size the background view with horizontal insets
    CGRect bounds = self.bounds;
    UIEdgeInsets insets = self.calendarView.contentInset;
    CGRect insetRect = UIEdgeInsetsInsetRect(bounds, insets);
    insetRect.origin.y = bounds.origin.y;
    insetRect.size.height = bounds.size.height;
    self.backgroundView.frame = insetRect;
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
        NSInteger thisDayMonth = [self.calendar components:NSCalendarUnitMonth fromDate:date].month;
        if (self.monthOfBeginningDate == thisDayMonth) {
            newIndexOfSelectedButton = [self.calendar components:NSCalendarUnitDay fromDate:self.beginningDate toDate:date options:0].day;
            if (newIndexOfSelectedButton >= (NSInteger)self.daysInWeek) {
                newIndexOfSelectedButton = -1;
            }
        }
    }

    self.indexOfSelectedButton = newIndexOfSelectedButton;
    
    if (newIndexOfSelectedButton >= 0) {
        self.selectedButton.hidden = NO;
		NSString *newTitle = [self.dayButtons[newIndexOfSelectedButton] currentTitle];
		[self.selectedButton setTitle:newTitle forState:UIControlStateNormal];
		[self.selectedButton setTitle:newTitle forState:UIControlStateDisabled];
        [self.selectedButton setAccessibilityLabel:[self.dayButtons[newIndexOfSelectedButton] accessibilityLabel]];
        self.selectedButton.subtitleLabel.text = [self.dayButtons[newIndexOfSelectedButton] subtitleLabel].text;
        self.selectedButton.subtitleSymbolLabel.text = [self.dayButtons[newIndexOfSelectedButton] subtitleSymbolLabel].text;
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
        _monthOfBeginningDate = [self.calendar components:NSCalendarUnitMonth fromDate:self.firstOfMonth].month;
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
        self.todayDateComponents = [self.calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:[NSDate date]];
    }
    return _todayDateComponents;
}

@end
