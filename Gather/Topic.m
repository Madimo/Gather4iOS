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
        self.topicId = [dict[@"id"] integerValue];
        self.authorId = [dict[@"author"] integerValue];
        self.nodeId = [dict[@"node"] integerValue];
        
        self.title = dict[@"title"];
        self.content = dict[@"content"];
        self.replyCount = [dict[@"repliy_count"] integerValue];
        
        NSMutableArray *repliesArray = [NSMutableArray new];
        for (NSDictionary *replyDict in dict[@"replies"]) {
            Reply *reply = [[Reply alloc] initWithReplyDict:replyDict];
            [repliesArray addObject:reply];
        }
        self.replies = repliesArray;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"E, dd LLL yyyy HH:mm:ss O"];
        
        if (dict[@"created"] != [NSNull null])
            self.created = [formatter dateFromString:dict[@"created"]];
        if (dict[@"updated"] != [NSNull null])
            self.updated = [formatter dateFromString:dict[@"updated"]];
        if (dict[@"changed"] != [NSNull null])
            self.changed = [formatter dateFromString:dict[@"changed"]];}
    
    return self;
}

@end
