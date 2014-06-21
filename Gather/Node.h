//
//  Node.h
//  Gather
//
//  Created by Madimo on 14-6-16.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Node : NSObject

@property (nonatomic) NSInteger nodeId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *slug;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *icon;

+ (instancetype)unknownNode;

- (instancetype)initWithId:(NSInteger)nodeId
                      name:(NSString *)name
                      slug:(NSString *)slug
               description:(NSString *)description
                      icon:(NSString *)icon;

- (instancetype)initWithNodeDict:(NSDictionary *)dict;

@end
