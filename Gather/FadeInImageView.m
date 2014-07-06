//
//  FadeInImageView.m
//  Gather
//
//  Created by Madimo on 14-6-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "FadeInImageView.h"

@implementation FadeInImageView

- (void)setImage:(UIImage *)image
{
    if (!self.image) {
        self.alpha = 0.0;
        [super setImage:image];
        
        [UIView beginAnimations:nil context:nil];
        self.alpha = 1.0;
        [UIView commitAnimations];
    } else {
        [super setImage:image];
    }
}

@end
