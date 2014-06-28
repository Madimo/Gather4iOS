//
//  ThemeManager.h
//  Gather
//
//  Created by Madimo on 14-6-2.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeManager : NSObject

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic, readonly) UIImage *blurImage;
@property (nonatomic) CGFloat blurRadius;
@property (nonatomic) CGFloat saturation;

@property (strong, nonatomic, readonly) UIImage *defaultImage;
@property (nonatomic, readonly) CGFloat defaultBlurRadius;
@property (nonatomic, readonly) CGFloat defaultSaturation;

+ (instancetype)manager;

- (void)initTheme;
- (void)applyAndUpdate;

@end
