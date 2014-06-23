//
//  GatherAPI.h
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Topic.h"
#import "Reply.h"
#import "User.h"
#import "Node.h"

@interface GatherAPI : NSObject

- (BOOL)isLogined;

- (NSURLSessionDataTask *)loginWithUsername:(NSString *)username
                                   password:(NSString *)password
                                    success:(void (^)())success
                                    failure:(void (^)(NSException * exception))failure;

- (NSURLSessionDataTask *)getTopicsInPage:(NSInteger)page
                                  success:(void (^)(NSArray *topics, NSInteger totalPage, NSInteger totalTopics))success
                                  failure:(void (^)(NSException * exception))failure;

- (NSURLSessionDataTask *)getTopicById:(NSInteger)topicId
                               success:(void (^)(Topic *topic))success
                               failure:(void (^)(NSException * exception))failure;

- (NSURLSessionDataTask *)getUserById:(NSInteger)userId
                              success:(void (^)(User *user))success
                              failure:(void (^)(NSException * exception))failure;

- (NSURLSessionDataTask *)refreshUserById:(NSInteger)userId
                                  success:(void (^)(User *user))success
                                  failure:(void (^)(NSException * exception))failure;

- (NSURLSessionDataTask *)getNodesInPage:(NSInteger)page
                                 success:(void (^)(NSArray *nodes, NSInteger totalPage, NSInteger totalNode))success
                                 failure:(void (^)(NSException * exception))failure;

- (NSURLSessionDataTask *)getNodeById:(NSInteger)nodeId
                              success:(void (^)(Node *node))success
                              failure:(void (^)(NSException * exception))failure;

- (NSURLSessionDataTask *)getAllNodesWithSuccess:(void (^)(NSArray *nodes))success
                                         failure:(void (^)(NSException * exception))failure;

- (NSURLSessionDataTask *)createTopicWithTitle:(NSString *)title
                                       content:(NSString *)content
                                        nodeId:(NSInteger)nodeId
                                       success:(void (^)(Topic *topic))success
                                       failure:(void (^)(NSException * exception))failure;

- (NSURLSessionDataTask *)createReplyWithTopicId:(NSInteger)topicId
                                         content:(NSString *)content
                                         success:(void (^)(Reply *reply))success
                                         failure:(void (^)(NSException * exception))failure;

+ (instancetype)sharedAPI;

@end
