//
//  User.m
//  Gather
//
//  Created by Madimo on 14-5-15.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "User.h"
#import "TimeOpreator.h"

@implementation User

- (instancetype)initWithUserDict:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.userId = [dict[@"id"] integerValue];
        self.username = dict[@"username"];
        self.description = dict[@"description"];
        self.website = dict[@"website"];
        self.email = dict[@"email"];
        self.emailMD5 = [self.email MD5Digest];
        self.role = dict[@"role"];
        
        if (dict[@"created"] != [NSNull null]) {
            self.created = [TimeOpreator stringToDate:dict[@"created"]];
        }
    }
    return self;
}

+ (instancetype)userWithUserDict:(NSDictionary *)dict
{
    return [[User alloc] initWithUserDict:dict];
}

@end
