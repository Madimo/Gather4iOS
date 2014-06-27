//
//  Emoticon.h
//  Gather
//
//  Created by Madimo on 6/26/14.
//  Copyright (c) 2014 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Emoticon : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) UIImage *emoticon;

@end
