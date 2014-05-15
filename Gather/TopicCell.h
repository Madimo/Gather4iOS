//
//  TopicCell.h
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicCell : UITableViewCell

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *avatar;
@property (strong, nonatomic) NSString *node;
@property (nonatomic) NSInteger replyCount;
@property (strong, nonatomic) NSDate *created;

@end
