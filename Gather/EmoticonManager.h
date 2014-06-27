//
//  EmoticonManager.h
//  Gather
//
//  Created by Madimo on 6/26/14.
//  Copyright (c) 2014 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmoticonManager : NSObject

@property (strong, nonatomic, readonly) NSArray *emoticons;

+ (instancetype)manager;

- (NSString *)translateEmoticonName:(NSString *)content;

@end
