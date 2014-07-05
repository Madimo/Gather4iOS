//
//  TopicCell.m
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "TopicCell.h"
#import "TimeOpreator.h"
#import "GatherModels.h"

@interface TopicCell ()
@property (weak, nonatomic) IBOutlet UILabel *replyCountLabel;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UILabel *nodeLabel;
@end

@implementation TopicCell

- (void)awakeFromNib
{
    // Initialization code
    
    self.view.layer.cornerRadius = 6.0;
    self.view.layer.masksToBounds = YES;
    
    self.replyCountLabel.layer.cornerRadius = 6.0;
    self.replyCountLabel.layer.masksToBounds = YES;
    
    self.avatarView.layer.cornerRadius = self.avatarView.layer.frame.size.height / 2.0;
    self.avatarView.layer.masksToBounds = YES;
    
    self.backgroundColor = [UIColor clearColor];
    
    NSArray *views = @[self.view, self.avatarView, self.authorLabel];
    for (UIView *view in views) {
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                     action:@selector(handleGesture:)];
        [view addGestureRecognizer:recognizer];
        view.userInteractionEnabled = YES;
    }
}

- (void)setTopic:(Topic *)topic
{
    _topic = topic;
    
    self.titleLabel.text = topic.title;
    self.authorLabel.text = topic.author.username;
    NSString *avatarUrl = [NSString stringWithFormat:@"http://gravatar.whouz.com/avatar/%@?s=200", topic.author.emailMD5];
    [self.avatarView setImageWithURL:[NSURL URLWithString:avatarUrl]];
    self.nodeLabel.text = topic.node.name;
    self.replyCountLabel.text = [NSString stringWithFormat:@"%@", @(topic.replies.count)];
    self.createdLabel.text = [TimeOpreator convertStringFromDate:topic.created];

    if (!topic.haveRead) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animation.fromValue = @0.5;
        animation.toValue = @0.0;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        animation.repeatCount = HUGE_VALF;
        animation.autoreverses = YES;
        animation.duration = 1.5;
        [self.replyCountLabel.layer addAnimation:animation forKey:@"UnreadNotifacition"];
    }
}

- (void)handleGesture:(UITapGestureRecognizer *)recognizer
{
    if (self.delegate) {
        if (recognizer.view == self.view) {
            if ([self.delegate respondsToSelector:@selector(didTapTopicInTopicCell:)]) {
                [self.delegate didTapTopicInTopicCell:self];
            }
        } else if (recognizer.view == self.avatarView || recognizer.view == self.authorLabel) {
            if ([self.delegate respondsToSelector:@selector(didTapUserInTopicCell:)]) {
                [self.delegate didTapUserInTopicCell:self];
            }
        }
    }
}

- (void)prepareForReuse
{
    [self.replyCountLabel.layer removeAllAnimations];
}

@end
