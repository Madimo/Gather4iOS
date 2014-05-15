//
//  ReplyViewController.m
//  Gather
//
//  Created by Madimo on 14-5-15.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "ReplyViewController.h"
#import "GatherAPI.h"
#import <UIImageView+WebCache.h>

@interface ReplyViewController ()
@property (strong, nonatomic) Topic *topic;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@end

@implementation ReplyViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.avatarView.layer.cornerRadius = self.avatarView.layer.frame.size.height / 2.0;
    self.avatarView.layer.masksToBounds = YES;
    
    [self refresh];
}

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    
    GatherAPI *api = [GatherAPI sharedAPI];
    [api getTopicById:self.topicId
              success:^(Topic *topic) {
                  self.topic = topic;
                  [self reloadHeaderView];
                  [self.refreshControl endRefreshing];
              }
              failure:^(NSException *exception) {
                  [self.refreshControl endRefreshing];
              }
    ];
}

- (void)reloadHeaderView
{
    NSString *url = [NSString stringWithFormat:@"http://gravatar.whouz.com/avatar/%@?s=200", self.topic.author.emailMD5];
    [self.avatarView setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil];
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
