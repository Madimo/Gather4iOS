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
#import "WebBrowserController.h"
#import "PostViewController.h"

@interface RepliesViewController () <UIWebViewDelegate, UIActionSheetDelegate, PostViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *addReplyButton;
@property (strong, nonatomic) UIWebView *contentWebView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) Topic *topic;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation RepliesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 0, self.contentScrollView.frame.size.width, 1);
    self.contentWebView = [[UIWebView alloc] initWithFrame:frame];
    self.contentWebView.delegate = self;
    self.contentWebView.scrollView.scrollEnabled = NO;
    self.contentWebView.dataDetectorTypes = UIDataDetectorTypeNone;
    self.contentWebView.backgroundColor = [UIColor clearColor];
    self.contentWebView.opaque = NO;
    self.contentWebView.alpha = 0.0;
    [self.contentScrollView addSubview:self.contentWebView];
    
    self.contentScrollView.contentInset = UIEdgeInsetsMake(75, 0, 0, 0);
    
    self.titleLabel = [UILabel new];

    CGRect rect = [self.title boundingRectWithSize:CGSizeMake(self.view.frame.size.width, 200)
                                           options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                        attributes:@{ NSFontAttributeName : self.titleLabel.font }
                                           context:nil];
    rect.size.width = self.view.frame.size.width;
    rect.origin.y = -rect.size.height - 95;
    self.titleLabel.frame = rect;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.titleLabel.text = self.title;
    self.titleLabel.textColor = [UIColor whiteColor];
    [self.contentScrollView addSubview:self.titleLabel];

    [self.contentWebView.scrollView addObserver:self
                                     forKeyPath:@"contentSize"
                                        options:NSKeyValueObservingOptionNew
                                        context:nil];
    
    [self refresh];
}

- (void)dealloc
{
    [self.contentWebView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)refresh
{
    [self.activityIndicator startAnimating];
    self.activityIndicator.hidden = NO;
    self.addReplyButton.alpha = 0.0;
    self.contentWebView.alpha = 0.0;
    
    [self pullToRefresh];
}

- (void)pullToRefresh
{
    [self.refreshControl beginRefreshing];
    [[GatherAPI sharedAPI] getTopicById:self.topicId
                                success:^(Topic *topic) {
                                    self.topic = topic;
                                    NSString *repliesHTML = [[ContentTranslator sharedTranslator] convertToWebUsingTopic:topic];
                                    [self.contentWebView loadHTMLString:repliesHTML baseURL:nil];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self.activityIndicator stopAnimating];
                                        [UIView beginAnimations:nil context:nil];
                                        [UIView setAnimationDelay:0.5];
                                        self.contentWebView.alpha = 1.0;
                                        self.addReplyButton.alpha = 1.0;
                                        [UIView commitAnimations];
                                        
                                        if (!self.refreshControl) {
                                            self.refreshControl = [[UIRefreshControl alloc] init];
                                            self.refreshControl.tintColor = [UIColor whiteColor];
                                            [self.refreshControl addTarget:self
                                                                    action:@selector(pullToRefresh)
                                                          forControlEvents:UIControlEventValueChanged];
                                            [self.contentScrollView addSubview:self.refreshControl];
                                        }
                                        
                                        [self.refreshControl endRefreshing];
                                    });
                                }
                                failure:^(NSException *exception) {
                                    [self.refreshControl endRefreshing];
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
        CGRect frame = webView.frame;
        frame.size = size;
        webView.frame = frame;
        
        CGFloat height = self.contentScrollView.frame.size.height - self.contentScrollView.contentInset.top + webView.frame.origin.y;
        
        size.height = scrollView.contentSize.height > height ? scrollView.contentSize.height : height;
        
        self.contentScrollView.contentSize = size;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = request.URL.absoluteString;
    
    NSLog(@"%@", requestString);
    
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    if (components.count == 3 && [[components objectAtIndex:0] isEqualToString:@"gather"]) {
        NSInteger index = [components[2] integerValue];
        if ([components[1] isEqualToString:@"reply"]) {
            NSString *title = [NSString stringWithFormat:@"#%@ by %@", @(index + 1), [self.topic.replies[index] author].username];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Reply", @"Rank", @"Copy", nil];
            actionSheet.tag = index;
            [actionSheet showInView:self.view];
        } else if ([components[1] isEqualToString:@"jumpToFloor"]) {
            NSInteger top = [components[2] integerValue];
            CGRect rect = CGRectMake(0, top, 100, self.contentScrollView.frame.size.height - self.contentScrollView.contentInset.top);
            [self.contentScrollView scrollRectToVisible:rect animated:YES];
        }
        NSString *title = [NSString stringWithFormat:@"recv command: %@\nwith paramter: %@", components[1], components[2]];
        NSLog(@"%@", title);
        return NO;
    }
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        // #x jump to floor
        if (requestString.length > 15 && [[requestString substringWithRange:NSMakeRange(0, 15)] isEqualToString:@"applewebdata://"]) {
            NSLog(@"allow");
            return YES;
        } else {
            WebBrowserController *webBrowser = [[WebBrowserController alloc] init];
            webBrowser.url = requestString;
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:webBrowser];
            [self presentViewController:nc animated:YES completion:nil];
            return NO;
        }
    }
    
    return YES;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            // Reply
            NSString *username = ((Reply *)self.topic.replies[actionSheet.tag]).author.username;
            NSString *reply = [NSString stringWithFormat:@"#%@ @%@ ", @(actionSheet.tag + 1), username];
            if (!self.content || [self.content isEqualToString:@""]) {
                self.content = reply;
            } else {
                self.content = [NSString stringWithFormat:@"%@\n%@ ", self.content, reply];
            }
            [self reply:actionSheet];
        }
            break;
        case 1:
            // Rank
            self.content = ((Reply *)self.topic.replies[actionSheet.tag]).content;
            [self reply:actionSheet];
            break;
        case 2: {
            // Copy
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            [pasteboard setString:((Reply *)self.topic.replies[actionSheet.tag]).content];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Button action

- (IBAction)reply:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PostView" bundle:nil];
    if ([storyboard.instantiateInitialViewController isKindOfClass:[PostViewController class]]) {
        PostViewController *pvc = storyboard.instantiateInitialViewController;
        pvc.postType = PostTypeReply;
        pvc.topic = self.topic;
        pvc.content = self.content;
        pvc.delegate = self;
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:pvc];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - PostViewControllerDelegate

- (void)postViewController:(PostViewController *)controller
  postCanceledWithPostType:(PostType)postType
                     title:(NSString *)title
                      node:(Node *)node
                   content:(NSString *)content
{
    self.content = content;
}

- (void)postViewController:(PostViewController *)controller didPostWithPost:(id)post
{
    [self refresh];
}

@end
