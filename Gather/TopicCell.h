//
//  TopicCell.h
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopicCell : UITableViewCell

@property (strong, nonatomic) UIImage *avatar;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSString *author;
@property (strong, nonatomic) NSString *node;
@property (strong, nonatomic) NSString *time;

@end
