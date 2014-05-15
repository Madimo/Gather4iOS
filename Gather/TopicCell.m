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
@property (weak, nonatomic) IBOutlet UIView *view;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@end

@implementation TopicCell

- (void)awakeFromNib
{
    // Initialization code
    
    self.view.layer.cornerRadius = 6.0;
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

@end
