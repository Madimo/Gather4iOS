//
//  PostViewController.h
//  Gather
//
//  Created by Madimo on 14-6-20.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PostViewController;
@class Topic;
@class Node;

typedef NS_ENUM(NSUInteger, PostType) {
    PostTypeTopic,
    PostTypeReply,
};

@protocol PostViewControllerDelegate <NSObject>

@optional
- (void)postViewController:(PostViewController *)controller
      willPostWithPostType:(PostType)postType
                     title:(NSString *)title
                      node:(Node *)node
                   content:(NSString *)content;

- (void)postViewController:(PostViewController *)controller
  postCanceledWithPostType:(PostType)postType
                     title:(NSString *)title
                      node:(Node *)node
                   content:(NSString *)content;

@end

@interface PostViewController : UITableViewController

@property (nonatomic) PostType postType;
@property (nonatomic, strong) Topic *topic;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, weak) id<PostViewControllerDelegate> delegate;

@end
