//
//  Node.m
//  Gather
//
//  Created by Madimo on 14-6-16.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "Node.h"

@implementation Node

- (instancetype)initWithId:(NSInteger)nodeId
                      name:(NSString *)name
                      slug:(NSString *)slug
               description:(NSString *)description
                      icon:(NSString *)icon
{
    self = [super init];
    if (self) {
        self.nodeId = nodeId;
        self.name = name;
        self.slug = slug;
        self.description = description;
        self.icon = icon;
    }
    return self;
}

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

@end
