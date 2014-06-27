//
//  AppDelegate.m
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "AppDelegate.h"
#import "GatherAPI.h"
#import "BackgroundImage.h"
#import <AFNetworkActivityIndicatorManager.h>
#import <AFNetworking.h>

@interface AppDelegate () <UIAlertViewDelegate>
@property (strong, nonatomic) NSString *updateUrl;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    AFNetworkActivityIndicatorManager *manager = [AFNetworkActivityIndicatorManager sharedManager];
    [manager setEnabled:YES];
    
    self.backgroundWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.backgroundWindow.bounds];
    backgroundImageView.image = [BackgroundImage sharedImage].image;
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view = backgroundImageView;
    self.backgroundWindow.rootViewController = vc;
    self.backgroundWindow.windowLevel = UIWindowLevelNormal - 1;
    [self.backgroundWindow makeKeyAndVisible];
    
    NSString *storyboardName;
    storyboardName = [[GatherAPI sharedAPI] isLogined] ? @"Main" : @"Start";
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = storyboard.instantiateInitialViewController;
    [self.window makeKeyAndVisible];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![ud stringForKey:UD_KEY_SIGNATURE]) {
        [ud setObject:@"Posted from Gather for iOS" forKey:UD_KEY_SIGNATURE];
        [ud synchronize];
    }
    
    [self checkForUpdate];
    
    return YES;
}

#pragma mark - Update

- (void)checkForUpdate
{
    [[AFHTTPSessionManager manager] GET:@"http://fir.im/api/v2/app/version/com.Madimo.Gather"
                             parameters:nil
                                success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                                    if ([responseObject[@"name"] isEqualToString:@"Gather"]) {
                                        NSString *version = [NSBundle mainBundle].infoDictionary[(NSString *)kCFBundleVersionKey];
                                        if (![version isEqualToString:responseObject[@"version"]]) {
                                            self.updateUrl = responseObject[@"update_url"];
                                            UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"Update Available"
                                                                                           message:responseObject[@"changelog"]
                                                                                          delegate:self
                                                                                 cancelButtonTitle:@"Later"
                                                                                 otherButtonTitles:@"Update", nil];
                                            [view show];
                                        }
                                    }
                                }
                                failure:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateUrl]];
    }
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
