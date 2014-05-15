//
//  Topic.h
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Topic : NSObject

@property (nonatomic) NSInteger topicId;
@property (nonatomic) NSInteger authorId;
@property (nonatomic) NSInteger nodeId;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) NSArray *replies;
@property (nonatomic) NSInteger replyCount;

@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSDate *updated;
@property (strong, nonatomic) NSDate *changed;

@property (strong, nonatomic) User *author;

- (id)initWithTopicDict:(NSDictionary *)dict;

@end
