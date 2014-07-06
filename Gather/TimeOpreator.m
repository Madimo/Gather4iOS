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
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.S"];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    });
    
    if (!date) {
        return nil;
    }
    
    return [formatter dateFromString:date];
}

+ (NSString *)convertStringFromDate:(NSDate *)date
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"M-d H:mm"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
    });
    
    if (!date) {
        return nil;
    }
    
    NSTimeInterval interval = abs([date timeIntervalSinceNow]);
    int time;
    if (interval < 120) {
        return @"Just now";
    } else if (interval < 3600) {
        return  [NSString stringWithFormat:@"%d mins ago", (int)(interval / 60)];
    } else if (interval < 3600 * 24) {
        time = (int)(interval / 3600);
        return  [NSString stringWithFormat:@"%d hour%@ ago", time, time > 1 ? @"s" : @""];
    } else if (interval < 3600 * 24 * 7) {
        time = (int)(interval / 3600 / 24);
        return  [NSString stringWithFormat:@"%d day%@ ago", time, time > 1 ? @"s" : @""];
    }

    return [formatter stringFromDate:date];
}

@end
