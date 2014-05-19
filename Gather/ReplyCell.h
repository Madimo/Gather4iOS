//
//  ReplyCell.h
//  Gather
//
//  Created by Madimo on 14-5-16.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ReplyCell;

@protocol ReplyCellDelegate <NSObject>

@optional
- (void)replyCellDidFinishLoad:(ReplyCell *)cell;

@end

@interface ReplyCell : UITableViewCell

@property (weak, nonatomic) id<ReplyCellDelegate> delegate;
@property (strong, nonatomic) NSString *contentHTML;
@property (nonatomic, readonly) CGFloat calculatedHeight;

@end
