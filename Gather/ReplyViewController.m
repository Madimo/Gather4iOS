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

@interface ReplyViewController () <UIWebViewDelegate>
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
                  self.topic = topic;
                  [self reloadHeaderView];
                  [self reloadHTMLsAndRowHeight];
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
    NSString *HTML = [[WebContentMatcher matcher] ConvertToHTMLUsingContent:self.topic.content];
    [self.headContentView loadHTMLString:HTML baseURL:nil];
}

- (void)reloadHTMLsAndRowHeight
{
    self.replyHTMLs = [NSMutableArray new];
    self.rowHeight = [NSMutableArray new];
    self.webviews = [NSMutableArray new];
    
    CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, 10);
    
    NSInteger count = 0;
    for (Reply *reply in self.topic.replies) {
        NSNumber *number = [[NSNumber alloc] initWithInt:0];
        [self.rowHeight addObject:number];

        NSString *contentHTML = [[WebContentMatcher matcher] ConvertToHTMLUsingContent:reply.content];
        [self.replyHTMLs addObject:contentHTML];
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];
        webView.hidden = NO;
        webView.tag = count;
        webView.delegate = self;
        [self.webviews addObject:webView];
        [self.tableView addSubview:webView];
        [webView loadHTMLString:contentHTML baseURL:nil];
        
        count++;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%lf", [self.rowHeight[indexPath.row] floatValue]);
    return [self.rowHeight[indexPath.row] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReplyCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.contentHTML = self.replyHTMLs[indexPath.row];
    
    return cell;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    frame.size = webView.scrollView.contentSize;
    webView.frame = frame;
    
    if (webView == self.headContentView) {
        UIView *view = self.tableView.tableHeaderView;
        frame = view.frame;
        frame.size.height += webView.scrollView.contentSize.height;
        view.frame = frame;
        self.tableView.tableHeaderView = view;
    } else {
        NSNumber *number = [NSNumber numberWithFloat:webView.scrollView.contentSize.height];
        self.rowHeight[webView.tag] = number;
        [webView removeFromSuperview];
        [self.webviews removeObject:webView];
        if (self.webviews.count == 0) {
            [self.tableView reloadData];
        }
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
