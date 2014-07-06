//
//  SettingsViewController.m
//  Gather
//
//  Created by Madimo on 6/28/14.
//  Copyright (c) 2014 Madimo. All rights reserved.
//

#import "SettingsViewController.h"
#import "GatherClient.h"

#define kActionSheetTagClearAllCaches 1
#define kActionSheetTagLogout         2

@interface SettingsViewController () <UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UITableViewCell *signatureCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *clearAllCachesCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *logoutCell;
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (IBAction)done:(id)sender
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)clearAllCaches
{
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] clearMemory];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)logout
{
    [[GatherClient client] logout];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Start" bundle:nil];
    self.view.window.rootViewController = storyboard.instantiateInitialViewController;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == self.clearAllCachesCell) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Clear All Caches"
                                                  otherButtonTitles:nil];
        sheet.tag = kActionSheetTagClearAllCaches;
        [sheet showInView:self.view];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (cell == self.logoutCell) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Log out"
                                                  otherButtonTitles:nil];
        sheet.tag = kActionSheetTagLogout;
        [sheet showInView:self.view];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (actionSheet.tag) {
        case kActionSheetTagClearAllCaches:
            [self clearAllCaches];
            break;
        case kActionSheetTagLogout:
            [self logout];
            break;
        default:
            break;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
