//
//  TimeOpreator.m
//  Gather
//
//  Created by Madimo on 14-5-25.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "TimeOpreator.h"

@implementation TimeOpreator

+ (NSDate *)stringToDate:(NSString *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"E, dd LLL yyyy HH:mm:ss O"];
    return [formatter dateFromString:date];
}

+ (NSString *)convertStringFromDate:(NSDate *)date
{
    NSTimeInterval interval = abs([date timeIntervalSinceNow]);
    int time;
    if (interval < 120)
        return @"just now";
    if (interval < 3600) {
        time = (int)(interval / 60 + 0.5);
        return  [NSString stringWithFormat:@"%d minute%@ ago", time, time > 1 ? @"s" : @""];
    }
    if (interval < 3600 * 24) {
        time = (int)(interval / 3600 + 0.5);
        return  [NSString stringWithFormat:@"%d hour%@ ago", time, time > 1 ? @"s" : @""];
    }
    if (interval < 3600 * 24 * 7) {
        time = (int)(interval / 3600 / 24 + 0.5);
        return  [NSString stringWithFormat:@"%d day%@ ago", time, time > 1 ? @"s" : @""];
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"M/d/yy HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    return [formatter stringFromDate:date];
}

@end
