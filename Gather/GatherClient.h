//
//  GatherClient.h
//  Gather
//
//  Created by Madimo on 7/5/14.
//  Copyright (c) 2014 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GatherModels.h"

typedef NS_ENUM(NSUInteger, GatherTopicOrderBy) {
    GatherTopicOrderByCreatedAsc,
    GatherTopicOrderByCreatedDesc,
    GatherTopicOrderByUpdatedAsc,
    GatherTopicOrderByUpdatedDesc,
};

@interface GatherClient : NSObject

+ (instancetype)client;

- (BOOL)isLogined;

- (void)logout;

- (NSURLSessionDataTask *)loginWithUsername:(NSString *)username
                                   password:(NSString *)password
                                    success:(void (^)())success
                                    failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getTopicsInPage:(NSInteger)page
                                  orderBy:(GatherTopicOrderBy)orderBy
                                  success:(void (^)(NSArray *topics, NSInteger totalPages, NSInteger totalTopics))success
                                  failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getTopicById:(NSInteger)topicId
                               success:(void (^)(Topic *topic))success
                               failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getReplisInTopic:(NSInteger)topicId
                                    inPage:(NSInteger)page
                                   success:(void (^)(NSArray *replies, NSInteger totalPages, NSInteger totalReplies))success
                                   failure:(void (^)(NSError *error))failure;

- (void)getAllReplisInTopic:(NSInteger)topicId
                    success:(void (^)(NSArray *replies))success
                    failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getUserById:(NSInteger)userId
                              success:(void (^)(User *user))success
                              failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getNodesInPage:(NSInteger)page
                                 success:(void (^)(NSArray *nodes, NSInteger totalPages, NSInteger totalNodes))success
                                 failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getNodeById:(NSInteger)nodeId
                              success:(void (^)(Node *node))success
                              failure:(void (^)(NSError *exception))failure;

- (void)getAllNodesWithSuccess:(void (^)(NSArray *nodes))success
                       failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)createTopicWithTitle:(NSString *)title
                                       content:(NSString *)content
                                        nodeId:(NSInteger)nodeId
                                       success:(void (^)(Topic *topic))success
                                       failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)createReplyWithTopicId:(NSInteger)topicId
                                         content:(NSString *)content
                                         success:(void (^)(Reply *reply))success
                                         failure:(void (^)(NSError *error))failure;

@end
