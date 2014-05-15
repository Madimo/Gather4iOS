//
//  ReplyViewController.m
//  Gather
//
//  Created by Madimo on 14-5-15.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "ReplyViewController.h"
#import "GatherAPI.h"

@interface ReplyViewController ()
@property (strong, nonatomic) Topic *topic;
@end

@implementation ReplyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    
    GatherAPI *api = [GatherAPI sharedAPI];
    [api getTopicById:self.topicId
              success:^(Topic *topic) {
                  self.topic = topic;
                  [self.refreshControl endRefreshing];
              }
              failure:^(NSException *exception) {
                  [self.refreshControl endRefreshing];
              }
    ];
}

#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topic.replies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReplyCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
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
