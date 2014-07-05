//
//  Reply.m
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "Reply.h"
#import "User.h"
#import "TimeOpreator.h"

@implementation Reply

- (instancetype)initWithReplyDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.replyId = [dict[@"id"] integerValue];
        self.authorId = [dict[@"author_id"] integerValue];
        self.topicId = [dict[@"topic_id"] integerValue];
        
        self.content = dict[@"content"];
        
        if (dict[@"created"] != [NSNull null])
            self.created = [TimeOpreator stringToDate:dict[@"created"]];
        if (dict[@"changed"] != [NSNull null])
            self.changed = [TimeOpreator stringToDate:dict[@"changed"]];
        
        if (dict[@"author"] != [NSNull null]) {
            self.author = [[User alloc] initWithUserDict:dict[@"author"]];
        }
    }
    return self;
}

+ (instancetype)replyWithReplyDict:(NSDictionary *)dict
{
    return [[Reply alloc] initWithReplyDict:dict];
}

@end
