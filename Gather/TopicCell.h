//
//  TopicCell.h
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TopicCell;
@class Topic;

@protocol TopicCellDelegate <NSObject>

@optional
- (void)didTapTopicInTopicCell:(TopicCell *)cell;
- (void)didTapUserInTopicCell:(TopicCell *)cell;

@end

@interface TopicCell : UITableViewCell

@property (weak, nonatomic) id<TopicCellDelegate> delegate;
@property (strong, nonatomic) Topic *topic;

@end
