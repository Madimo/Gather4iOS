//
//  ThemeManager.m
//  Gather
//
//  Created by Madimo on 14-6-2.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "ThemeManager.h"

#define UD_KEY_BLUR_RADIUS @"UD_KEY_BLUR_RADIUS"
#define UD_KEY_SATURATION @"UD_KEY_SATURATION"

@interface ThemeManager () {
    NSNumber *_blurRadius;
    NSNumber *_saturation;
}

@property (strong, nonatomic) UIImage *blurImage;
@property (strong, nonatomic) UIWindow *themeWindow;
@property (strong, nonatomic) UIImageView *backgroundImageView;
@end

@implementation ThemeManager

@synthesize image = _image;

- (UIImage *)image
{
    if (!_image) {
        NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *path = [directory stringByAppendingPathComponent:@"bg.ga"];
        UIImage *bg = [UIImage imageWithContentsOfFile:path];
        if (bg) {
            _image = bg;
        } else {
            [self setImage:self.defaultImage];
        }
    }
    
    return _image;
}

- (void)setImage:(UIImage *)image
{
    NSData *data = UIImagePNGRepresentation(image);
    data = !data ? UIImageJPEGRepresentation(image, 1) : data;
    NSString *directory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *path = [directory stringByAppendingPathComponent:@"bg.ga"];
    [data writeToFile:path atomically:YES];
    
    _image = image;
}

- (CGFloat)blurRadius
{
    if (!_blurRadius) {
        _blurRadius = [[NSUserDefaults standardUserDefaults] objectForKey:UD_KEY_BLUR_RADIUS];
    }
    if (!_blurRadius) {
        self.blurRadius = self.defaultBlurRadius;
    }
    
    return _blurRadius.floatValue;
}

- (void)setBlurRadius:(CGFloat)blurRadius
{
    _blurRadius = @(blurRadius);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_blurRadius forKey:UD_KEY_BLUR_RADIUS];
    [defaults synchronize];
}

- (CGFloat)saturation
{
    if (!_saturation) {
        _saturation = [[NSUserDefaults standardUserDefaults] objectForKey:UD_KEY_SATURATION];
    }
    if (!_saturation) {
        self.saturation = self.defaultSaturation;
    }
    
    return _saturation.floatValue;
}

- (void)setSaturation:(CGFloat)saturation
{
    _saturation = @(saturation);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_saturation forKey:UD_KEY_SATURATION];
    [defaults synchronize];
}

- (UIImage *)blurImage
{
    if (!_blurImage) {
        [self refreshBlurImage];
    }
    return _blurImage;
}

- (void)refreshBlurImage
{
    self.blurImage = [self.image applyBlurWithRadius:self.blurRadius
                                           tintColor:[UIColor colorWithWhite:0.2 alpha:0.3]
                               saturationDeltaFactor:self.saturation
                                           maskImage:nil];
}

- (void)applyAndUpdate
{
    [self refreshBlurImage];
    self.backgroundImageView.image = self.blurImage;
}

- (void)initTheme
{
    self.themeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.themeWindow.bounds];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.image = self.blurImage;
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view = self.backgroundImageView;
    self.themeWindow.rootViewController = vc;
    self.themeWindow.windowLevel = UIWindowLevelNormal - 1;
    [self.themeWindow makeKeyAndVisible];
}

#pragma mark - Default value

- (UIImage *)defaultImage
{
    return [UIImage imageNamed:@"DefaultBackground"];
}

- (CGFloat)defaultBlurRadius
{
    return 30.0;
}

- (CGFloat)defaultSaturation
{
    return 1.0;
}

#pragma mark - Singleton

+ (instancetype)manager
{
    static ThemeManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[super allocWithZone:NULL] init];
    });
    return sharedObject;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self manager];
}


@end
