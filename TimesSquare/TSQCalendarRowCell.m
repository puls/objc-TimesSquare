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
@property (nonatomic, strong) TSQCalendarDayButton *selectedButton;

@property (nonatomic, assign) NSInteger indexOfSelectedButton;

@property (nonatomic, strong) NSDateFormatter *dayFormatter;
@property (nonatomic, strong) NSDateFormatter *accessibilityFormatter;

@property (nonatomic) NSInteger monthOfBeginningDate;

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

- (UIColor *)initialDayTextColor
{
    return [self textColor];
}

- (UIColor *)initialDayTextShadowColor
{
    return [self textShadowColor];
}

- (UIColor *)initialDaySubtitleTextColor
{
    return [self subtitleTextColor];
}

#pragma mark - Buttons

- (void)configureButton:(TSQCalendarDayButton *)button
{
    [self updateColorsForButton:button];

    button.titleLabel.font = [self dayOfMonthFont];
    button.subtitleLabel.font = [self subtitleFont];
    button.subtitleSymbolLabel.font = [self subtitleFont];
    button.titleLabel.shadowOffset = self.shadowOffset;
    button.adjustsImageWhenDisabled = NO;
}

- (void)createDayButtons;
{
    NSMutableArray *dayButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        TSQCalendarDayButton *button = [[TSQCalendarDayButton alloc] initWithFrame:self.contentView.bounds];
        button.type = CalendarButtonTypeNormalDay;
        [button addTarget:self action:@selector(dateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [dayButtons addObject:button];
        [self.contentView addSubview:button];
        [self configureButton:button];
    }
    self.dayButtons = dayButtons;
}

- (void)createNotThisMonthButtons;
{
    NSMutableArray *notThisMonthButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        TSQCalendarDayButton *button = [[TSQCalendarDayButton alloc] initWithFrame:self.contentView.bounds];
        button.type = CalendarButtonTypeOtherMonth;
        [notThisMonthButtons addObject:button];
        [self.contentView addSubview:button];
        [self configureButton:button];
        button.enabled = NO;
        UIColor *backgroundPattern = [UIColor colorWithPatternImage:[self notThisMonthBackgroundImage]];
        button.backgroundColor = backgroundPattern;
    }
    self.notThisMonthButtons = notThisMonthButtons;
}

- (void)createSelectedButton;
{
    TSQCalendarDayButton *button = [[TSQCalendarDayButton alloc] initWithFrame:self.contentView.bounds];
    button.type = CalendarButtonTypeSelected;
    [self.contentView addSubview:button];
    [self configureButton:button];
    [button setBackgroundImage:[self selectedBackgroundImage] forState:UIControlStateNormal];
    [button setAccessibilityTraits:UIAccessibilityTraitSelected|button.accessibilityTraits];
    button.enabled = NO;
    button.hidden = YES;
    self.indexOfSelectedButton = -1;

    self.selectedButton = button;
}

- (void)updateColorsForButton:(TSQCalendarDayButton *)button
{
    UIColor *dateColor = nil;
    UIColor *disabledDateColor = nil;
    UIColor *dateShadowColor = nil;

    NSDate *date = button.day;

    // ** DATE COLOR **/

    // prefer the delegate date color over everything else; this will always be
    // used if the delegate returns a color
    
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:dateColorForDate:)])
    {
        dateColor = [self.calendarView.delegate calendarView:self.calendarView dateColorForDate:date];
    }
    
    // if the delegate doesn't return a date color, fall back to some sane defaults,
    // which can still be overridden in subclasses
    if (! dateColor)
    {
        switch (button.type)
        {
            case CalendarButtonTypeNormalDay:
                if ([button isForToday]) {
                    dateColor = [self todayTextColor];
                } else if ([button isForDay:self.calendarView.initialDate]) {
                    dateColor = [self initialDayTextColor];
                } else {
                    dateColor = self.textColor;
                }
                break;

            case CalendarButtonTypeOtherMonth:
                dateColor = [self.textColor colorWithAlphaComponent:0.5f];
                break;

            case CalendarButtonTypeSelected:
                dateColor = [self selectedTextColor];
                break;
        }
    }

    // ** DISABLED DATE COLOR **/

    // prefer the delegate disabledDate color over everything else; this will
    // always be used if the delegate returns a color (except for other month
    // buttons)
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:disabledDateColorForDate:)])
    {
        disabledDateColor = [self.calendarView.delegate calendarView:self.calendarView disabledDateColorForDate:date];
    }

    // if the delegate doesn't return a disabled date color, fall back to a sane
    // default.  Other month buttons will always get this disabled color.
    if ((! disabledDateColor) || (button.type == CalendarButtonTypeOtherMonth))
    {
        disabledDateColor = [self.textColor colorWithAlphaComponent:0.5f];
    }

    // ** DATE SHADOW COLOR **/

    // prefer the delegate date shadow color over everything else; this will
    // always be used if the delegate returns a color
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:dateShadowColorForDate:)])
    {
        dateShadowColor = [self.calendarView.delegate calendarView:self.calendarView dateShadowColorForDate:date];
    }

    if (! dateShadowColor)
    {
        switch (button.type)
        {
            case CalendarButtonTypeNormalDay:
                if ([button isForToday]) {
                    dateShadowColor = [self todayTextShadowColor];
                } else if ([button isForDay:self.calendarView.initialDate]) {
                    dateShadowColor = [self initialDayTextShadowColor];
                } else if (button.type == CalendarButtonTypeNormalDay) {
                    dateShadowColor = [self textShadowColor];
                }
                break;

            case CalendarButtonTypeOtherMonth:
                break;

            case CalendarButtonTypeSelected:
                dateShadowColor = [self selectedTextShadowColor];
                break;
        }
    }

    [button setTitleColor:dateColor forState:UIControlStateNormal];
    [button setTitleColor:disabledDateColor forState:UIControlStateDisabled];
    button.titleLabel.shadowColor = dateShadowColor;

    // ** ICON **/

    UIImage *icon = nil;
    if ([button isForToday]) {
        icon = [self todayIcon];
    }
    // can extend later to support other icons
    button.iconImageView.image = icon;
}

- (void)updateSubtitlesForButton:(TSQCalendarDayButton *)button
{
    NSDate *date = button.day;

    NSString *subtitle = nil;
    NSString *subtitleSymbol = nil;
    UIColor *subtitleColor = nil;

    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:subtitleForDate:)])
    {
        subtitle = [self.calendarView.delegate calendarView:self.calendarView subtitleForDate:date];

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
            switch (button.type)
            {
                case CalendarButtonTypeNormalDay:
                    if ([button isForToday]) {
                        subtitleColor = [self todaySubtitleTextColor];
                    } else if ([button isForDay:self.calendarView.initialDate]) {
                        subtitleColor = [self initialDaySubtitleTextColor];
                    } else {
                        subtitleColor = [self subtitleTextColor];
                    }
                    break;

                case CalendarButtonTypeOtherMonth:
                    break;

                case CalendarButtonTypeSelected:
                    subtitleColor = [self selectedSubtitleTextColor];
                    break;
            }
        }
        
        // prefer a disabled color for other month buttons, even if the delegate
        // returned a color
        if (button.type == CalendarButtonTypeOtherMonth)
        {
            subtitleColor = [self.textColor colorWithAlphaComponent:0.5f];
        }

        if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:subtitleTrailingSymbolForDate:)])
        {
            subtitleSymbol = [self.calendarView.delegate calendarView:self.calendarView subtitleTrailingSymbolForDate:date];
        }
    }

    button.subtitleLabel.text = subtitle;
    button.subtitleSymbolLabel.text = subtitleSymbol;
    button.subtitleLabel.textColor = subtitleColor;
    button.subtitleSymbolLabel.textColor = subtitleColor;
}

- (void)setBeginningDate:(NSDate *)date;
{
    _beginningDate = date;
    
    if (!self.dayButtons) {
        [self createDayButtons];
        [self createNotThisMonthButtons];
        [self createSelectedButton];
    }

    NSDateComponents *offset = [NSDateComponents new];
    offset.day = 1;

    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        NSString *title = [self.dayFormatter stringFromDate:date];
        NSString *accessibilityLabel = [self.accessibilityFormatter stringFromDate:date];
        
        TSQCalendarDayButton *currentDayButton = self.dayButtons[index];
        TSQCalendarDayButton *currentNotThisMonthButton = self.notThisMonthButtons[index];
        currentDayButton.day = date;
        currentNotThisMonthButton.day = date;
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
            
            UIButton *button = self.dayButtons[index];
            button.enabled = buttonEnabled;
            button.hidden = NO;
        }

        // update background image
        UIImage *backgroundImage = nil;
        if ([currentDayButton isForDay:self.calendarView.initialDate]) {
            backgroundImage = [self initialDayBackgroundImage];
        } else if ([currentDayButton isForToday]) {
            backgroundImage = [self todayBackgroundImage];
        }
        [currentDayButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];

        // update button colors
        [self updateColorsForButton:currentDayButton];
        [self updateColorsForButton:currentNotThisMonthButton];

        // update button subtitles
        [self updateSubtitlesForButton:currentDayButton];
        [self updateSubtitlesForButton:currentNotThisMonthButton];

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
        // update selected button colors
        TSQCalendarDayButton *dayButton = self.dayButtons[newIndexOfSelectedButton];
        self.selectedButton.day = dayButton.day;
        [self updateColorsForButton:self.selectedButton];
        [self updateSubtitlesForButton:self.selectedButton];

        // update selected button text
        self.selectedButton.hidden = NO;
        self.selectedButton.enabled = YES;
		NSString *newTitle = [dayButton currentTitle];
		[self.selectedButton setTitle:newTitle forState:UIControlStateNormal];
		[self.selectedButton setTitle:newTitle forState:UIControlStateDisabled];
        [self.selectedButton setAccessibilityLabel:[dayButton accessibilityLabel]];
        self.selectedButton.subtitleLabel.text = dayButton.subtitleLabel.text;
        self.selectedButton.subtitleSymbolLabel.text = dayButton.subtitleSymbolLabel.text;
    } else {
        self.selectedButton.hidden = YES;
        self.selectedButton.enabled = NO;
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

@end
