//
//  EmoticonCell.m
//  Gather
//
//  Created by Madimo on 6/26/14.
//  Copyright (c) 2014 Madimo. All rights reserved.
//

#import "EmoticonCell.h"
#import "Emoticon.h"

@interface EmoticonCell ()

@end

@implementation EmoticonCell

- (void)setEmoticon:(Emoticon *)emoticon
{
    _emoticon = emoticon;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [[UIColor whiteColor] setFill];
    [path fill];
    [self.emoticon.emoticon drawInRect:rect];
}

@end
