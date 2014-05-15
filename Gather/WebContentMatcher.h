//
//  WebContentMatcher.h
//  Gather
//
//  Created by Madimo on 14-5-15.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebContentMatcher : NSObject

+ (instancetype)matcher;

- (NSString *)ConvertToHTMLUsingContent:(NSString *)content;

@end
