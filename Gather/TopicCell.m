//
//  TopicCell.m
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "TopicCell.h"
#import <UIImageView+WebCache.h>

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
    self.replyCountLabel.textColor = [UIColor whiteColor];
    self.replyCountLabel.backgroundColor = [UIColor grayColor];
    self.replyCountLabel.layer.cornerRadius = 10.0;
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
    self.createdLabel.text = [self convertStringFromDate:created];
}

- (NSString *)convertStringFromDate:(NSDate *)date
{
    NSTimeInterval interval = abs([date timeIntervalSinceNow]);
    if (interval < 60)
        return @"less than a minute";
    if (interval < 3600)
        return  [NSString stringWithFormat:@"%d minutes ago", (int)(interval / 60 + 0.5)];
    if (interval < 3600 * 24)
        return  [NSString stringWithFormat:@"%d hours ago", (int)(interval / 3600 + 0.5)];
    if (interval < 3600 * 24 * 7)
        return  [NSString stringWithFormat:@"%d days ago", (int)(interval / 3600 / 24 + 0.5)];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"d/M/yy HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    return [formatter stringFromDate:date];
}

@end
