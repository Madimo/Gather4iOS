//
//  PostManager.m
//  Gather
//
//  Created by Madimo on 14-6-22.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "PostManager.h"
#import "GatherAPI.h"

@implementation PostManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)postTopicWithTitle:(NSString *)title
                    nodeId:(NSInteger)nodeId
                   content:(NSString *)content
                    images:(UIImage *)images
                   success:(void (^)(Topic *topic))success
                   failure:(void (^)(NSException *exception))failure
{
    GatherAPI *api = [GatherAPI sharedAPI];
    [api createTopicWithTitle:title
                      content:content
                       nodeId:nodeId
                      success:^(Topic *topic) {
                          if (success) {
                              success(topic);
                          }
                      }
                      failure:^(NSException *exception) {
                          if (failure) {
                              failure(exception);
                          }
                      }];
    
}

#pragma mark - Singleton

+ (instancetype)manager
{
    static PostManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[super allocWithZone:NULL] init];
    });
    return sharedObject;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self manager];
}


@end
