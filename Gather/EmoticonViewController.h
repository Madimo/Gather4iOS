//
//  EmoticonViewController.h
//  Gather
//
//  Created by Madimo on 6/26/14.
//  Copyright (c) 2014 Madimo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EmoticonViewController;
@class Emoticon;

@protocol EmoticonViewControllerDelegate <NSObject>

@optional
- (void)emoticonViewController:(EmoticonViewController *)controller didSelectEmoticon:(Emoticon *)emoticon;

@end

@interface EmoticonViewController : UICollectionViewController

@property (weak, nonatomic) id<EmoticonViewControllerDelegate> delegate;

@end
