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
@property (nonatomic, strong) TSQCalendarMonthHeaderCell *headerView; // nil unless pinsHeaderToTop == YES

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
    
    // WORKAROUND: In iOS8, scrolling randomly doesn't work in the calendar view when dragging on enabled buttons.
    // The correct solution is to enable delaysContentTouches but this has been broken since iOS7: ( https://devforums.apple.com/thread/199755?start=0&tstart=0 ).
    // The workaround here is to set delaysTouchesBegan on the panGestureRecognizer of the table itself.
    _tableView.panGestureRecognizer.delaysTouchesBegan = YES;
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

- (void)setPinsHeaderToTop:(BOOL)pinsHeaderToTop;
{
    _pinsHeaderToTop = pinsHeaderToTop;
    [self setNeedsLayout];
}

- (void)setFirstDate:(NSDate *)firstDate;
{
    // clamp to the beginning of its month
    _firstDate = [self clampDate:firstDate toComponents:NSMonthCalendarUnit|NSYearCalendarUnit];
}

- (void)setLastDate:(NSDate *)lastDate;
{
    // clamp to the end of its month
    NSDate *firstOfMonth = [self clampDate:lastDate toComponents:NSMonthCalendarUnit|NSYearCalendarUnit];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.month = 1;
    offsetComponents.day = -1;
    _lastDate = [self.calendar dateByAddingComponents:offsetComponents toDate:firstOfMonth options:0];
}

- (void)setSelectedDate:(NSDate *)newSelectedDate;
{
    // clamp to beginning of its day
    NSDate *startOfDay = [self clampDate:newSelectedDate toComponents:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit];
    
    if ([self.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)] && ![self.delegate calendarView:self shouldSelectDate:startOfDay]) {
        return;
    }
    
    [[self cellForRowAtDate:_selectedDate] selectColumnForDate:nil];
    [[self cellForRowAtDate:startOfDay] selectColumnForDate:startOfDay];
    NSIndexPath *newIndexPath = [self indexPathForRowAtDate:startOfDay];
    CGRect newIndexPathRect = [self.tableView rectForRowAtIndexPath:newIndexPath];
    CGRect scrollBounds = self.tableView.bounds;
    
    if (self.pagingEnabled) {
        CGRect sectionRect = [self.tableView rectForSection:newIndexPath.section];
        [self.tableView setContentOffset:sectionRect.origin animated:YES];
    } else {
        if (CGRectGetMinY(scrollBounds) > CGRectGetMinY(newIndexPathRect)) {
            [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
        } else if (CGRectGetMaxY(scrollBounds) < CGRectGetMaxY(newIndexPathRect)) {
            [self.tableView scrollToRowAtIndexPath:newIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
    
    _selectedDate = startOfDay;
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.delegate calendarView:self didSelectDate:startOfDay];
    }
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
  NSInteger section = [self sectionForDate:date];
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

- (TSQCalendarMonthHeaderCell *)makeHeaderCellWithIdentifier:(NSString *)identifier;
{
    TSQCalendarMonthHeaderCell *cell = [[[self headerCellClass] alloc] initWithCalendar:self.calendar reuseIdentifier:identifier];
    cell.backgroundColor = self.backgroundColor;
    cell.calendarView = self;
    return cell;
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

- (NSInteger)sectionForDate:(NSDate *)date;
{
  return [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDate toDate:date options:0].month;
}

- (NSIndexPath *)indexPathForRowAtDate:(NSDate *)date;
{
    if (!date) {
        return nil;
    }
    
    NSInteger section = [self sectionForDate:date];
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    
    NSInteger firstWeek = [self.calendar components:NSWeekOfMonthCalendarUnit fromDate:firstOfMonth].weekOfMonth;
    NSInteger targetWeek = [self.calendar components:NSWeekOfMonthCalendarUnit fromDate:date].weekOfMonth;
    
    return [NSIndexPath indexPathForRow:targetWeek - firstWeek inSection:section];
}

#pragma mark UIView

- (void)layoutSubviews;
{
    if (self.pinsHeaderToTop) {
        if (!self.headerView) {
            self.headerView = [self makeHeaderCellWithIdentifier:nil];
            if (self.tableView.visibleCells.count > 0) {
                self.headerView.firstOfMonth = [self.tableView.visibleCells[0] firstOfMonth];
            } else {
                self.headerView.firstOfMonth = self.firstDate;
            }
            [self addSubview:self.headerView];
        }
        CGRect bounds = self.bounds;
        CGRect headerRect;
        CGRect tableRect;
        CGRectDivide(bounds, &headerRect, &tableRect, [[self headerCellClass] cellHeight], CGRectMinYEdge);
        self.headerView.frame = headerRect;
        self.tableView.frame = tableRect;
    } else {
        if (self.headerView) {
            [self.headerView removeFromSuperview];
            self.headerView = nil;
        }
        self.tableView.frame = self.bounds;
    }
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1 + [self.calendar components:NSMonthCalendarUnit fromDate:self.firstDate toDate:self.lastDate options:0].month;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    NSRange rangeOfWeeks = [self.calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:firstOfMonth];
    return rangeOfWeeks.length;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *identifier = @"row";
    TSQCalendarRowCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[[self rowCellClass] alloc] initWithCalendar:self.calendar reuseIdentifier:identifier];
        cell.backgroundColor = self.backgroundColor;
        cell.calendarView = self;
    }
    return cell;
}

#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    [(TSQCalendarCell *)cell setFirstOfMonth:firstOfMonth];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSDayCalendarUnit inUnit:NSWeekCalendarUnit forDate:firstOfMonth];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = 1 - ordinalityOfFirstDay;
    dateComponents.week = indexPath.row;
    [(TSQCalendarRowCell *)cell setBeginningDate:[self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0]];
    [(TSQCalendarRowCell *)cell selectColumnForDate:self.selectedDate];
    
    BOOL isBottomRow = indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1;
    [(TSQCalendarRowCell *)cell setBottomRow:isBottomRow];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return [[self rowCellClass] cellHeight];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (self.pinsHeaderToTop) {
        return 0;
    }
    return [[self headerCellClass] cellHeight];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.pinsHeaderToTop) {
        return nil;
    }
    
    static NSString *identifier = @"header";
    TSQCalendarMonthHeaderCell *cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!cell) {
        cell = [self makeHeaderCellWithIdentifier:identifier];
        cell.firstOfMonth = [self firstOfMonthForSection:section];
    }
    return cell;
}


#pragma mark UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
{
    if (self.pagingEnabled) {
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:*targetContentOffset];
        // If the target offset is at the third row or later, target the next month; otherwise, target the beginning of this month.
        NSInteger section = indexPath.section;
        if (indexPath.row > 2) {
            section++;
        }
        CGRect sectionRect = [self.tableView rectForSection:section];
        *targetContentOffset = sectionRect.origin;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    if (self.pinsHeaderToTop && self.tableView.visibleCells.count > 0) {
        TSQCalendarCell *cell = self.tableView.visibleCells[0];
        self.headerView.firstOfMonth = cell.firstOfMonth;
    }
}

- (NSDate *)clampDate:(NSDate *)date toComponents:(NSUInteger)unitFlags
{
    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

@end
