//
//  ReplyCell.m
//  Gather
//
//  Created by Madimo on 14-5-16.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "ReplyCell.h"

@interface ReplyCell () <UIWebViewDelegate>
@property (nonatomic) CGFloat calculatedHeight;
@property (weak, nonatomic) IBOutlet UIWebView *contentWebView;
@end

@implementation ReplyCell

- (void)awakeFromNib
{
    // Initialization code
    self.contentWebView.scrollView.scrollEnabled = NO;
}

- (void)setContentHTML:(NSString *)contentHTML
{
    _contentHTML = contentHTML;
    [self.contentWebView loadHTMLString:contentHTML baseURL:nil];
}

- (void)setTag:(NSInteger)tag
{
    [super setTag:tag];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    self.calculatedHeight = webView.scrollView.contentSize.height;

    CGRect frame = webView.frame;
    frame.size.height = self.calculatedHeight;
    webView.frame = frame;
    
    if ([self.delegate respondsToSelector:@selector(replyCellDidFinishLoad:)]) {
        [self.delegate replyCellDidFinishLoad:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        self.calculatedHeight = self.contentWebView.scrollView.contentSize.height;
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.calculatedHeight = 0;
    [self.contentWebView stopLoading];
}

@end
