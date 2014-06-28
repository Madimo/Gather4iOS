//
//  ChangeThemeViewController.m
//  Gather
//
//  Created by Madimo on 6/28/14.
//  Copyright (c) 2014 Madimo. All rights reserved.
//

#import "ChangeThemeViewController.h"
#import "ThemeManager.h"
#import <UIImage+ImageEffects.h>

@interface ChangeThemeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UISlider *saturationSlider;
@property (weak, nonatomic) IBOutlet UISlider *blurRadiusSlider;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) UIImage *backgroundImage;
@end

@implementation ChangeThemeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.blurRadiusSlider.value = [ThemeManager manager].blurRadius;
    self.saturationSlider.value = [ThemeManager manager].saturation;
    self.backgroundImageView.image = [ThemeManager manager].blurImage;
    _backgroundImage = [ThemeManager manager].image;
    
    self.contentView.alpha = 0.0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [UIView beginAnimations:nil context:nil];
    self.contentView.alpha = 1.0;
    [UIView commitAnimations];
}

- (void)updateImage
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *blurImage = [self.backgroundImage applyBlurWithRadius:self.blurRadiusSlider.value
                                                             tintColor:[UIColor colorWithWhite:0.2 alpha:0.3]
                                                 saturationDeltaFactor:self.saturationSlider.value
                                                             maskImage:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.backgroundImageView.image = blurImage;
        });
    });
}

- (IBAction)valueChanged:(id)sender
{
    [self updateImage];
}

- (IBAction)chooseImage:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        ipc.delegate = self;
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        [self presentViewController:ipc animated:YES completion:nil];
    }
}

- (IBAction)apply:(id)sender
{
    ThemeManager *manager = [ThemeManager manager];
    manager.image = self.backgroundImage;
    manager.blurRadius = self.blurRadiusSlider.value;
    manager.saturation = self.saturationSlider.value;
    [manager applyAndUpdate];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)setToDefault:(id)sender
{
    ThemeManager *manager = [ThemeManager manager];
    self.backgroundImage = manager.defaultImage;
    [self.blurRadiusSlider setValue:manager.defaultBlurRadius animated:YES];
    [self.saturationSlider setValue:manager.defaultSaturation animated:YES];
    [self updateImage];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    self.backgroundImage = [UIImage imageWithData:data];
    [self updateImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
