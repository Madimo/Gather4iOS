//
//  NodeChosenViewController.h
//  Gather
//
//  Created by Madimo on 14-6-22.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NodeChosenViewController;

@protocol NodeChosenViewControllerDelegate <NSObject>

@optional
- (void)nodeChosenViewController:(NodeChosenViewController *)controller
            didSelectItemAtIndex:(NSInteger)index;

@end

@interface NodeChosenViewController : UITableViewController

@property (weak, nonatomic) id<NodeChosenViewControllerDelegate> delegate;
@property (strong, nonatomic) NSArray *nodes;
@property (nonatomic) NSInteger selectedItem;

@end
