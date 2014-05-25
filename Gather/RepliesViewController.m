//
//  RepliesViewController.m
//  Gather
//
//  Created by Madimo on 14-5-23.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "RepliesViewController.h"
#import "GatherAPI.h"
#import "ContentTranslator.h"

@interface RepliesViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) UIWebView *repliesWebView;
@end

@implementation RepliesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 0, self.contentScrollView.frame.size.width, 1);
    self.repliesWebView = [[UIWebView alloc] initWithFrame:frame];
    self.repliesWebView.delegate = self;
    self.repliesWebView.scrollView.scrollEnabled = NO;
    [self.contentScrollView addSubview:self.repliesWebView];

    [self.repliesWebView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    [self refresh];
}

- (void)dealloc
{
    [self.repliesWebView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)refresh
{
    [[GatherAPI sharedAPI] getTopicById:self.topicId
                                success:^(Topic *topic) {
                                    NSString *repliesHTML = [[ContentTranslator sharedTranslator] convertToWebUsingReplies:topic.replies];
                                    [self.repliesWebView loadHTMLString:repliesHTML baseURL:nil];
                                }
                                failure:^(NSException *exception) {
                                    
                                }
     ];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        UIScrollView *scrollView = (UIScrollView *)object;
        UIWebView *webView = (UIWebView *)scrollView.superview;

        CGSize size = self.contentScrollView.frame.size;
        size.height = scrollView.contentSize.height;
        CGRect frame = CGRectMake(0, 0, size.width, size.height);
        webView.frame = frame;
        
        CGFloat height = self.contentScrollView.frame.size.height - self.contentScrollView.contentInset.top;
        size.height = scrollView.contentSize.height > height ? scrollView.contentSize.height : height;
        
        self.contentScrollView.contentSize = size;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = request.URL.absoluteString;
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    if (components.count == 3 && [[components objectAtIndex:0] isEqualToString:@"gather"]) {
        NSString *title = [NSString stringWithFormat:@"recv command: %@\nwith paramter: %@", components[1], components[2]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:@""
                                                       delegate:nil
                                              cancelButtonTitle:@"ok"
                                              otherButtonTitles:nil];
        [alert show];
    }
    return YES;
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
