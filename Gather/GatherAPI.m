//
//  GatherAPI.m
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "GatherAPI.h"

#define GATHER_API_LOGIN @"http://gather.whouz.com/api/user/authorize/"
#define GATHER_API_TOPIC @"http://gather.whouz.com/api/topic/"
#define GATHER_API_USER  @"http://gather.whouz.com/api/user/"

@interface GatherAPI ()
@property (strong, nonatomic) NSString *token;
@property (strong, nonatomic) NSMutableDictionary *userList;
@property (strong, nonatomic) NSMutableDictionary *nodeList;
@end

@implementation GatherAPI

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.userList = [NSMutableDictionary new];
        self.nodeList = [NSMutableDictionary new];
    }
    return self;
}

- (void)setToken:(NSString *)token
{
    _token = token;
    // todo: save token
}

- (NSURLSessionDataTask *)loginWithUsername:(NSString *)username
                                   password:(NSString *)password
                                    success:(void (^)())success
                                    failure:(void (^)(NSException * exception))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *parameters = @{ @"username" : username,
                                  @"password" : password };
    NSURLSessionDataTask *task = [manager POST:GATHER_API_LOGIN
                                    parameters:parameters
                                       success:^(NSURLSessionDataTask *task, id responseObject) {

                                           if (!success)
                                               return;

                                           @try {
                                               NSDictionary *result = (NSDictionary *)responseObject;
                                               if (result[@"msg"]) {
                                                   NSException *exception = [[NSException alloc] initWithName:@"Login Failed"
                                                                                                       reason:result[@"msg"]
                                                                                                     userInfo:nil];
                                                   failure(exception);
                                                   return;
                                               }
                                               
                                               self.token = result[@"token"];

                                           }
                                           @catch (NSException *exception) {
                                               if (failure)
                                                   failure(exception);
                                           }
                                       }
                                       failure:^(NSURLSessionDataTask *task, NSError *error) {

                                           if (!failure)
                                               return;

                                           NSException *exception = CreateNetworkErrorException(task, error);
                                           failure(exception);
                                       }];
    return task;
}

- (NSURLSessionDataTask *)getTopicsInPage:(NSInteger)page
                                  success:(void (^)(NSArray *topics, NSInteger totalPage, NSInteger totalTopics))success
                                  failure:(void (^)(NSException * exception))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *parameters = @{ @"page" : [NSNumber numberWithInteger:page] };
    NSURLSessionDataTask *task = [manager GET:GATHER_API_TOPIC
                                   parameters:parameters
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          
                                          if (!success)
                                              return;
                                          
                                          @try {
                                              NSDictionary *result = (NSDictionary *)responseObject;
                                              NSInteger totalPage = [result[@"total_page"] integerValue];
                                              NSInteger totalTopics = [result[@"total"] integerValue];
                                              NSMutableArray *topics = [NSMutableArray new];
                                              for (NSDictionary *topicDict in result[@"topics"]) {
                                                  Topic *topic = [[Topic alloc] initWithTopicDict:topicDict];
                                                  [topics addObject:topic];
                                              }
                                              
                                              __block NSInteger finishCount = 0;
                                              __block void (^blk)() = ^{
                                                  [self getUserById:((Topic *)topics[finishCount]).authorId
                                                            success:^(User *user) {
                                                                ((Topic *)topics[finishCount]).author = user;
                                                                finishCount++;
                                                                if (finishCount == topics.count) {
                                                                    success(topics, totalPage, totalTopics);
                                                                    blk = nil;
                                                                }
                                                                else {
                                                                    blk();
                                                                }
                                                            }
                                                            failure:^(NSException *exception) {
                                                                ((Topic *)topics[finishCount]).author = [User unknownUser];
                                                                finishCount++;
                                                                if (finishCount == topics.count) {
                                                                    success(topics, totalPage, totalTopics);
                                                                    blk = nil;
                                                                }
                                                                else {
                                                                    blk();
                                                                }
                                                            }
                                                  ];
                                              };
                                              
                                              blk();
                                          }
                                          @catch (NSException *exception) {
                                              if (failure)
                                                  failure(exception);
                                          }
                                      }
                                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          
                                          if (!failure)
                                              return;
                                          
                                          NSException *exception = CreateNetworkErrorException(task, error);
                                          failure(exception);
                                      }];
    return task;
}

- (NSURLSessionDataTask *)getTopicById:(NSInteger)topicId
                               success:(void (^)(Topic *topic))success
                               failure:(void (^)(NSException * exception))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@%ld", GATHER_API_TOPIC, (long)topicId];
    NSURLSessionDataTask *task = [manager GET:url
                                   parameters:nil
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          
                                          if (!success)
                                              return;
                                          
                                          @try {
                                              NSDictionary *result = (NSDictionary *)responseObject;
                                              Topic *topic = [[Topic alloc] initWithTopicDict:result];
                                              success(topic);
                                          }
                                          @catch (NSException *exception) {
                                              if (failure)
                                                  failure(exception);
                                          }
                                      }
                                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          
                                          if (!failure)
                                              return;
                                          
                                          NSException *exception = CreateNetworkErrorException(task, error);
                                          failure(exception);
                                      }];
    return task;
}

- (NSURLSessionDataTask *)getUserById:(NSInteger)userId
                              success:(void (^)(User *user))success
                              failure:(void (^)(NSException * exception))failure
{
    if (!success)
        return nil;
    
    User *user;
    NSNumber *idNumber = [NSNumber numberWithInteger:userId];
    if (self.userList[idNumber]) {
        user = self.userList[idNumber];
        success(user);
    } else {
        return [self refreshUserById:userId
                             success:^(User *user) {
                                 success(user);
                             }
                             failure:^(NSException *exception) {
                                 if (failure)
                                     failure(exception);
                             }
        ];
    }
    
    return nil;
}

- (NSURLSessionDataTask *)refreshUserById:(NSInteger)userId
                                  success:(void (^)(User *user))success
                                  failure:(void (^)(NSException * exception))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@%ld", GATHER_API_USER, (long)userId];
    NSURLSessionDataTask *task = [manager GET:url
                                   parameters:nil
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          
                                          if (!success)
                                              return;
                                          
                                          @try {
                                              NSDictionary *result = (NSDictionary *)responseObject;
                                              User *user = [[User alloc] initWithUserDict:result[@"user"]];
                                              self.userList[[NSNumber numberWithInteger:userId]] = user;
                                              success(user);
                                          }
                                          @catch (NSException *exception) {
                                              if (failure)
                                                  failure(exception);
                                          }
                                      }
                                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                                          
                                          if (!failure)
                                              return;
                                          
                                          NSException *exception = CreateNetworkErrorException(task, error);
                                          failure(exception);
                                      }];
    return task;
}

//- (NSURLSessionDataTask *)getTopicsInPage:(NSInteger)page
//                                  success:(void (^)(NSArray *topics, NSInteger totalPage, NSInteger totalTopics))success
//                                  failure:(void (^)(NSException * exception))failure
//{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSDictionary *parameters = @{ @"page" : [NSNumber numberWithInteger:page] };
//    NSURLSessionDataTask *task = [manager GET:GATHER_API_TOPIC
//                                   parameters:parameters
//                                      success:^(NSURLSessionDataTask *task, id responseObject) {
//                                          
//                                          if (!success)
//                                              return;
//                                          
//                                          @try {
//                                              NSDictionary *result = (NSDictionary *)responseObject;
//
//                                          }
//                                          @catch (NSException *exception) {
//                                              if (failure)
//                                                  failure(exception);
//                                          }
//                                      }
//                                      failure:^(NSURLSessionDataTask *task, NSError *error) {
//                                          
//                                          if (!failure)
//                                              return;
//                                          
//                                          NSException *exception = CreateNetworkErrorException(task, error);
//                                          failure(exception);
//                                      }];
//    return task;
//}

NSException *CreateNetworkErrorException(NSURLSessionDataTask *task, NSError *error)
{
    NSDictionary *userinfo = @{ @"task"  : task,
                                @"error" : error };
    NSException *exception = [NSException exceptionWithName:@"Network Error"
                                                     reason:@"Please check your network and try again"
                                                   userInfo:userinfo];
    return exception;
}

#pragma mark - Singleton

+ (instancetype)sharedAPI
{
    static GatherAPI *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[super allocWithZone:NULL] init];
    });
    return sharedObject;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedAPI];
}


@end
