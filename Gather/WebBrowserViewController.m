//
//  WebBrowserViewController.m
//  Gather
//
//  Created by Madimo on 14-6-1.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "WebBrowserViewController.h"
#import "MAWebView.h"
#import <OpenInChromeController.h>

@interface WebBrowserViewController () <UIWebViewDelegate, MAWebViewProgressDelegate>
@property (nonatomic) BOOL toolbarHidden;
@property (strong, nonatomic) MAWebView *webView;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIBarButtonItem *forwardButton;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIBarButtonItem *refreshStopButton;
@property (strong, nonatomic) UIBarButtonItem *openInChromeButton;
@property (strong, nonatomic) UIBarButtonItem *openInSafariButton;
@end

@implementation WebBrowserViewController

#pragma mark - Initialize

- (void)initWebView
{
    self.webView = [[MAWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    self.webView.progressDelegate = self;
    [self.view addSubview:self.webView];
}

- (void)initProgressView
{
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    CGRect frame = self.progressView.frame;
    frame.origin.y = CGRectGetHeight(self.navigationController.navigationBar.frame) - CGRectGetHeight(frame);
    frame.size.width = CGRectGetWidth(self.navigationController.navigationBar.frame);
    self.progressView.frame = frame;
    self.progressView.alpha = 0.0;
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)initToolbar
{
    self.backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"]
                                                       style:UIBarButtonItemStylePlain
                                                      target:self
                                                      action:@selector(goBack:)];
    
    self.forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"forward"]
                                                          style:UIBarButtonItemStylePlain
                                                         target:self
                                                         action:@selector(goForward:)];
    
    self.refreshStopButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload"]
                                                              style:UIBarButtonItemStylePlain
                                                             target:self
                                                             action:@selector(reload:)];
    
    self.openInChromeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chrome"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(openInChrome:)];
    
    self.openInSafariButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"safari"]
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(openInSafari:)];
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:self
                                                                           action:nil];
    
    self.openInChromeButton.enabled = [OpenInChromeController sharedInstance].isChromeInstalled;

    
    NSArray *items = @[self.backButton, space, self.forwardButton, space, self.refreshStopButton, space, self.openInChromeButton, space, self.openInSafariButton];
    
    [self setToolbarItems:items];

    self.toolbarHidden = self.navigationController.toolbarHidden;
    self.navigationController.toolbarHidden = NO;
}

#pragma mark - View lift cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initWebView];
    [self initProgressView];
    [self initToolbar];
    
    self.title = self.url;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.url]];
    [self.webView loadRequest:request];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbarHidden = self.toolbarHidden;
}

#pragma mark - UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(setTitleFromWebView:)
                                   userInfo:nil
                                    repeats:YES];
    
    self.refreshStopButton.image = [UIImage imageNamed:@"stop"];
    [self refreshButtonStatus];
    
    self.progressView.progress = 0.0;
    self.progressView.alpha = 1.0;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.refreshStopButton.image = [UIImage imageNamed:@"reload"];
    [self refreshButtonStatus];
    
    [UIView beginAnimations:nil context:nil];
    self.progressView.alpha = 0.0;
    [UIView commitAnimations];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.refreshStopButton.image = [UIImage imageNamed:@"reload"];
    [self refreshButtonStatus];
    
    [UIView beginAnimations:nil context:nil];
    self.progressView.alpha = 0.0;
    [UIView commitAnimations];
}

#pragma mark - Private API

- (void)webView:(MAWebView *)webView didReceiveResourceNumber:(NSInteger)resourceNumber totalResources:(NSInteger)totalResources
{
    [self.progressView setProgress:(float)resourceNumber / (float)totalResources animated:YES];
}

#pragma mark - Timer action

- (void)setTitleFromWebView:(NSTimer *)timer
{
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title && ![title isEqualToString:@""]) {
        self.title = title;
    }
    
    if (!self.webView.isLoading) {
        [timer invalidate];
    }
}

#pragma mark - Toolbar button item action

- (void)refreshButtonStatus
{
    self.backButton.enabled = self.webView.canGoBack;
    self.forwardButton.enabled = self.webView.canGoForward;
}

- (void)goBack:(id)sender
{
    [self.webView goBack];
    [self refreshButtonStatus];
}

- (void)goForward:(id)sender
{
    [self.webView goForward];
    [self refreshButtonStatus];
}

- (void)reload:(id)sender
{
    if (self.webView.isLoading)
        [self.webView stopLoading];
    else
        [self.webView reload];
    [self refreshButtonStatus];
}

- (void)openInChrome:(id)sender
{
    [[OpenInChromeController sharedInstance] openInChrome:self.webView.request.URL
                                          withCallbackURL:[NSURL URLWithString:@"gather://"]
                                             createNewTab:NO];
}

- (void)openInSafari:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

@end
