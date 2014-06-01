//
//  MAWebView.h
//  Gather
//
//  Created by Madimo on 14-6-1.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAWebView;

@protocol MAWebViewProgressDelegate <NSObject>
@optional
- (void)webView:(MAWebView *)webView didReceiveResourceNumber:(NSInteger)resourceNumber totalResources:(NSInteger)totalResources;
@end

@interface MAWebView : UIWebView

@property (nonatomic, weak) id<MAWebViewProgressDelegate> progressDelegate;

@property (nonatomic) NSInteger resourceCount;
@property (nonatomic) NSInteger resourceCompletedCount;

@end
