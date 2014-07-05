//
//  Node.m
//  Gather
//
//  Created by Madimo on 14-6-16.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "Node.h"

@implementation Node

- (instancetype)initWithNodeDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.nodeId = [dict[@"id"] integerValue];
        self.name = dict[@"name"];
        self.slug = dict[@"slug"];
        self.description = dict[@"description"];
        self.icon = dict[@"icon"];
    }
    return self;
}

+ (instancetype)nodeWithNodeDict:(NSDictionary *)dict
{
    return [[Node alloc] initWithNodeDict:dict];
}

+ (instancetype)unknownNode
{
    static Node *node;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        node = [[Node alloc] init];
        node.nodeId = 0;
        node.name = @"Unknown";
    });
    return node;
}

@end
