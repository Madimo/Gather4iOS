//
//  PostViewController.h
//  Gather
//
//  Created by Madimo on 14-6-20.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, PostType) {
    PostTypeTopic,
    PostTypeReply,
};

@interface PostViewController : UITableViewController

@property (nonatomic) PostType postType;
@property (nonatomic, strong) NSString *nodeName;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;

@end
