//
//  TopicViewController.m
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "TopicViewController.h"
#import "TopicCell.h"
#import "ReplyViewController.h"
#import "GatherAPI.h"

@interface TopicViewController ()
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic) NSInteger totalPage;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) BOOL loading;
@property (nonatomic) NSInteger currentMaxDisplayedCell;
@end

@implementation TopicViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    self.currentPage = 1;
    GatherAPI *api = [GatherAPI sharedAPI];
    [api getTopicsInPage:1
                 success:^(NSArray *topics, NSInteger totalPage, NSInteger totalTopics) {
                     self.totalPage = totalPage;
                     self.topics = [topics mutableCopy];
                     self.currentMaxDisplayedCell = -1;
                     [self.tableView reloadData];
                     [self.refreshControl endRefreshing];
                 }
                 failure:^(NSException *exception) {
                     [self.refreshControl endRefreshing];
                 }
    ];
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
    
    GatherAPI *api = [GatherAPI sharedAPI];
    [api getTopicsInPage:self.currentPage + 1
                 success:^(NSArray *topics, NSInteger totalPage, NSInteger totalTopics) {
                     [self.topics addObjectsFromArray:topics];
                     self.totalPage = totalPage;
                     NSMutableArray *indexPaths = [NSMutableArray new];
                     for (NSInteger i = self.topics.count - topics.count; i < self.topics.count; ++i) {
                         NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                         [indexPaths addObject:indexPath];
                     }
                     [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
                     self.currentPage++;
                     self.loading = NO;
                 }
                 failure:^(NSException *exception) {
                     self.loading = NO;
                 }
    ];
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
    cell.topicId = topic.topicId;
    cell.title = topic.title;
    cell.author = topic.author.username;
    cell.avatar = [NSString stringWithFormat:@"http://gravatar.whouz.com/avatar/%@?s=200", topic.author.emailMD5];
    cell.replyCount = topic.replyCount;
    cell.created = topic.created;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > scrollView.contentSize.height * 2.0 / 3.0) {
        [self loadNext];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row > self.currentMaxDisplayedCell) {
        cell.contentView.alpha = 0.3;
        
        CGAffineTransform transformScale = CGAffineTransformMakeScale(1.15, 1.15);
        CGAffineTransform transformTranslate;
        if (indexPath.row % 2)
            transformTranslate = CGAffineTransformMakeTranslation(-10, 5);
        else
            transformTranslate = CGAffineTransformMakeTranslation(10, 5);
        
        cell.contentView.transform = CGAffineTransformConcat(transformScale, transformTranslate);
        
        [self.tableView bringSubviewToFront:cell.contentView];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.65];
        cell.contentView.alpha = 1;
        cell.contentView.transform = CGAffineTransformIdentity;
        [UIView commitAnimations];
        
        self.currentMaxDisplayedCell = indexPath.row;
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Reply"]) {
        if ([segue.destinationViewController isKindOfClass:[ReplyViewController class]]) {
            ReplyViewController *dest = segue.destinationViewController;
            [dest setTopicId:((TopicCell *)sender).topicId];
        }
    }
}


@end
