//
//  User.m
//  Gather
//
//  Created by Madimo on 14-5-15.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithUserDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.userId = [dict[@"id"] integerValue];
        self.username = dict[@"username"];
        self.description = dict[@"description"];
        self.website = dict[@"website"];
        self.emailMD5 = dict[@"email_md5"];
        self.role = dict[@"role"];
    }
    return self;
}

+ (instancetype)unknownUser
{
    static User *user;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [[User alloc] init];
        user.userId = 0;
        user.username = @"Unknown";
    });
    return user;
}

@end
