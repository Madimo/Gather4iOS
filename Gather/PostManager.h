//
//  PostManager.h
//  Gather
//
//  Created by Madimo on 14-6-22.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Topic;
@class Reply;

@interface PostManager : NSObject

- (void)postTopicWithTitle:(NSString *)title
                    nodeId:(NSInteger)nodeId
                   content:(NSString *)content
                    images:(UIImage *)images
                   success:(void (^)(Topic *topic))success
                   failure:(void (^)(NSError *error))failure;

- (void)postReplyWithTopicId:(NSInteger)topicId
                     content:(NSString *)content
                      images:(UIImage *)images
                     success:(void (^)(Reply *reply))success
                     failure:(void (^)(NSError *error))failure;

+ (instancetype)manager;

@end
