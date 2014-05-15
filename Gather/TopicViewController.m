//
//  TopicViewController.m
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "TopicViewController.h"
#import "TopicCell.h"
#import "GatherAPI.h"

@interface TopicViewController ()
@property (nonatomic, strong) NSMutableArray *topics;
@property (nonatomic) NSInteger totalPage;
@property (nonatomic) NSInteger currentPage;
@property (nonatomic) BOOL loading;
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
                     for (int i = self.topics.count - topics.count; i < self.topics.count; ++i) {
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
    cell.title = topic.title;
    cell.author = topic.author.username;
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > scrollView.contentSize.height * 2.0 / 3.0) {
        [self loadNext];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@""]) {
        
    }
}


@end
