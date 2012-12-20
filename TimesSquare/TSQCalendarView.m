//
//  TSQCalendarState.m
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarView.h"
#import "TSQCalendarMonthHeaderCell.h"
#import "TSQCalendarRowCell.h"

@interface TSQCalendarView () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end


@implementation TSQCalendarView

- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    if (!self) {
        return nil;
    }

    [self _TSQCalendarView_commonInit];

    return self;
}

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }

    [self _TSQCalendarView_commonInit];
    
    return self;
}

- (void)_TSQCalendarView_commonInit;
{
    _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:_tableView];    
}

- (void)dealloc;
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (NSCalendar *)calendar;
{
    if (!_calendar) {
        self.calendar = [NSCalendar currentCalendar];
    }
    return _calendar;
}

- (Class)headerCellClass;
{
    if (!_headerCellClass) {
        self.headerCellClass = [TSQCalendarMonthHeaderCell class];
    }
    return _headerCellClass;
}

- (Class)rowCellClass;
{
    if (!_rowCellClass) {
        self.rowCellClass = [TSQCalendarRowCell class];
    }
    return _rowCellClass;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor;
{
    [super setBackgroundColor:backgroundColor];
    [self.tableView setBackgroundColor:backgroundColor];
}

- (void)setFirstDate:(NSDate *)firstDate;
{
    // clamp to the beginning of its month
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:firstDate];
    _firstDate = [self.calendar dateFromComponents:components];
}

- (void)setLastDate:(NSDate *)lastDate;
{
    // clamp to the end of its month
    NSDateComponents *components = [self.calendar components:NSMonthCalendarUnit|NSYearCalendarUnit fromDate:lastDate];
    NSDate *firstOfMonth = [self.calendar dateFromComponents:components];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.month = 1;
    offsetComponents.day = -1;
    _lastDate = [self.calendar dateByAddingComponents:offsetComponents toDate:firstOfMonth options:0];
}

- (void)setSelectedDate:(NSDate *)newSelectedDate;
{
    if ([self.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)] && ![self.delegate calendarView:self shouldSelectDate:newSelectedDate]) {
        return;
    }
    
    [[self cellForRowAtDate:_selectedDate] selectColumnForDate:nil];
    [[self cellForRowAtDate:newSelectedDate] selectColumnForDate:newSelectedDate];
    NSIndexPath *newIndexPath = [self indexPathForRowAtDate:newSelectedDate];
    CGRect newIndexPathRect = [self.tableView rectForRowAtIndexPath:newIndexPath];
    CGRect scrollBounds = self.tableView.bounds;
    if (CGRectGetMinY(scrollBounds) > CGRectGetMinY(newIndexPathRect)) {
        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    } else if (CGRectGetMaxY(scrollBounds) < CGRectGetMaxY(newIndexPathRect)) {
        [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    _selectedDate = newSelectedDate;
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.delegate calendarView:self didSelectDate:newSelectedDate];
    }
}

#pragma mark Calendar calculations

- (NSDate *)firstOfMonthForSection:(NSInteger)section;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = section;
    return [self.calendar dateByAddingComponents:offset toDate:self.firstDate options:0];
}

- (TSQCalendarRowCell *)cellForRowAtDate:(NSDate *)date;
{
    return (TSQCalendarRowCell *)[self.tableView cellForRowAtIndexPath:[self indexPathForRowAtDate:date]];
}

- (NSIndexPath *)indexPathForRowAtDate:(NSDate *)date;
{
    if (!date) {
        return nil;
    }

    NSInteger section = [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDate toDate:date options:0].month;
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSInteger firstWeek = [self.calendar components:NSWeekOfYearCalendarUnit fromDate:firstOfMonth].weekOfYear;
    NSInteger targetWeek = [self.calendar components:NSWeekOfYearCalendarUnit fromDate:date].weekOfYear;
    if (targetWeek < firstWeek) {
        targetWeek = [self.calendar maximumRangeOfUnit:NSWeekOfYearCalendarUnit].length;
    }
    return [NSIndexPath indexPathForRow:1 + targetWeek - firstWeek inSection:section];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1 + [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDate toDate:self.lastDate options:0].month;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSDateComponents *offset = [NSDateComponents new];
    offset.month = 1;
    offset.week = -1;
    offset.day = -1;
    NSDate *weekBeforeLastOfMonth = [self.calendar dateByAddingComponents:offset toDate:firstOfMonth options:0];

    NSInteger firstWeek = [self.calendar components:NSWeekOfYearCalendarUnit fromDate:firstOfMonth].weekOfYear;
    NSInteger nextToLastWeek = [self.calendar components:NSWeekOfYearCalendarUnit fromDate:weekBeforeLastOfMonth].weekOfYear;

    // Work around the fact that the last week of the year inexplicably comes up as the first week of next year instead
    return 3 + nextToLastWeek - firstWeek;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if (indexPath.row == 0) {
        // month header
        static NSString *identifier = @"header";
        TSQCalendarMonthHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[self headerCellClass] alloc] initWithCalendar:self.calendar reuseIdentifier:identifier];
            cell.backgroundColor = self.backgroundColor;
            cell.calendarView = self;
        }
        return cell;
    } else {
        static NSString *identifier = @"row";
        TSQCalendarRowCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[[self rowCellClass] alloc] initWithCalendar:self.calendar reuseIdentifier:identifier];
            cell.backgroundColor = self.backgroundColor;
            cell.calendarView = self;
        }
        return cell;
    }
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    [(TSQCalendarCell *)cell setFirstOfMonth:firstOfMonth];
    if (indexPath.row > 0) {
        NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
        NSDateComponents *dateComponents = [NSDateComponents new];
        dateComponents.day = 1 - ordinalityOfFirstDay;
        dateComponents.week = indexPath.row - 1;
        [(TSQCalendarRowCell *)cell setBeginningDate:[self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0]];
        [(TSQCalendarRowCell *)cell selectColumnForDate:self.selectedDate];
        
        BOOL isBottomRow = (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1);
        [(TSQCalendarRowCell *)cell setBottomRow:isBottomRow];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [(id)[self tableView:tableView cellForRowAtIndexPath:indexPath] cellHeight];
}

@end
