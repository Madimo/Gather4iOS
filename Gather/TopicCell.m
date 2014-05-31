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
    
    self.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setAuthor:(NSString *)author
{
    _author = author;
    self.authorLabel.text = author;
}

- (void)setAvatar:(NSString *)avatar
{
    _avatar = avatar;
    [self.avatarView setImageWithURL:[NSURL URLWithString:self.avatar]
                    placeholderImage:nil];
}

- (void)setReplyCount:(NSInteger)replyCount
{
    _replyCount = replyCount;
    self.replyCountLabel.text = [NSString stringWithFormat:@"%ld", (long)replyCount];
}

- (void)setCreated:(NSDate *)created
{
    _created = created;
    self.createdLabel.text = [TimeOpreator convertStringFromDate:created];
}

@end
