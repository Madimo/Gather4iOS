//
//  ReplyCell.m
//  Gather
//
//  Created by Madimo on 14-5-16.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "ReplyCell.h"

@interface ReplyCell () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;
@end

@implementation ReplyCell

- (void)awakeFromNib
{
    // Initialization code
    self.contentWebView.scrollView.scrollEnabled = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContentHTML:(NSString *)contentHTML
{
    _contentHTML = contentHTML;
    [self.contentWebView loadHTMLString:contentHTML baseURL:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    frame.origin = CGPointMake(0, 0);
    frame.size = webView.scrollView.contentSize;
    webView.frame = frame;
    NSLog(@"%lf %lf %lf %lf", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
}

- (void)prepareForReuse
{
    [self.contentWebView stopLoading];
}

@end
