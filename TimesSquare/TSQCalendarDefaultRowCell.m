//
//  TSQCalendarDefaultRowCell.m
//  TimesSquare
//
//  Created by Marc Nijdam on 2/11/13.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.
//

#import "TSQCalendarDefaultRowCell.h"

@implementation TSQCalendarDefaultRowCell

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
{
    // Move down for the row at the top
    rect.origin.y += self.columnSpacing;
    rect.size.height -= (self.bottomRow ? 2.0f : 1.0f) * self.columnSpacing;
    [super layoutViewsForColumnAtIndex:index inRect:rect];
}

- (UIImage *)defaultImageNamed:(NSString *)imageName
{
    static NSBundle *bundle = nil;
    static NSCache *imageCache = nil;
    static dispatch_once_t onceToken;
    
    
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"TimesSquareResources" withExtension:@"bundle"]];
        imageCache = [[NSCache alloc] init];
    });
    
    UIImage *image = [imageCache objectForKey:@"imageName"];
    if (!image) {
        image = [UIImage imageWithContentsOfFile:[[bundle resourcePath] stringByAppendingPathComponent:imageName]];
        if (image) {
            [imageCache setObject:image forKey:imageName];
        }
    }
    return image;
}

- (UIImage *)todayBackgroundImage;
{
    return [[self defaultImageNamed:@"CalendarTodaysDate.png" ] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

- (UIImage *)selectedBackgroundImage;
{
    return [[self defaultImageNamed:@"CalendarSelectedDate.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

- (UIImage *)notThisMonthBackgroundImage;
{
    return [[self defaultImageNamed:@"CalendarPreviousMonth.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
}

- (UIImage *)backgroundImage;
{
    return [self defaultImageNamed:[NSString stringWithFormat:@"CalendarRow%@.png", self.bottomRow ? @"Bottom" : @""]];
}

@end
