//
//  TimeOpreator.h
//  Gather
//
//  Created by Madimo on 14-5-25.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeOpreator : NSObject

+ (NSDate *)stringToDate:(NSString *)date;
+ (NSString *)convertStringFromDate:(NSDate *)date;

@end
