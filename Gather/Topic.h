//
//  Topic.h
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;
@class Node;

@interface Topic : NSObject

@property (nonatomic) NSInteger topicId;

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *content;
@property (nonatomic) BOOL haveRead;

@property (strong, nonatomic) User *author;
@property (strong, nonatomic) Node *node;
@property (strong, nonatomic) NSArray *replies;

@property (strong, nonatomic) NSDate *created;
@property (strong, nonatomic) NSDate *updated;
@property (strong, nonatomic) NSDate *changed;

+ (instancetype)topicWithTopicDict:(NSDictionary *)dict;

- (id)initWithTopicDict:(NSDictionary *)dict;

@end
