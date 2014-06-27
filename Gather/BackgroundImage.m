//
//  BackgroundImage.m
//  Gather
//
//  Created by Madimo on 14-6-2.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "BackgroundImage.h"

@implementation BackgroundImage

@synthesize image = _image;

- (UIImage *)image
{
    if (!_image) {
        NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *path = [directory stringByAppendingPathComponent:@"bg.x"];
        UIImage *bg = [UIImage imageWithContentsOfFile:path];
        if (bg) {
            _image = bg;
        } else {
            [self setImage:[UIImage imageNamed:@"DefaultBackground"]];
        }
    }
    return _image;
}

- (void)setImage:(UIImage *)image
{
    UIImage *blur = [image applyBlurWithRadius:30.0
                                     tintColor:[UIColor colorWithWhite:0.2 alpha:0.3]
                         saturationDeltaFactor:1.0
                                     maskImage:nil];
    
    NSData *data = UIImagePNGRepresentation(blur);
    data = !data ? UIImageJPEGRepresentation(blur, 1) : data;
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [directory stringByAppendingPathComponent:@"bg.x"];
    //[data writeToFile:path atomically:YES];
    
    _image = blur;
}

#pragma mark - Singleton

+ (instancetype)sharedImage
{
    static BackgroundImage *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[super allocWithZone:NULL] init];
    });
    return sharedObject;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedImage];
}


@end
