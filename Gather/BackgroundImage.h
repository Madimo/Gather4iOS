//
//  BackgroundImage.h
//  Gather
//
//  Created by Madimo on 14-6-2.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BackgroundImage : NSObject

@property (strong, nonatomic) UIImage *image;

+ (instancetype)sharedImage;

@end
