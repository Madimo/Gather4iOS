//
//  ContentTranslator.m
//  Gather
//
//  Created by Madimo on 14-5-23.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "ContentTranslator.h"
#import "Reply.h"
#import "Topic.h"
#import "TimeOpreator.h"

@interface ContentTranslator ()
@property (strong, nonatomic) NSString *contentHTML;
@property (strong, nonatomic) NSString *replyTemplate;
@property (strong, nonatomic) NSString *topicTemplate;
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
        
        path = [[NSBundle mainBundle] pathForResource:@"topic" ofType:@"html"];
        self.topicTemplate = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
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
    
    NSRegularExpression *atRegex = [NSRegularExpression regularExpressionWithPattern:@"@\\w+"
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:nil];
    checkResult = [atRegex firstMatchInString:result
                                      options:kNilOptions
                                        range:NSMakeRange(0, result.length)];
    
    while (checkResult.range.location != NSNotFound && checkResult.range.length != 0) {
        
        NSString *converted = @"";
        NSRange range = checkResult.range;
        range.location += 1;
        range.length -= 1;
        NSString *string = [result substringWithRange:range];
        converted = [NSString stringWithFormat:@"<a class=\"reply_body_a\" href=\"gather:at:%@\">@%@</a>", string, string];
        [result replaceCharactersInRange:checkResult.range withString:converted];
        
        checkResult = [atRegex firstMatchInString:result
                                          options:kNilOptions
                                            range:NSMakeRange(checkResult.range.location + converted.length,
                                                                   result.length - checkResult.range.location - converted.length)];
    }
    
    
    NSRegularExpression *numberRegex = [NSRegularExpression regularExpressionWithPattern:@"#[1-9]\\d*"
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
    
    checkResult = [numberRegex firstMatchInString:result
                                          options:kNilOptions
                                            range:NSMakeRange(0, result.length)];
    
    while (checkResult.range.location != NSNotFound && checkResult.range.length != 0) {
        
        NSString *converted = @"";
        NSRange range = checkResult.range;
        range.location += 1;
        range.length -= 1;
        NSString *string = [result substringWithRange:range];
        converted = [NSString stringWithFormat:@"<a class=\"reply_body_a\" href=\"gather:reply:%@\">#%@</a>", string, string];
        [result replaceCharactersInRange:checkResult.range withString:converted];
        
        checkResult = [numberRegex firstMatchInString:result
                                              options:kNilOptions
                                                range:NSMakeRange(checkResult.range.location + converted.length,
                                                                   result.length - checkResult.range.location - converted.length)];
    }
    
    return result;
}

- (NSString *)convertToWebUsingTopic:(Topic *)topic
{
    NSMutableString *result = [self.contentHTML mutableCopy];
    
    NSMutableString *topicTemplate = [self.topicTemplate mutableCopy];
    
//    [topicTemplate replaceOccurrencesOfString:@"{{ topic_title }}"
//                                   withString:topic.title
//                                      options:NSLiteralSearch
//                                        range:NSMakeRange(0, topicTemplate.length)];
    
    [topicTemplate replaceOccurrencesOfString:@"{{ topic_author }}"
                                   withString:topic.author.username
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, topicTemplate.length)];
    
    [topicTemplate replaceOccurrencesOfString:@"{{ avatar }}"
                                   withString:[NSString stringWithFormat:@"http://gravatar.whouz.com/avatar/%@?s=100", topic.author.emailMD5]
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, topicTemplate.length)];
    
    [topicTemplate replaceOccurrencesOfString:@"{{ user_id }}"
                                   withString:[NSString stringWithFormat:@"%ld", (long)topic.author.userId]
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, topicTemplate.length)];
    
    [topicTemplate replaceOccurrencesOfString:@"{{ topic_time }}"
                                   withString:[TimeOpreator convertStringFromDate:topic.created]
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, topicTemplate.length)];
    
    [topicTemplate replaceOccurrencesOfString:@"{{ topic_body }}"
                                   withString:[self convertToHTMLUsingString:topic.content]
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, topicTemplate.length)];
    
    [result replaceOccurrencesOfString:@"{{ topic }}"
                            withString:topicTemplate
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, result.length)];
    
    NSMutableString *reply_list = [NSMutableString new];
    NSInteger count = 0;
    for (Reply *reply in topic.replies) {
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
        
        [replyTemplate replaceOccurrencesOfString:@"{{ reply_body }}"
                                       withString:[self convertToHTMLUsingString:reply.content]
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [replyTemplate replaceOccurrencesOfString:@"\r\n"
                                       withString:@"<br>"
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [reply_list appendString:replyTemplate];
    }
    
    
    [result replaceOccurrencesOfString:@"{{ reply_list }}"
                            withString:reply_list
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, result.length)];
    
    // NSLog(@"%@", result);
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
