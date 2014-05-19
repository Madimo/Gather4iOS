//
//  ReplyViewController.m
//  Gather
//
//  Created by Madimo on 14-5-15.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "ReplyViewController.h"
#import "ReplyCell.h"
#import "GatherAPI.h"
#import "WebContentMatcher.h"
#import <UIImageView+WebCache.h>

@interface ReplyViewController () <UIWebViewDelegate, ReplyCellDelegate>
@property (strong, nonatomic) Topic *topic;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UIWebView *headContentView;
@property (strong, nonatomic) NSMutableArray *replyHTMLs;
@property (strong, nonatomic) NSMutableArray *rowHeight;
@property (strong, nonatomic) NSMutableArray *webviews;
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
                  dispatch_async(dispatch_get_global_queue(0, 0), ^{
                      self.topic = topic;
                      [self reloadHeaderView];
                      [self reloadHTMLsAndRowHeight];
                      [self.tableView reloadData];
                      [self.refreshControl endRefreshing];
                  });
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
    NSString *HTML = [[WebContentMatcher matcher] ConvertToHTMLUsingContent:self.topic.content];
    [self.headContentView loadHTMLString:HTML baseURL:nil];
}

- (void)reloadHTMLsAndRowHeight
{
    self.replyHTMLs = [NSMutableArray new];
    self.rowHeight = [NSMutableArray new];
    
    for (Reply *reply in self.topic.replies) {
        NSNumber *number = [[NSNumber alloc] initWithInt:0];
        [self.rowHeight addObject:number];

        NSString *contentHTML = [[WebContentMatcher matcher] ConvertToHTMLUsingContent:reply.content];
        [self.replyHTMLs addObject:contentHTML];
    }
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

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.rowHeight[indexPath.row] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReplyCell" forIndexPath:indexPath];

    cell.delegate = self;
    cell.contentHTML = self.replyHTMLs[indexPath.row];
    cell.tag = indexPath.row;
    
    return cell;
}

- (void)replyCellDidFinishLoad:(ReplyCell *)cell
{
    NSNumber *height = self.rowHeight[cell.tag];
    if (height.floatValue != cell.calculatedHeight) {
        height = [NSNumber numberWithFloat:cell.calculatedHeight];
        self.rowHeight[cell.tag] = height;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:cell.tag inSection:0];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    frame.size.height = webView.scrollView.contentSize.height;
    webView.frame = frame;
}

@end
