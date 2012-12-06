//
//  PDTAViewController.m
//  PonyDate
//
//  Created by Jim Puls on 12/5/12.
//  Copyright (c) 2012 Square. All rights reserved.
//

#import "PDTAViewController.h"
#import "PDTACalendarRowCell.h"
#import "PonyDate.h"


@interface PDTAViewController ()

@property (nonatomic, retain) NSTimer *timer;

@end


@interface PDCalendarView (AccessingPrivateStuff)

@property (nonatomic, readonly) UITableView *tableView;

@end


@implementation PDTAViewController

- (void)loadView;
{
    PDCalendarView *calendarView = [[PDCalendarView alloc] init];
    calendarView.calendar = self.calendar;
    calendarView.rowCellClass = [PDTACalendarRowCell class];
    calendarView.firstDate = [NSDate date];
    calendarView.lastDate = [NSDate dateWithTimeIntervalSinceNow:60 * 60 * 24 * 365 * 5];
    calendarView.backgroundColor = [UIColor colorWithRed:0.84f green:0.85f blue:0.86f alpha:1.0f];

    self.view = calendarView;
}

- (void)setCalendar:(NSCalendar *)calendar;
{
    _calendar = calendar;
    
    self.navigationItem.title = calendar.calendarIdentifier;
    self.tabBarItem.title = calendar.calendarIdentifier;
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
    PDCalendarView *calendarView = (PDCalendarView *)self.view;
    UITableView *tableView = calendarView.tableView;
    
    [tableView setContentOffset:CGPointMake(0.f, atTop ? 10000.f : 0.f) animated:YES];
    atTop = !atTop;
}

@end
