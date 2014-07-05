//
//  Reply.h
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Reply;
@class User;

@interface Reply : NSObject

@property (nonatomic) NSInteger replyId;
@property (nonatomic) NSInteger authorId;
@property (nonatomic) NSInteger topicId;

@property (nonatomic, strong) NSString *content;

@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSDate *changed;

@property (nonatomic, strong) User *author;

+ (instancetype)replyWithReplyDict:(NSDictionary *)dict;

- (instancetype)initWithReplyDict:(NSDictionary *)dict;

@end
