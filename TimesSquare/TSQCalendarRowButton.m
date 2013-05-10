//
//  TSQCalendarButton.m
//  TimesSquare
//
//  Created by Simon Booth on 10/05/2013.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarRowButton.h"


@implementation TSQCalendarRowButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:19.f];
        self.adjustsImageWhenDisabled = NO;
        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        _subtitleLabel = [[UILabel alloc] init];
        _subtitleLabel.backgroundColor = [UIColor clearColor];
        _subtitleLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:_subtitleLabel];
        
        [self updateSubtitleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect subtitleFrame = self.bounds;
    subtitleFrame.origin.y = subtitleFrame.size.height - 15;
    subtitleFrame.size.height = 15;
    self.subtitleLabel.frame = subtitleFrame;
}

- (void)updateSubtitleLabel
{
    self.subtitleLabel.font = self.titleLabel.font;
    self.subtitleLabel.textColor = self.currentTitleColor;
    self.subtitleLabel.shadowColor = self.currentTitleShadowColor;
    self.subtitleLabel.shadowOffset = self.titleLabel.shadowOffset;
}

- (void)setTitleShadowColor:(UIColor *)color forState:(UIControlState)state
{
    [super setTitleShadowColor:color forState:state];
    [self updateSubtitleLabel];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [super setTitleColor:color forState:state];
    [self updateSubtitleLabel];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self updateSubtitleLabel];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self updateSubtitleLabel];
}

@end
