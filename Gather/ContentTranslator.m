//
//  ContentTranslator.m
//  Gather
//
//  Created by Madimo on 14-5-23.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "ContentTranslator.h"
#import "Reply.h"
#import "TimeOpreator.h"

@interface ContentTranslator ()
@property (strong, nonatomic) NSString *contentHTML;
@property (strong, nonatomic) NSString *replyTemplate;
@end

@implementation ContentTranslator

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path;
        path = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"html"];
        self.contentHTML = [[NSString alloc] initWithContentsOfFile:path
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];
        
        path = [[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"];
        NSString *style = [[NSString alloc] initWithContentsOfFile:path
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
        self.contentHTML = [self.contentHTML stringByReplacingOccurrencesOfString:@"{{ style }}"
                                                                       withString:style];
        
//        path = [[NSBundle mainBundle] pathForResource:@"script" ofType:@"js"];
//        NSString *script = [[NSString alloc] initWithContentsOfFile:path
//                                                           encoding:NSUTF8StringEncoding
//                                                              error:nil];
//        self.contentHTML = [self.contentHTML stringByReplacingOccurrencesOfString:@"{{ script }}"
//                                                                       withString:script];
        
        path = [[NSBundle mainBundle] pathForResource:@"reply" ofType:@"html"];
        self.replyTemplate = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    }
    return self;
}

- (NSString *)convertToHTMLUsingString:(NSString *)string
{
    NSMutableString *result = [string mutableCopy];
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSTextCheckingResult *checkResult = [linkDetector firstMatchInString:result options:kNilOptions range:NSMakeRange(0, result.length)];
    
    while (checkResult.range.location != NSNotFound && checkResult.range.length != 0) {
        NSString *converted = @"";
        if (checkResult.resultType == NSTextCheckingTypeLink) {
            NSString *urlString = [checkResult.URL absoluteString];
            if ([self isImageFileUrl:urlString]) {
                converted = [NSString stringWithFormat:@"<img class=\"reply_body_img\" src=\"%@\">", urlString];
            } else {
                converted = [NSString stringWithFormat:@"<a class=\"reply_body_a\" href=\"%@\">%@</a>", urlString, urlString];
            }
            [result replaceCharactersInRange:checkResult.range withString:converted];
        }
        checkResult = [linkDetector firstMatchInString:result
                                               options:kNilOptions
                                                 range:NSMakeRange(checkResult.range.location + converted.length,
                                                                   result.length - checkResult.range.location - converted.length)];
    }

    return result;
}

- (NSString *)convertToWebUsingReplies:(NSArray *)replies
{
    NSMutableString *result = [self.contentHTML mutableCopy];
    
    NSMutableString *body = [NSMutableString new];
    NSInteger count = 0;
    for (Reply *reply in replies) {
        count++;
        
        NSMutableString *replyTemplate = [self.replyTemplate mutableCopy];
        
        [replyTemplate replaceOccurrencesOfString:@"{{ reply_id }}"
                                       withString:[NSString stringWithFormat:@"%ld", (long)count - 1]
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [replyTemplate replaceOccurrencesOfString:@"{{ user_id }}"
                                       withString:[NSString stringWithFormat:@"%ld", (long)reply.author.userId]
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [replyTemplate replaceOccurrencesOfString:@"{{ avatar }}"
                                       withString:[NSString stringWithFormat:@"http://gravatar.whouz.com/avatar/%@?s=100", reply.author.emailMD5]
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [replyTemplate replaceOccurrencesOfString:@"{{ reply_time }}"
                                       withString:[TimeOpreator convertStringFromDate:reply.created]
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [replyTemplate replaceOccurrencesOfString:@"{{ reply_number }}"
                                       withString:[NSString stringWithFormat:@"#%ld", (long)count]
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [replyTemplate replaceOccurrencesOfString:@"{{ reply_author }}"
                                       withString:reply.author.username
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        NSString *converted = [self convertToHTMLUsingString:reply.content];
        [replyTemplate replaceOccurrencesOfString:@"{{ reply_body }}"
                                       withString:converted
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [replyTemplate replaceOccurrencesOfString:@"\r\n"
                                       withString:@"<br>"
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [body appendString:replyTemplate];
    }
    
    
    [result replaceOccurrencesOfString:@"{{ reply_list }}"
                            withString:body
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, result.length)];
    
    NSLog(@"%@", result);
    return result;
}

- (BOOL)isImageFileUrl:(NSString *)url
{
    NSArray *fileTypes = @[[url substringWithRange:NSMakeRange(url.length - 4, 4)].lowercaseString,
                           [url substringWithRange:NSMakeRange(url.length - 5, 5)].lowercaseString];
    if ([fileTypes[0] isEqualToString:@".jpg"] ||
        [fileTypes[0] isEqualToString:@".png"] ||
        [fileTypes[1] isEqualToString:@".jpeg"]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - Singleton

+ (instancetype)sharedTranslator
{
    static ContentTranslator *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[super allocWithZone:NULL] init];
    });
    return sharedObject;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self sharedTranslator];
}


@end
