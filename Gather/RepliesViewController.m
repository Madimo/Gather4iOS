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

@interface RepliesViewController () <UIWebViewDelegate, UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (strong, nonatomic) UIWebView *contentWebView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) Topic *topic;
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

    [self.contentWebView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    [self refresh];
}

- (void)dealloc
{
    [self.contentWebView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (void)refresh
{
    [[GatherAPI sharedAPI] getTopicById:self.topicId
                                success:^(Topic *topic) {
                                    self.topic = topic;
                                    NSString *repliesHTML = [[ContentTranslator sharedTranslator] convertToWebUsingTopic:topic];
                                    [self.contentWebView loadHTMLString:repliesHTML baseURL:nil];
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [UIView beginAnimations:nil context:nil];
                                        [UIView setAnimationDelay:0.5];
                                        self.contentWebView.alpha = 1.0;
                                        [UIView commitAnimations];
                                    });
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
            NSString *title = [NSString stringWithFormat:@"#%ld by %@", (long)index + 1, [self.topic.replies[index] author].username];
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:@"Reply"
                                                            otherButtonTitles:@"Rank", nil];
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
    
}

#pragma mark - Button action

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
