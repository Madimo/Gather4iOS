//
//  Topic.m
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "Topic.h"
#import "Reply.h"

@implementation Topic

- (instancetype)initWithTopicDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.topicId = [dict[@"topic"] integerValue];
        self.authorId = [dict[@"author"] integerValue];
        self.nodeId = [dict[@"node"] integerValue];
        
        self.title = dict[@"title"];
        self.content = dict[@"content"];
        
        NSMutableArray *repliesArray = [NSMutableArray new];
        for (NSDictionary *replyDict in dict[@"replies"]) {
            Reply *reply = [[Reply alloc] initWithReplyDict:replyDict];
            [repliesArray addObject:reply];
        }
        self.replies = repliesArray;
        
    }
    return self;
}

@end
