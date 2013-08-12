//
//  TSQTAViewController.h
//  TimesSquare
//
//  Created by Jim Puls on 12/5/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import <UIKit/UIKit.h>
#import <TimesSquare/TimesSquare.h>

@interface TSQTAViewController : UIViewController

@property (nonatomic, strong) NSCalendar *calendar;
@property (nonatomic, assign) TSQCalendarSelectionMode selectionMode;

@end
