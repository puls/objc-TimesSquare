//
//  TSQTAViewController.m
//  TimesSquare
//
//  Created by Jim Puls on 12/5/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQTAViewController.h"
#import "TSQTACalendarRowCell.h"
#import <TimesSquare/TimesSquare.h>


@interface TSQTAViewController () <TSQCalendarViewDelegate>

@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, strong) NSDate *firstDateInCurrentMonth;
@property (nonatomic, strong) NSDate *lastDateInCurrentMonth;
@property (nonatomic, strong) TSQCalendarView *calendarView;

@end


@interface TSQCalendarView (AccessingPrivateStuff)

@property (nonatomic, readonly) UITableView *tableView;

@end


@implementation TSQTAViewController

- (void)loadView;
{
    self.firstDateInCurrentMonth = [self firstDateInMonthOfReferenceDate:[NSDate date]];
    self.lastDateInCurrentMonth = [self lastDateInMonthOfReferenceDate:[NSDate date]];
    
    self.calendarView = [[TSQCalendarView alloc] init];
    self.calendarView.calendar = self.calendar;
    self.calendarView.rowCellClass = [TSQTACalendarRowCell class];
    self.calendarView.firstDate = self.firstDateInCurrentMonth;
//    self.calendarView.lastDate = self.lastDateInCurrentMonth;
    self.calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];
    self.calendarView.pagingEnabled = YES;
    self.calendarView.selectionMode = self.multipleSelection ? TSQSelectionModeMultiple : TSQSelectionModeSingle;
    self.calendarView.delegate = self;
    CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
    self.calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);

    UIBarButtonItem *selectAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllButtonWasTapped:)];
    self.navigationItem.rightBarButtonItem = selectAllButton;
    UIBarButtonItem *clearAllButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear All" style:UIBarButtonItemStyleBordered target:self action:@selector(clearAllButtonWasTapped:)];
    self.navigationItem.leftBarButtonItem = clearAllButton;
    
    self.view = self.calendarView;
}

- (NSDate *)firstDateInMonthOfReferenceDate:(NSDate *)date
{
    NSDateComponents *dateComponents = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    return [self.calendar dateFromComponents:dateComponents];
}


- (NSDate *)lastDateInMonthOfReferenceDate:(NSDate *)date
{
    NSDateComponents *dateComponents = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    
    // set last of month
    dateComponents.month += 1;
    dateComponents.day = 0;
    
    return [self.calendar dateFromComponents:dateComponents];
}

- (void)selectAllButtonWasTapped:(UIBarButtonItem *)sender
{
    static NSDateComponents *oneDay;
    if (oneDay == nil) {
        oneDay = [NSDateComponents new];
        oneDay.day = 1;
    }
    
    NSMutableArray *tmp = [@[] mutableCopy];
    NSDate *date = self.firstDateInCurrentMonth;
    while ([date compare:self.lastDateInCurrentMonth] != NSOrderedDescending) {
        [tmp addObject:date];
        date = [self.calendar dateByAddingComponents:oneDay toDate:date options:0];
    }
    self.calendarView.selectedDates = tmp;
}

- (void)clearAllButtonWasTapped:(UIBarButtonItem *)sender
{
    self.calendarView.selectedDates = nil;
}

- (void)setCalendar:(NSCalendar *)calendar;
{
    _calendar = calendar;
    
    self.navigationItem.title = calendar.calendarIdentifier;
    self.tabBarItem.title = calendar.calendarIdentifier;
}

- (void)viewDidLayoutSubviews;
{
  // Set the calendar view to show today date on start
  [(TSQCalendarView *)self.view scrollToDate:[NSDate date] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated;
{
    [super viewDidAppear:animated];
    
    // Uncomment this to test scrolling performance of your custom drawing
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(scroll) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated;
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)scroll;
{
    static BOOL atTop = YES;
    TSQCalendarView *calendarView = (TSQCalendarView *)self.view;
    UITableView *tableView = calendarView.tableView;
    
    [tableView setContentOffset:CGPointMake(0.f, atTop ? 10000.f : 0.f) animated:YES];
    atTop = !atTop;
}


# pragma mark -
# pragma mark TSQCalendarViewDelegate

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    NSLog(@"Did Select Date: %@", date);
}


- (void)calendarView:(TSQCalendarView *)calendarView didSelectDates:(NSArray *)dates
{
    NSLog(@"Did Select Dates: %@", dates);
}


- (BOOL)calendarView:(TSQCalendarView *)calendarView shouldSelectDate:(NSDate *)date
{
    return YES;
}

@end
