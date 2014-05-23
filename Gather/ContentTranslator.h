//
//  ContentTranslator.h
//  Gather
//
//  Created by Madimo on 14-5-23.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContentTranslator : NSObject

+ (instancetype)sharedTranslator;

- (NSString *)convertToHTMLUsingString:(NSString *)string;
- (NSString *)convertToWebUsingReplies:(NSArray *)replies;

@end
