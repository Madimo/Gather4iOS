//
//  TopicCell.m
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "TopicCell.h"
#import <UIImageView+WebCache.h>
#import "TimeOpreator.h"
#import "Topic.h"

@interface TopicCell ()
@property (weak, nonatomic) IBOutlet UILabel *replyCountLabel;
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
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
}

- (void)setTopic:(Topic *)topic
{
    _topic = topic;
    
    self.titleLabel.text = topic.title;
    self.authorLabel.text = topic.author.username;
    NSString *avatarUrl = [NSString stringWithFormat:@"http://gravatar.whouz.com/avatar/%@?s=200", topic.author.emailMD5];
    [self.avatarView setImageWithURL:[NSURL URLWithString:avatarUrl]];
    self.replyCountLabel.text = [NSString stringWithFormat:@"%@", @(topic.replyCount)];
    self.createdLabel.text = [TimeOpreator convertStringFromDate:topic.created];

    if (topic.changed) {
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

- (void)prepareForReuse
{
    [self.replyCountLabel.layer removeAnimationForKey:@"UnreadNotifacition"];
}

@end
