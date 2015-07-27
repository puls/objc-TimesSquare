//
//  TSQCalendarDayButton.m
//  TimesSquare
//
//  Created by Loretta Chan on 7/23/15.
//  Copyright (c) 2015 Square. All rights reserved.
//

#import "TSQCalendarDayButton.h"

@implementation TSQCalendarDayButton


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.secondTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 85, 18)];
        self.secondTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.secondTitleLabel.userInteractionEnabled = NO;
        self.secondTitleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.secondTitleLabel];
    }
    return self;
}
@end
