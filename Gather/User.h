//
//  User.h
//  Gather
//
//  Created by Madimo on 14-5-15.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

@property (nonatomic) NSInteger userId;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *website;
@property (strong, nonatomic) NSString *emailMD5;
@property (strong, nonatomic) NSString *role;

+ (instancetype)unknownUser;

- (instancetype)initWithUserDict:(NSDictionary *)dict;

@end
