//
//  TopicViewController.m
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "TopicViewController.h"
#import "TopicCell.h"
#import "RepliesViewController.h"
#import "GatherClient.h"
#import "ThemeManager.h"
#import "PostViewController.h"
#import "SettingsViewController.h"
#import "ChangeThemeViewController.h"

#define kActionSheetTagLogout 1

@interface TopicViewController () <TopicCellDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic) NSInteger totalPage;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger currentMaxDisplayedCell;
@property (nonatomic) BOOL loading;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *lodingIndicatorView;
@property (weak, nonatomic) IBOutlet UIView *actionButtonView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation TopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.titleLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(titleLabelTap)];
    [self.titleLabel addGestureRecognizer:recognizer];
    
    [self refresh];
}

- (void)refresh
{
    if (self.loading) {
        [self.refreshControl endRefreshing];
        return;
    }
    
    self.loading = YES;
    self.currentPage = 1;
    GatherClient *client = [GatherClient client];
    [client getTopicsInPage:1
                    orderBy:GatherTopicOrderByUpdatedDesc
                    success:^(NSArray *topics, NSInteger totalPages, NSInteger totalTopics) {
                        self.totalPage = totalPages;
                        self.topics = [topics mutableCopy];
                        self.currentMaxDisplayedCell = -1;
                        [self.tableView reloadData];
                        [self.refreshControl endRefreshing];
                        self.lodingIndicatorView.hidden = YES;
                        [self loadRefreshControl];
                        self.loading = NO;
                    }
                    failure:^(NSError *error) {
                        [self.refreshControl endRefreshing];
                        self.lodingIndicatorView.hidden = YES;
                        [self loadRefreshControl];
                        self.loading = NO;
                    }];
}

- (void)loadNext
{
    if (self.refreshControl.refreshing)
        return;
    if (!self.topics)
        return;
    if (self.loading)
        return;
    if (self.currentPage >= self.totalPage)
        return;
    
    self.loading = YES;
    self.lodingIndicatorView.hidden = NO;
    
    GatherClient *client = [GatherClient client];
    [client getTopicsInPage:self.currentPage + 1
                    orderBy:GatherTopicOrderByUpdatedDesc
                    success:^(NSArray *topics, NSInteger totalPages, NSInteger totalTopics) {
                        [self.topics addObjectsFromArray:topics];
                        self.totalPage = totalPages;
                        NSMutableArray *indexPaths = [NSMutableArray new];
                        for (NSInteger i = self.topics.count - topics.count; i < self.topics.count; ++i) {
                            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                            [indexPaths addObject:indexPath];
                        }
                        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                        self.currentPage++;
                        self.lodingIndicatorView.hidden = YES;
                        self.loading = NO;
                    }
                    failure:^(NSError *error) {
                        self.lodingIndicatorView.hidden = YES;
                        self.loading = NO;
                    }];
}

- (void)loadRefreshControl
{
    if (!self.refreshControl) {
        self.refreshControl = [[UIRefreshControl alloc] init];
        self.refreshControl.tintColor = [UIColor whiteColor];
        [self.refreshControl addTarget:self
                                action:@selector(refresh)
                      forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refreshControl];
    }
}

#pragma mark - Menu button action

- (void)titleLabelTap
{
    [UIView beginAnimations:nil context:nil];
    self.actionButtonView.alpha = 0.8;
    self.titleLabel.alpha = 0.0;
    [UIView commitAnimations];
}

- (IBAction)gotoNewTopic:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PostView" bundle:nil];
    
    if ([storyboard.instantiateInitialViewController isKindOfClass:[PostViewController class]]) {
        PostViewController *pvc = storyboard.instantiateInitialViewController;
        [pvc setPostType:PostTypeTopic];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:pvc];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (IBAction)gotoChangeTheme:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChangeTheme"];
    if ([vc isKindOfClass:[ChangeThemeViewController class]]) {
        ChangeThemeViewController *ctv = (ChangeThemeViewController *)vc;
        [self presentViewController:ctv animated:NO completion:nil];
    }
}

- (IBAction)gotoSettings:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Settings" bundle:nil];
    
    if ([storyboard.instantiateInitialViewController isKindOfClass:[SettingsViewController class]]) {
        SettingsViewController *sv = storyboard.instantiateInitialViewController;
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:sv];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (IBAction)gotoLogout:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Logout"
                                                    otherButtonTitles:nil];
    actionSheet.tag = kActionSheetTagLogout;
    [actionSheet showInView:self.view];
}

- (void)logout
{
    [[GatherClient client] logout];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Start" bundle:nil];
    self.view.window.rootViewController = storyboard.instantiateInitialViewController;
}

#pragma mark - Table view data source & Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topics.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TopicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TopicCell" forIndexPath:indexPath];
    
    // Configure the cell...
    Topic *topic = self.topics[indexPath.row];
    cell.delegate = self;
    cell.topic = topic;
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.titleLabel.alpha) {
        [UIView beginAnimations:nil context:nil];
        self.titleLabel.alpha = 0.8;
        self.actionButtonView.alpha = 0.0;
        [UIView commitAnimations];
    }
    
    CGFloat fontSize = MIN(MAX(50.0, 70.0 - scrollView.contentOffset.y / 5.0), 100.0);
    UIFont *font = self.titleLabel.font;
    self.titleLabel.font = [font fontWithSize:fontSize];
    
    if (scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height - 200.0) {
        [self loadNext];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > self.currentMaxDisplayedCell) {
        cell.contentView.alpha = 0.3;
        
        cell.contentView.transform = CGAffineTransformMakeTranslation(-40, 0);
        
        [self.tableView bringSubviewToFront:cell.contentView];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.65];
        cell.contentView.alpha = 1;
        cell.contentView.transform = CGAffineTransformMakeTranslation(0, 0);
        [UIView commitAnimations];
        
        self.currentMaxDisplayedCell = indexPath.row;
    }
}

#pragma mark - TopicCell delegate

- (void)didTapUserInTopicCell:(TopicCell *)cell
{

}

- (void)didTapTopicInTopicCell:(TopicCell *)cell
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RepliesViewController *rvc = [storyboard instantiateViewControllerWithIdentifier:@"Reply"];
    rvc.topicId = cell.topic.topicId;
    rvc.title = cell.topic.title;
    
    [self presentViewController:rvc animated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (actionSheet.tag) {
        case kActionSheetTagLogout:
            [self logout];
            break;
            
        default:
            break;
    }
}

@end
