//
//  TriangleView.m
//  Gather
//
//  Created by Madimo on 14-5-27.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "TriangleView.h"

@implementation TriangleView

- (void)awakeFromNib
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect))];
    [path addLineToPoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect))];
    [path closePath];
    [[UIColor whiteColor] setFill];
    [path fill];
}

@end
