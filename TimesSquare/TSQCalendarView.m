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
    _firstDate = [self clampDate:firstDate toComponents:NSCalendarUnitMonth|NSCalendarUnitYear];
}

- (void)setLastDate:(NSDate *)lastDate;
{
    // clamp to the end of its month
    NSDate *firstOfMonth = [self clampDate:lastDate toComponents:NSCalendarUnitMonth|NSCalendarUnitYear];
    
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    offsetComponents.month = 1;
    offsetComponents.day = -1;
    _lastDate = [self.calendar dateByAddingComponents:offsetComponents toDate:firstOfMonth options:0];
}

- (void)setSelectedDate:(NSDate *)newSelectedDate;
{
    // clamp to beginning of its day
    NSDate *startOfDay = [self clampDate:newSelectedDate toComponents:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear];
    
    if ([self.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)] && ![self.delegate calendarView:self shouldSelectDate:startOfDay]) {
        return;
    }
    
    [self updateSelectedDate:startOfDay isInitialDate:NO];

    _selectedDate = startOfDay;

    if (startOfDay == nil && self.initialDate != nil) {
        [self updateSelectedDate:self.initialDate isInitialDate:YES];
    }
    
    if ([self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [self.delegate calendarView:self didSelectDate:startOfDay];
    }
}

- (void)setInitialDate:(NSDate *)initialDate
{
    // clamp to beginning of its day
    NSDate *startOfDay = [self clampDate:initialDate toComponents:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear];

    if (self.selectedDate == nil) {
        // only show initial date if user hasn't already selected a date
        [self updateSelectedDate:startOfDay isInitialDate:YES];
    }

    _initialDate = startOfDay;
}

- (void)updateSelectedDate:(NSDate *)date isInitialDate:(BOOL)isInitialDate
{
    [[self cellForRowAtDate:_selectedDate] deselectColumnForDate:self.selectedDate];
    // clear existing selected cells
    [[self cellForRowAtDate:_selectedDate] selectColumnForDate:nil];
    [[self cellForRowAtDate:_initialDate] selectColumnForDate:nil];

    // update new selected cell
    TSQCalendarRowCell *dateRowCell = [self cellForRowAtDate:date];
    if (dateRowCell == nil) {
        return;
    }

    if (isInitialDate) {
        [dateRowCell selectColumnForInitialDate:date];
    } else {
        [dateRowCell selectColumnForDate:date];
    }

    NSIndexPath *newIndexPath = [self indexPathForRowAtDate:date];
    if (newIndexPath == nil) {
        return;
    }

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
}

- (BOOL)scrollEnabled
{
    return self.tableView.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    self.tableView.scrollEnabled = scrollEnabled;
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated
{
  NSInteger section = [self sectionForDate:date];
  [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] atScrollPosition:UITableViewScrollPositionTop animated:animated];
}



- (void)scrollDate:(NSDate *)date toPosition:(UITableViewScrollPosition)position animated:(BOOL)animated {
    NSIndexPath *cellPath = [self indexPathForRowAtDate:date];

    [self.tableView scrollToRowAtIndexPath:cellPath
                          atScrollPosition:position
                                  animated:animated];
}



- (TSQCalendarMonthHeaderCell *)makeHeaderCellWithIdentifier:(NSString *)identifier;
{
    TSQCalendarMonthHeaderCell *cell = [[[self headerCellClass] alloc] initWithCalendar:self.calendar reuseIdentifier:identifier];
    cell.backgroundColor = self.backgroundColor;
    cell.calendarView = self;
    return cell;
}

- (void)setShowsVerticalScrollIndicator:(BOOL)showsVerticalScrollIndicator
{
    self.tableView.showsVerticalScrollIndicator = showsVerticalScrollIndicator;
}

- (BOOL)showsVerticalScrollIndicator
{
    return self.tableView.showsVerticalScrollIndicator;
}

#pragma mark - Calendar calculations

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
  return [self.calendar components:NSCalendarUnitMonth fromDate:self.firstDate toDate:date options:0].month;
}

- (NSIndexPath *)indexPathForRowAtDate:(NSDate *)date;
{
    if (!date) {
        return nil;
    }
    
    NSInteger section = [self sectionForDate:date];
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    
    NSInteger firstWeek = [self.calendar components:NSCalendarUnitWeekOfMonth fromDate:firstOfMonth].weekOfMonth;
    NSInteger targetWeek = [self.calendar components:NSCalendarUnitWeekOfMonth fromDate:date].weekOfMonth;
    
    return [NSIndexPath indexPathForRow:targetWeek - firstWeek inSection:section];
}

#pragma mark - UIView

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

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1 + [self.calendar components:NSCalendarUnitMonth fromDate:self.firstDate toDate:self.lastDate options:0].month;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:section];
    
    // using the new calendar units, even though they are available in iOS 7.0, don't actually work for this calculation
    // on iOS 7.  So we can't use the new units here.
    NSRange rangeOfWeeks = [self.calendar rangeOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:firstOfMonth];
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

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSDate *firstOfMonth = [self firstOfMonthForSection:indexPath.section];
    [(TSQCalendarCell *)cell setFirstOfMonth:firstOfMonth];
    NSInteger ordinalityOfFirstDay = [self.calendar ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfMonth forDate:firstOfMonth];
    NSDateComponents *dateComponents = [NSDateComponents new];
    dateComponents.day = 1 - ordinalityOfFirstDay;
    dateComponents.weekOfMonth = indexPath.row;
    [(TSQCalendarRowCell *)cell setBeginningDate:[self.calendar dateByAddingComponents:dateComponents toDate:firstOfMonth options:0]];
    
    if (self.selectedDate) {
        [(TSQCalendarRowCell *)cell selectColumnForDate:self.selectedDate];
    } else if (self.initialDate) {
        [(TSQCalendarRowCell *)cell selectColumnForInitialDate:self.initialDate];
    }

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
    TSQCalendarMonthHeaderCell *cell = (TSQCalendarMonthHeaderCell *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:identifier];
    if (!cell) {
        cell = [self makeHeaderCellWithIdentifier:identifier];
        cell.firstOfMonth = [self firstOfMonthForSection:section];
    }
    return cell;
}


#pragma mark - UIScrollViewDelegate

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
    if (date == nil) {
        // [__NSCFCalendar components:fromDate:]: date cannot be nil
        return nil;
    }

    NSDateComponents *components = [self.calendar components:unitFlags fromDate:date];
    return [self.calendar dateFromComponents:components];
}

- (CGSize)contentSize
{
    return self.tableView.contentSize;
}

@end
