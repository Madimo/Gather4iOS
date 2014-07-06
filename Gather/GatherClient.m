//
//  GatherClient.m
//  Gather
//
//  Created by Madimo on 7/5/14.
//  Copyright (c) 2014 Madimo. All rights reserved.
//

#import "GatherClient.h"

#define kGatherAPIDomains   @"http://gather.whouz.com/api"
#define kKeychainIdentifier @"com.Madimo.Gather.Keychain"

@interface GatherClient ()
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *token;
@end

@implementation GatherClient

#pragma mark - Keychain

- (NSString *)username
{
    if (!_username) {
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainIdentifier
                                                                           accessGroup:nil];
        _token = [wrapper objectForKey:(__bridge id)(kSecAttrAccount)];
    }
    return _username;
}

- (NSString *)token
{
    if (!_token) {
        KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainIdentifier
                                                                           accessGroup:nil];
        _token = [wrapper objectForKey:(__bridge id)(kSecValueData)];
    }
    return _token;
}

- (void)saveUsername:(NSString *)username token:(NSString *)token
{
    self.username = username;
    self.token = token;
    
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainIdentifier
                                                                       accessGroup:nil];
    [wrapper setObject:username forKey:(__bridge id)(kSecAttrAccount)];
    [wrapper setObject:token forKey:(__bridge id)(kSecValueData)];
}

#pragma mark - GET & POST

- (NSURLSessionDataTask *)getPath:(NSString *)path
                       parameters:(NSDictionary *)parameters
                          success:(void(^)(NSURLSessionDataTask *task, NSDictionary *responseObject))success
                          failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    [serializer setValue:self.token forHTTPHeaderField:@"token"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = serializer;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager GET:[NSString stringWithFormat:@"%@%@", kGatherAPIDomains, path]
                                   parameters:parameters
                                      success:success
                                      failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postPath:(NSString *)path
                        parameters:(NSDictionary *)parameters
                           success:(void(^)(NSURLSessionDataTask *task, NSDictionary *responseObject))success
                           failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPRequestSerializer *serializer = [AFHTTPRequestSerializer serializer];
    [serializer setValue:self.token forHTTPHeaderField:@"token"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = serializer;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager POST:[NSString stringWithFormat:@"%@%@", kGatherAPIDomains, path]
                                    parameters:parameters
                                       success:success
                                       failure:failure];
    return task;
}

- (NSURLSessionDataTask *)postPath:(NSString *)path
                    JSONParameters:(NSDictionary *)parameters
                           success:(void(^)(NSURLSessionDataTask *task, NSDictionary *responseObject))success
                           failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    [serializer setValue:self.token forHTTPHeaderField:@"token"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = serializer;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSURLSessionDataTask *task = [manager POST:[NSString stringWithFormat:@"%@%@", kGatherAPIDomains, path]
                                    parameters:parameters
                                       success:success
                                       failure:failure];
    return task;
}

#pragma mark - Public method

- (BOOL)isLogined
{
    return self.token != nil && ![self.token isEqualToString:@""];
}

- (void)logout
{
    KeychainItemWrapper *wrapper = [[KeychainItemWrapper alloc] initWithIdentifier:kKeychainIdentifier
                                                                       accessGroup:nil];
    [wrapper resetKeychainItem];
    self.username = nil;
    self.token = nil;
}

- (NSURLSessionDataTask *)loginWithUsername:(NSString *)username
                                   password:(NSString *)password
                                    success:(void (^)())success
                                    failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{ @"username" : username,
                                  @"password" : password };
    
    return [self postPath:@"/account/authorize/"
               parameters:parameters
                  success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                      NSInteger code = [responseObject[@"code"] integerValue];
                      if (code == 200) {
                          [self saveUsername:username token:responseObject[@"token"]];
                          if (success) {
                              success();
                          }
                      } else {
                          NSError *error = [NSError errorWithDomain:NSOSStatusErrorDomain
                                                               code:code
                                                           userInfo:@{ NSLocalizedDescriptionKey : responseObject[@"msg"] }];
                          
                          if (failure) {
                              failure(error);
                          }
                      }
                  }
                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                      if (failure) {
                          NSLog(@"%@", error);
                          failure(error);
                      }
                  }];
}

- (NSURLSessionDataTask *)getTopicsInPage:(NSInteger)page
                                  orderBy:(GatherTopicOrderBy)orderBy
                                  success:(void (^)(NSArray *topics, NSInteger totalPages, NSInteger totalTopics))success
                                  failure:(void (^)(NSError *error))failure
{
    NSString *orderByParameter;
    switch (orderBy) {
        case GatherTopicOrderByCreatedAsc:
            orderByParameter = @"{\"order_by\":[{\"field\":\"created\",\"direction\":\"asc\"}]}";
            break;
        case GatherTopicOrderByCreatedDesc:
            orderByParameter = @"{\"order_by\":[{\"field\":\"created\",\"direction\":\"desc\"}]}";
            break;
        case GatherTopicOrderByUpdatedAsc:
            orderByParameter = @"{\"order_by\":[{\"field\":\"updated\",\"direction\":\"asc\"}]}";
            break;
        case GatherTopicOrderByUpdatedDesc:
            orderByParameter = @"{\"order_by\":[{\"field\":\"updated\",\"direction\":\"desc\"}]}";
            break;
        default:
            orderByParameter = @"{\"order_by\":[{\"field\":\"created\",\"direction\":\"desc\"}]}";
            break;
    }
    
    NSDictionary *parameters = @{ @"page" : @(page),
                                  @"q"    : orderByParameter };
    
    return [self getPath:@"/topic"
              parameters:parameters
                 success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                     if (!success)
                         return;
                     
                     NSInteger totalPage = [responseObject[@"total_pages"] integerValue];
                     NSInteger totalTopics = [responseObject[@"num_results"] integerValue];
                     
                     NSMutableArray *topics = [NSMutableArray new];
                     for (NSDictionary *dict in responseObject[@"objects"]) {
                         Topic *topic = [Topic topicWithTopicDict:dict];
                         [topics addObject:topic];
                     }
                     
                     success(topics, totalPage, totalTopics);
                 }
                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                     if (failure) {
                         failure(error);
                     }
                 }];
}

- (NSURLSessionDataTask *)getTopicById:(NSInteger)topicId
                               success:(void (^)(Topic *topic))success
                               failure:(void (^)(NSError *error))failure
{
    return [self getPath:[NSString stringWithFormat:@"/topic/%@", @(topicId)]
              parameters:nil
                 success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                     if (!success)
                         return;
                     
                     Topic *topic = [Topic topicWithTopicDict:responseObject];
                     success(topic);
                 }
                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                     if (failure) {
                         failure(error);
                     }
                 }];
}

- (NSURLSessionDataTask *)getReplisInTopic:(NSInteger)topicId
                                    inPage:(NSInteger)page
                                   success:(void (^)(NSArray *replies, NSInteger totalPages, NSInteger totalReplies))success
                                   failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{ @"page" : @(page) };
    
    return [self getPath:[NSString stringWithFormat:@"/topic/%@/replies", @(topicId)]
              parameters:parameters
                 success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                     if (!success) {
                         return;
                     }
                     
                     NSInteger totalPages = [responseObject[@"total_pages"] integerValue];
                     NSInteger totalReplies = [responseObject[@"num_results"] integerValue];
                     
                     NSMutableArray *replies = [NSMutableArray new];
                     for (NSDictionary *dict in responseObject[@"objects"]) {
                         Reply *reply = [Reply replyWithReplyDict:dict];
                         [replies addObject:reply];
                     }
                     
                     success(replies, totalPages, totalReplies);
                 }
                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                     if (failure) {
                         failure(error);
                     }
                 }];
}

- (void)getAllReplisInTopic:(NSInteger)topicId
                    success:(void (^)(NSArray *replies))success
                    failure:(void (^)(NSError *error))failure
{
    [self getReplisInTopic:topicId
                    inPage:1
                   success:^(NSArray *replies, NSInteger totalPages, NSInteger totalReplies) {
                       if (!success) {
                           return;
                       }
                       
                       dispatch_async(dispatch_get_global_queue(0, 0), ^{
                           dispatch_group_t group = dispatch_group_create();
                           
                           NSMutableArray *allReplies = [NSMutableArray new];
                           [allReplies addObjectsFromArray:replies];
                           
                           for (NSInteger i = 2; i <= totalPages; ++i) {
                               dispatch_group_enter(group);
                               [self getReplisInTopic:topicId
                                               inPage:i
                                              success:^(NSArray *replies, NSInteger totalPages, NSInteger totalReplies) {
                                                  [allReplies addObjectsFromArray:replies];
                                                  dispatch_group_leave(group);
                                              }
                                              failure:^(NSError *error) {
                                                  dispatch_group_leave(group);
                                              }];
                               dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                           }
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               success(allReplies);
                           });
                       });
                   }
                   failure:^(NSError *error) {
                       if (failure) {
                           failure(error);
                       }
                   }];
}

- (NSURLSessionDataTask *)getUserById:(NSInteger)userId
                              success:(void (^)(User *user))success
                              failure:(void (^)(NSError *error))failure
{
    return [self getPath:[NSString stringWithFormat:@"/account/%@", @(userId)]
              parameters:nil
                 success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                     if (!success)
                         return;
                     
                     User *user = [User userWithUserDict:responseObject];
                     success(user);
                 }
                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                     if (failure) {
                         failure(error);
                     }
                 }];
}

- (NSURLSessionDataTask *)getNodesInPage:(NSInteger)page
                                 success:(void (^)(NSArray *nodes, NSInteger totalPages, NSInteger totalNodes))success
                                 failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{ @"page" : @(page) };
    
    return [self getPath:@"/node"
              parameters:parameters
                 success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                     if (!success) {
                         return;
                     }
                     
                     NSInteger totalPages = [responseObject[@"total_pages"] integerValue];
                     NSInteger totalNodes = [responseObject[@"num_results"] integerValue];
                     
                     NSMutableArray *nodes = [NSMutableArray new];
                     for (NSDictionary *dict in responseObject[@"objects"]) {
                         Node *node = [Node nodeWithNodeDict:dict];
                         [nodes addObject:node];
                     }
                     
                     success(nodes, totalPages, totalNodes);
                 }
                 failure:^(NSURLSessionDataTask *task, NSError *error) {
                     if (failure) {
                         failure(error);
                     }
                 }];
}

- (NSURLSessionDataTask *)getNodeById:(NSInteger)nodeId
                              success:(void (^)(Node *node))success
                              failure:(void (^)(NSError *exception))failure
{
    return [self getPath:[NSString stringWithFormat:@"/node/%@", @(nodeId)]
              parameters:nil
                 success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                     if (!success) {
                         return;
                     }
                     
                     Node *node = [Node nodeWithNodeDict:responseObject];
                     success(node);
                 }
                 failure:^(NSURLSessionDataTask *task, NSError *error) {
              
                 }];
}

- (void)getAllNodesWithSuccess:(void (^)(NSArray *nodes))success
                       failure:(void (^)(NSError *error))failure
{
    [self getNodesInPage:1
                 success:^(NSArray *nodes, NSInteger totalPages, NSInteger totalNodes) {
                     if (!success) {
                         return;
                     }
                     
                     dispatch_async(dispatch_get_global_queue(0, 0), ^{
                         dispatch_group_t group = dispatch_group_create();
                         
                         NSMutableArray *allNodes = [NSMutableArray new];
                         [allNodes addObjectsFromArray:nodes];
                         
                         for (NSInteger i = 2; i <= totalPages; ++i) {
                             dispatch_group_enter(group);
                             [self getNodesInPage:i
                                          success:^(NSArray *nodes, NSInteger totalPages, NSInteger totalNodes) {
                                              [allNodes addObjectsFromArray:nodes];
                                              dispatch_group_leave(group);
                                          }
                                          failure:^(NSError *error) {
                                              dispatch_group_leave(group);
                                          }];
                             dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
                         }
                         
                         dispatch_async(dispatch_get_main_queue(), ^{
                             success(allNodes);
                         });
                     });
                }
                 failure:^(NSError *error) {
                     if (failure) {
                         failure(error);
                     }
                 }];
}

- (NSURLSessionDataTask *)createTopicWithTitle:(NSString *)title
                                       content:(NSString *)content
                                        nodeId:(NSInteger)nodeId
                                       success:(void (^)(Topic *topic))success
                                       failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{ @"title"   : title,
                                  @"content" : content,
                                  @"node_id" : @(nodeId) };
    
    return [self postPath:@"/topic"
           JSONParameters:parameters
                  success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                      if (!success) {
                          return;
                      }
                      
                      Topic *topic = [Topic topicWithTopicDict:responseObject];
                      success(topic);
                  }
                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                      if (failure) {
                          NSLog(@"%@", error);
                          failure(error);
                      }
                  }];
}

- (NSURLSessionDataTask *)createReplyWithTopicId:(NSInteger)topicId
                                         content:(NSString *)content
                                         success:(void (^)(Reply *reply))success
                                         failure:(void (^)(NSError *error))failure
{
    NSDictionary *parameters = @{ @"topic_id": @(topicId),
                                  @"content" : content };
    
    return [self postPath:@"/reply"
           JSONParameters:parameters
                  success:^(NSURLSessionDataTask *task, NSDictionary *responseObject) {
                      if (!success) {
                          return;
                      }
                      
                      Reply *reply = [Reply replyWithReplyDict:responseObject];
                      success(reply);
                  }
                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                      if (failure) {
                          NSLog(@"%@", error);
                          failure(error);
                      }
                  }];
}

#pragma mark - Singleton

+ (instancetype)client
{
    static GatherClient *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[super allocWithZone:NULL] init];
    });
    return sharedObject;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self client];
}

@end
