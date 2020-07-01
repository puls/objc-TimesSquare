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
    [self updateAppearanceForButton:button];

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
    [button addTarget:self action:@selector(dateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    [self configureButton:button];
    [button setBackgroundImage:[self selectedBackgroundImage] forState:UIControlStateNormal];
    [button setAccessibilityTraits:UIAccessibilityTraitSelected|button.accessibilityTraits];
    button.enabled = NO;
    button.hidden = YES;
    self.indexOfSelectedButton = -1;

    self.selectedButton = button;
}

- (void)updateAppearanceForButton:(TSQCalendarDayButton *)button
{
    UIColor *dateColor = nil;
    UIColor *disabledDateColor = nil;
    UIColor *dateShadowColor = nil;

    NSDate *date = button.day;

    BOOL dateIsSelectable = YES;
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)]) {
        dateIsSelectable = [self.calendarView.delegate calendarView:self.calendarView shouldSelectDate:date];
    }

    // ** DISABLED DATE COLOR **/

    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:disabledDateColorForDate:)]) {
        // prefer the delegate disabledDate color over everything else; this will
        // always be used if the delegate returns a color (except for other month
        // buttons)
        disabledDateColor = [self.calendarView.delegate calendarView:self.calendarView disabledDateColorForDate:date];
    }

    // if the delegate doesn't return a disabled date color, fall back to a sane
    // default.  Other month buttons will always get this disabled color.
    if ((! disabledDateColor) || (button.type == CalendarButtonTypeOtherMonth))
    {
        disabledDateColor = [self.textColor colorWithAlphaComponent:0.5f];
    }

    // ** DATE COLOR **/

    // prefer the delegate date color over everything else; this will always be
    // used if the delegate returns a color
    UIColor *delegateDateColor = nil;
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:dateColorForDate:)]) {
        delegateDateColor = [self.calendarView.delegate calendarView:self.calendarView dateColorForDate:date];
    }

    UIColor *delegateSelectedDateColor = nil;
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:selectedDateColorForDate:)]) {
        delegateSelectedDateColor = [self.calendarView.delegate calendarView:self.calendarView selectedDateColorForDate:date];
    }

    // if the delegate doesn't return a date color, fall back to some sane defaults,
    // which can still be overridden in subclasses
    switch (button.type)
    {
        case CalendarButtonTypeNormalDay:
            if (delegateDateColor) {
                dateColor = delegateDateColor;
            } else if ([button isForToday]) {
                dateColor = [self todayTextColor];
            } else {
                dateColor = self.textColor;
            }
            break;

        case CalendarButtonTypeOtherMonth:
            dateColor = [self.textColor colorWithAlphaComponent:0.5f];
            break;

        case CalendarButtonTypeSelected:
            if (delegateSelectedDateColor) {
                dateColor = delegateSelectedDateColor;
            } else {
                dateColor = [self selectedTextColor];
            }
            break;

        case CalendarButtonTypeInitialDay:
            if (dateIsSelectable) {
                if (delegateDateColor) {
                    dateColor = delegateDateColor;
                } else if ([button isForToday]) {
                    dateColor = [self todayTextColor];
                } else {
                    dateColor = [self initialDayTextColor];
                }
            } else {
                dateColor = disabledDateColor;
            }
    }

    // ** DATE SHADOW COLOR **/

    // prefer the delegate date shadow color over everything else; this will
    // always be used if the delegate returns a color
    UIColor *delegateDateShadowColor = nil;
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:dateShadowColorForDate:)]) {
        delegateDateShadowColor = [self.calendarView.delegate calendarView:self.calendarView dateShadowColorForDate:date];
    }

    switch (button.type)
    {
        case CalendarButtonTypeNormalDay:
            if (delegateDateShadowColor) {
                dateShadowColor = delegateDateShadowColor;
            } else if ([button isForToday]) {
                dateShadowColor = [self todayTextShadowColor];
            } else {
                dateShadowColor = [self textShadowColor];
            }
            break;

        case CalendarButtonTypeOtherMonth:
            break;

        case CalendarButtonTypeSelected:
            dateShadowColor = [self selectedTextShadowColor];
            break;

        case CalendarButtonTypeInitialDay:
            if (dateIsSelectable) {
                if (delegateDateShadowColor) {
                    dateShadowColor = delegateDateShadowColor;
                } else if ([button isForToday]) {
                    dateShadowColor = [self todayTextShadowColor];
                } else {
                    dateShadowColor = [self initialDayTextShadowColor];
                }
            }
            break;
    }

    [button setTitleColor:dateColor forState:UIControlStateNormal];
    [button setTitleColor:disabledDateColor forState:UIControlStateDisabled];
    [button setTitleShadowColor:dateShadowColor forState:UIControlStateNormal];

    // ** ICON **/

    UIImage *icon = nil;
    UIColor *iconTintColor = nil;

    if ([button isForToday] && button.type != CalendarButtonTypeOtherMonth)
    {
        icon = [self todayIcon];

        if (button.type == CalendarButtonTypeSelected)
        {
            // when selected, tint the icon the same as selected text
            icon = [icon imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            iconTintColor = dateColor;
        }
    }
    // can extend later to support other icons
    button.iconImageView.image = icon;
    button.iconImageView.tintColor = iconTintColor;
}

- (void)updateBackgroundImageForButton:(TSQCalendarDayButton *)button isSelected:(BOOL)isSelected
{
    NSDate *date = button.day;
    
    UIImage *delegateBackgroundImage = nil;
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:backgroundImageForDate:size:isInThisMonth:isSelected:)]) {
        BOOL thisMonth = button.type != CalendarButtonTypeOtherMonth;
        
        delegateBackgroundImage = [self.calendarView.delegate calendarView:self.calendarView backgroundImageForDate:date size:button.bounds.size isInThisMonth:thisMonth isSelected:isSelected];
    }
    
   
    [button setBackgroundImage:delegateBackgroundImage forState:UIControlStateNormal];
}

- (void)updateTitleForButton:(TSQCalendarDayButton *)button
{
    NSDate *date = button.day;

    if (date == nil) {
        return;
    }

    [self updateBackgroundImageForButton:button isSelected:self.selectedButton == button];
    NSString *title = [self.dayFormatter stringFromDate:date];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateDisabled];

    // add accessibility label
    NSString *accessibilityLabel = [self.accessibilityFormatter stringFromDate:date];
    if (button.type == 1) {
        [button setAccessibilityLabel:[NSString stringWithFormat:@"%@ Disabled", accessibilityLabel]];
    } else {
        [button setAccessibilityLabel:accessibilityLabel];
    }

    // check if we should use an attributed string
    NSDictionary *additionalAttributes = nil;
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:additionalDateTextAttributesForDate:)]) {
        additionalAttributes = [self.calendarView.delegate calendarView:self.calendarView additionalDateTextAttributesForDate:date];
    }

    if (additionalAttributes) {
        // create text attributes for normal button
        NSMutableDictionary *normalAttributes = [additionalAttributes mutableCopy];

        if ([button titleColorForState:UIControlStateNormal]) {
            normalAttributes[NSForegroundColorAttributeName] = [button titleColorForState:UIControlStateNormal];
        }

        if ([button titleShadowColorForState:UIControlStateNormal]) {
            NSShadow *shadow = [NSShadow new];
            shadow.shadowOffset = button.titleLabel.shadowOffset;
            shadow.shadowColor = [button titleShadowColorForState:UIControlStateNormal];
            normalAttributes[NSShadowAttributeName] = shadow;
        }

        // update button title with normal attributes
        NSAttributedString *normalTitle = [[NSAttributedString alloc] initWithString:title attributes:normalAttributes];
        [button setAttributedTitle:normalTitle forState:UIControlStateNormal];

        // create text attributes for disabled button
        NSMutableDictionary *disabledAttributes = [normalAttributes mutableCopy];

        if ([button titleColorForState:UIControlStateDisabled]) {
            disabledAttributes[NSForegroundColorAttributeName] = [button titleColorForState:UIControlStateDisabled];
        }

        if ([button titleShadowColorForState:UIControlStateDisabled]) {
            NSShadow *shadow = [NSShadow new];
            shadow.shadowOffset = button.titleLabel.shadowOffset;
            shadow.shadowColor = [button titleShadowColorForState:UIControlStateDisabled];
            disabledAttributes[NSShadowAttributeName] = shadow;
        }

        // update button title with normal attributes
        NSAttributedString *disabledTitle = [[NSAttributedString alloc] initWithString:title attributes:disabledAttributes];
        [button setAttributedTitle:disabledTitle forState:UIControlStateDisabled];
    }
}

- (void)updateSubtitlesForButton:(TSQCalendarDayButton *)button
{
    NSDate *date = button.day;

    NSString *subtitle = nil;
    NSString *subtitleSymbol = nil;
    UIColor *subtitleColor = nil;

    BOOL dateIsSelectable = YES;
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)]) {
        dateIsSelectable = [self.calendarView.delegate calendarView:self.calendarView shouldSelectDate:date];
    }

    // ** DISABLED DATE COLOR **/
    UIColor *disabledDateColor = nil;
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:disabledDateColorForDate:)]) {
        // prefer the delegate disabledDate color over everything else; this will
        // always be used if the delegate returns a color (except for other month
        // buttons)
        disabledDateColor = [self.calendarView.delegate calendarView:self.calendarView disabledDateColorForDate:date];
    }

    // if the delegate doesn't return a disabled date color, fall back to a sane
    // default.  Other month buttons will always get this disabled color.
    if ((! disabledDateColor) || (button.type == CalendarButtonTypeOtherMonth))
    {
        disabledDateColor = [self.textColor colorWithAlphaComponent:0.5f];
    }
    
    if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:subtitleForDate:)])
    {
        subtitle = [self.calendarView.delegate calendarView:self.calendarView subtitleForDate:date];

        // only check the color if the delegate also responds to the subtitle
        // delegate method.  Prefer this subtitle color returned by the delegate,
        // except for other month buttons.
        UIColor *delegateSubtitleColor = nil;
        if ([self.calendarView.delegate respondsToSelector:@selector(calendarView:subtitleColorForDate:)]) {
            delegateSubtitleColor = [self.calendarView.delegate calendarView:self.calendarView subtitleColorForDate:date];
        }

        switch (button.type)
        {
            case CalendarButtonTypeNormalDay:
                if (delegateSubtitleColor) {
                    subtitleColor = delegateSubtitleColor;
                } else if ([button isForToday]) {
                    subtitleColor = [self todaySubtitleTextColor];
                } else {
                    subtitleColor = [self subtitleTextColor];
                }
                break;

            case CalendarButtonTypeOtherMonth:
                // prefer a disabled color for other month buttons, even if the delegate
                // returned a color
                subtitleColor = disabledDateColor;
                break;

            case CalendarButtonTypeSelected:
                subtitleColor = [self selectedSubtitleTextColor];
                break;

            case CalendarButtonTypeInitialDay:
                if (dateIsSelectable) {
                    if (delegateSubtitleColor) {
                        subtitleColor = delegateSubtitleColor;
                    } else if ([button isForToday]) {
                        subtitleColor = [self todaySubtitleTextColor];
                    } else {
                        subtitleColor = [self initialDaySubtitleTextColor];
                    }
                } else {
                    subtitleColor = disabledDateColor;
                }
                break;
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

        TSQCalendarDayButton *currentDayButton = self.dayButtons[index];
        TSQCalendarDayButton *currentNotThisMonthButton = self.notThisMonthButtons[index];
        currentDayButton.day = date;
        currentNotThisMonthButton.day = date;

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

        // update button appearance
        [self updateAppearanceForButton:currentDayButton];
        [self updateAppearanceForButton:currentNotThisMonthButton];

        // update button title
        [self updateTitleForButton:currentDayButton];
        [self updateTitleForButton:currentNotThisMonthButton];

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
    TSQCalendarDayButton *dayButton = (TSQCalendarDayButton *)sender;
    NSDate *selectedDate = dayButton.day;
    self.calendarView.selectedDate = selectedDate;
    [self updateBackgroundImageForButton:dayButton isSelected:YES];
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
    // find buttons that we need to update the frame
    NSMutableArray<TSQCalendarDayButton *> *buttons = [NSMutableArray new];
    if (index < self.dayButtons.count) {
        [buttons addObject:self.dayButtons[index]];
    }
    if (index < self.notThisMonthButtons.count) {
        [buttons addObject:self.notThisMonthButtons[index]];
    }
    if (self.indexOfSelectedButton == (NSInteger)index) {
        [buttons addObject:self.selectedButton];
    }

    for (TSQCalendarDayButton *button in buttons) {
        if (CGRectEqualToRect(button.frame, rect) == NO) {
            button.frame = rect;
            // image views are dependant on button size so they need to be regenerated
            [self updateBackgroundImageForButton:button isSelected:[self.calendarView.selectedDate isEqualToDate:button.day]];
        }
    }
}

- (void)selectColumnForDate:(NSDate *)date;
{
    [self selectColumnForDate:date isInitialDay:NO];
}

- (void)deselectColumnForDate:(NSDate *)date
{
    for (TSQCalendarDayButton *button in self.dayButtons) {
        if ([button.day isEqualToDate:date])
        {
            [self updateBackgroundImageForButton:button isSelected:NO];
            break; 
        }
    }
}

- (void)selectColumnForInitialDate:(NSDate *)date
{
    [self selectColumnForDate:date isInitialDay:YES];
}

- (void)selectColumnForDate:(NSDate *)date isInitialDay:(BOOL)isInitialDay
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
        self.selectedButton.type = isInitialDay ? CalendarButtonTypeInitialDay : CalendarButtonTypeSelected;
        self.selectedButton.enabled = isInitialDay;
        self.selectedButton.isInitialDay = isInitialDay;
        [self updateAppearanceForButton:self.selectedButton];
        [self updateSubtitlesForButton:self.selectedButton];

        // update background image
        [self updateBackgroundImageForButton:self.selectedButton isSelected:NO];

        // update selected button text
        self.selectedButton.hidden = NO;
        self.selectedButton.enabled = YES;
        [self updateTitleForButton:self.selectedButton];
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
