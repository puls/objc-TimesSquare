//
//  TSQTAAppDelegate.m
//  TimesSquareTestApp
//
//  Created by Jim Puls on 12/5/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQTAAppDelegate.h"
#import "TSQTAViewController.h"

@implementation TSQTAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    TSQTAViewController *gregorian = [[TSQTAViewController alloc] init];
    gregorian.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    gregorian.calendar.locale = [NSLocale currentLocale];
    
    TSQTAViewController *hebrew = [[TSQTAViewController alloc] init];
    hebrew.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSHebrewCalendar];
    hebrew.calendar.locale = [NSLocale currentLocale];

    TSQTAViewController *islamic = [[TSQTAViewController alloc] init];
    islamic.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSIslamicCalendar];
    islamic.calendar.locale = [NSLocale currentLocale];
    
    TSQTAViewController *indian = [[TSQTAViewController alloc] init];
    indian.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSIndianCalendar];
    indian.calendar.locale = [NSLocale currentLocale];

    TSQTAViewController *persian = [[TSQTAViewController alloc] init];
    persian.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSPersianCalendar];
    persian.calendar.locale = [NSLocale currentLocale];

    UITabBarController *tabController = [[UITabBarController alloc] init];
    tabController.viewControllers = @[gregorian, hebrew, islamic, indian, persian];
    self.window.rootViewController = tabController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
