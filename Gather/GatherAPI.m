//
//  GatherAPI.m
//  Gather
//
//  Created by Madimo on 14-5-14.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "GatherAPI.h"
#import <AFNetworking.h>
#import <KeychainItemWrapper.h>

#define GATHER_API_LOGIN @"http://gather.whouz.com/api/user/authorize/"
#define GATHER_API_TOPIC @"http://gather.whouz.com/api/topic/"
#define GATHER_API_USER  @"http://gather.whouz.com/api/user/"
#define GATHER_API_NODE  @"http://gather.whouz.com/api/node/"

#define KEYCHAIN_IDENTIFIER @"com.Madimo.Gather.Keychain"

@interface GatherAPI ()
@property (strong, nonatomic) NSString *username;
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

#pragma mark - Keychain

- (NSString *)username
{
    if (!_username) {
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_IDENTIFIER accessGroup:nil];
        _token = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    }
    return _username;
}

- (NSString *)token
{
    if (!_token) {
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_IDENTIFIER accessGroup:nil];
        _token = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    }
    return _token;
}

- (void)saveUsername:(NSString *)username token:(NSString *)token
{
    self.username = username;
    self.token = token;
    
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_IDENTIFIER accessGroup:nil];
    [wrapper setObject:username forKey:(__bridge id)(kSecAttrAccount)];
    [wrapper setObject:token forKey:(__bridge id)(kSecValueData)];
}

#pragma mark - Public method

- (BOOL)isLogined
{
    return self.token != nil && ![self.token isEqualToString:@""];
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
                                               
                                               [self saveUsername:username token:result[@"token"]];
                                               success();
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
              
              NSOperationQueue *queue = [[NSOperationQueue alloc] init];
              
              for (NSInteger i = 0; i < topics.count; ++i) {
                  NSString *url = [NSString stringWithFormat:@"%@%@", GATHER_API_USER, @(((Topic *)topics[i]).authorId)];
                  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                  AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                  op.responseSerializer = [AFJSONResponseSerializer serializer];
                  [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                User *author = [[User alloc] initWithUserDict:responseObject[@"user"]];
                                                ((Topic *)topics[i]).author = author;
                                            }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                User *author = [User unknownUser];
                                                ((Topic *)topics[i]).author = author;
                                            }];
                  [queue addOperations:@[op] waitUntilFinished:YES];
              }
              
              for (NSInteger i = 0; i < topics.count; ++i) {
                  NSString *url = [NSString stringWithFormat:@"%@%@", GATHER_API_NODE, @(((Topic *)topics[i]).nodeId)];
                  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                  AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                  op.responseSerializer = [AFJSONResponseSerializer serializer];
                  [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                Node *node = [[Node alloc] initWithNodeDict:responseObject[@"node"]];
                                                ((Topic *)topics[i]).node = node;
                                                if (i == topics.count - 1) {
                                                    success(topics, totalPage, totalTopics);
                                                }
                                            }
                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                Node *node = [Node unknownNode];
                                                ((Topic *)topics[i]).node = node;
                                                if (i == topics.count - 1) {
                                                    success(topics, totalPage, totalTopics);
                                                }
                                            }];
                  [queue addOperations:@[op] waitUntilFinished:YES];
              }
              
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
//                                              NSInteger totalPage = [result[@"total_page"] integerValue];
//                                              NSInteger totalTopics = [result[@"total"] integerValue];
//                                              NSMutableArray *topics = [NSMutableArray new];
//                                              for (NSDictionary *topicDict in result[@"topics"]) {
//                                                  Topic *topic = [[Topic alloc] initWithTopicDict:topicDict];
//                                                  [topics addObject:topic];
//                                              }
//                                              
//                                              __block NSInteger finishCount = 0;
//                                              __block void (^blk)() = ^{
//                                                  [self getUserById:((Topic *)topics[finishCount]).authorId
//                                                            success:^(User *user) {
//                                                                ((Topic *)topics[finishCount]).author = user;
//                                                                finishCount++;
//                                                                if (finishCount == topics.count) {
//                                                                    success(topics, totalPage, totalTopics);
//                                                                    blk = nil;
//                                                                }
//                                                                else {
//                                                                    blk();
//                                                                }
//                                                            }
//                                                            failure:^(NSException *exception) {
//                                                                ((Topic *)topics[finishCount]).author = [User unknownUser];
//                                                                finishCount++;
//                                                                if (finishCount == topics.count) {
//                                                                    success(topics, totalPage, totalTopics);
//                                                                    blk = nil;
//                                                                }
//                                                                else {
//                                                                    blk();
//                                                                }
//                                                            }
//                                                  ];
//                                              };
//                                              
//                                              blk();
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

- (NSURLSessionDataTask *)getTopicById:(NSInteger)topicId
                               success:(void (^)(Topic *topic))success
                               failure:(void (^)(NSException * exception))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@%ld", GATHER_API_TOPIC, (long)topicId];
    debugLog(@"%@", url);
    NSURLSessionDataTask *task = [manager GET:url
                                   parameters:nil
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
          
          if (!success)
              return;
          
          @try {
              NSDictionary *result = (NSDictionary *)responseObject;
              Topic *topic = [[Topic alloc] initWithTopicDict:result[@"topic"]];
              [self getUserById:topic.authorId
                        success:^(User *user) {
                            topic.author = user;
                            
                            if (topic.replies.count <= 0) {
                                success(topic);
                                return;
                            }
                            
                            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                            
                            for (NSInteger i = 0; i < topic.replies.count; ++i) {
                                NSString *url = [NSString stringWithFormat:@"%@%@", GATHER_API_USER, @(((Reply *)(topic.replies[i])).authorId)];
                                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                                AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                                op.responseSerializer = [AFJSONResponseSerializer serializer];
                                [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                              User *author = [[User alloc] initWithUserDict:responseObject[@"user"]];
                                                              ((Reply *)(topic.replies[i])).author = author;
                                                              if (i == topic.replies.count - 1) {
                                                                  success(topic);
                                                              }
                                                          }
                                                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                              User *author = [User unknownUser];
                                                              ((Reply *)(topic.replies[i])).author = author;
                                                              if (i == topic.replies.count - 1) {
                                                                  success(topic);
                                                              }
                                                          }];
                                [queue addOperations:@[op] waitUntilFinished:YES];
                            }
                        }
                        failure:^(NSException *exception) {
                            topic.author = [User unknownUser];
                        }
               ];
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

//- (NSURLSessionDataTask *)getTopicById:(NSInteger)topicId
//                               success:(void (^)(Topic *topic))success
//                               failure:(void (^)(NSException * exception))failure
//{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    NSString *url = [NSString stringWithFormat:@"%@%ld", GATHER_API_TOPIC, (long)topicId];
//    debugLog(@"%@", url);
//    NSURLSessionDataTask *task = [manager GET:url
//                                   parameters:nil
//                                      success:^(NSURLSessionDataTask *task, id responseObject) {
//                                          
//                                          if (!success)
//                                              return;
//                                          
//                                          @try {
//                                              NSDictionary *result = (NSDictionary *)responseObject;
//                                              Topic *topic = [[Topic alloc] initWithTopicDict:result[@"topic"]];
//                                              [self getUserById:topic.authorId
//                                                        success:^(User *user) {
//                                                            topic.author = user;
//                                                            
//                                                            if (topic.replies.count <= 0) {
//                                                                success(topic);
//                                                                return;
//                                                            }
//                                                            
//                                                            __block NSInteger finishCount = 0;
//                                                            __block void (^blk)() = ^{
//                                                                [self getUserById:((Reply *)topic.replies[finishCount]).authorId
//                                                                          success:^(User *user) {
//                                                                              ((Reply *)topic.replies[finishCount]).author = user;
//                                                                              finishCount++;
//                                                                              if (finishCount == topic.replies.count) {
//                                                                                  success(topic);
//                                                                                  blk = nil;
//                                                                              }
//                                                                              else {
//                                                                                  blk();
//                                                                              }
//                                                                          }
//                                                                          failure:^(NSException *exception) {
//                                                                              ((Reply *)topic.replies[finishCount]).author = [User unknownUser];
//                                                                              finishCount++;
//                                                                              if (finishCount == topic.replies.count) {
//                                                                                  success(topic);
//                                                                                  blk = nil;
//                                                                              }
//                                                                              else {
//                                                                                  blk();
//                                                                              }
//                                                                          }
//                                                                ];
//                                                            };
//                                                            
//                                                            blk();
//                                                        }
//                                                        failure:^(NSException *exception) {
//                                                            topic.author = [User unknownUser];
//                                                        }
//                                               ];
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

- (NSURLSessionDataTask *)getNodesInPage:(NSInteger)page
                                 success:(void (^)(NSArray *nodes, NSInteger totalPage, NSInteger totalNode))success
                                 failure:(void (^)(NSException * exception))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *parameters = @{ @"token"   : self.token,
                                  @"page"    : @(page) };
    NSURLSessionDataTask *task = [manager GET:GATHER_API_NODE
                                   parameters:parameters
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          
                                          if (!success)
                                              return;
                                          
                                          @try {
                                              NSDictionary *result = (NSDictionary *)responseObject;
                                              NSMutableArray *nodes = [NSMutableArray new];
                                              for (NSDictionary *dict in result[@"nodes"]) {
                                                  Node *node = [[Node alloc] initWithNodeDict:dict];
                                                  [nodes addObject:node];
                                              }
                                              NSInteger totalPage = [result[@"total_page"] integerValue];
                                              NSInteger totalNode = [result[@"total"] integerValue];
                                              success(nodes, totalPage, totalNode);
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

- (NSURLSessionDataTask *)getNodesById:(NSInteger)nodeId
                               success:(void (^)(Node *node))success
                               failure:(void (^)(NSException * exception))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"%@%@", GATHER_API_NODE, @(nodeId)];
    NSURLSessionDataTask *task = [manager GET:url
                                   parameters:nil
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          
                                          if (!success)
                                              return;
                                          
                                          @try {
                                              NSDictionary *result = (NSDictionary *)responseObject;
                                              
                                              Node *node = [[Node alloc] initWithNodeDict:result[@"node"]];
                                
                                              success(node);
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

- (NSURLSessionDataTask *)getAllNodesWithSuccess:(void (^)(NSArray *nodes))success
                                         failure:(void (^)(NSException * exception))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLSessionDataTask *task = [manager GET:GATHER_API_NODE
                                   parameters:nil
                                      success:^(NSURLSessionDataTask *task, id responseObject) {
                                          
                                          if (!success)
                                              return;
                                          
                                          @try {
                                              NSDictionary *result = (NSDictionary *)responseObject;
                                              NSMutableArray *nodes = [NSMutableArray new];
                                              for (NSDictionary *dict in result[@"nodes"]) {
                                                  Node *node = [[Node alloc] initWithNodeDict:dict];
                                                  [nodes addObject:node];
                                              }
                                              NSInteger totalPage = [result[@"total_page"] integerValue];
                                              
                                              NSOperationQueue *queue = [[NSOperationQueue alloc] init];
                                              
                                              for (NSInteger i = 1; i <= totalPage; ++i) {
                                                  NSString *url = [NSString stringWithFormat:@"%@%@", GATHER_API_NODE, @(i)];
                                                  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
                                                  AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                                                  op.responseSerializer = [AFJSONResponseSerializer serializer];
                                                  [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                                    NSDictionary *result = (NSDictionary *)responseObject;
                                                                                    NSMutableArray *nodes = [NSMutableArray new];
                                                                                    for (NSDictionary *dict in result[@"nodes"]) {
                                                                                        Node *node = [[Node alloc] initWithNodeDict:dict];
                                                                                        [nodes addObject:node];
                                                                                    }
                                                                                    if (i == totalPage) {
                                                                                        success(nodes);
                                                                                    }
                                                                                }
                                                                            failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                                if (i == totalPage) {
                                                                                    success(nodes);
                                                                                }
                                                                            }];
                                                  [queue addOperations:@[op] waitUntilFinished:YES];
                                              }
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

- (NSURLSessionDataTask *)createTopicWithTitle:(NSString *)title
                                       content:(NSString *)content
                                        nodeId:(NSInteger)nodeId
                                       success:(void (^)(Topic *topic))success
                                       failure:(void (^)(NSException * exception))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSDictionary *parameters = @{ @"token"   : self.token,
                                  @"title"   : title,
                                  @"content" : content,
                                  @"node"    : @(nodeId) };
    NSURLSessionDataTask *task = [manager POST:GATHER_API_TOPIC
                                    parameters:parameters
                                       success:^(NSURLSessionDataTask *task, id responseObject) {
                                           
                                       }
                                       failure:^(NSURLSessionDataTask *task, NSError *error) {
                                           
                                       }
                                  ];
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

#pragma mark - Private method

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
