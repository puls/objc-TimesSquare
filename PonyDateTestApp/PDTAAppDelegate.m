//
//  PDTAAppDelegate.m
//  PonyDateTestApp
//
//  Created by Jim Puls on 12/5/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "PDTAAppDelegate.h"
#import "PDTAViewController.h"

@implementation PDTAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PDTAViewController *gregorian = [[PDTAViewController alloc] init];
    gregorian.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    PDTAViewController *hebrew = [[PDTAViewController alloc] init];
    hebrew.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSHebrewCalendar];
    PDTAViewController *islamic = [[PDTAViewController alloc] init];
    islamic.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSIslamicCalendar];
    PDTAViewController *indian = [[PDTAViewController alloc] init];
    indian.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSIndianCalendar];
    PDTAViewController *persian = [[PDTAViewController alloc] init];
    persian.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSPersianCalendar];

    UITabBarController *tabController = [[UITabBarController alloc] init];
    tabController.viewControllers = @[gregorian, hebrew, islamic, indian, persian];
    self.window.rootViewController = tabController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

@end
