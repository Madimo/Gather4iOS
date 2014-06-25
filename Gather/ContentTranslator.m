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

#pragma mark - Initilize

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
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
    
    path = [[NSBundle mainBundle] pathForResource:@"reply" ofType:@"html"];
    self.replyTemplate = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    path = [[NSBundle mainBundle] pathForResource:@"topic" ofType:@"html"];
    self.topicTemplate = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
}

#pragma mark - Public method

- (NSString *)convertToHTMLUsingString:(NSString *)string
{
    NSString *result = string;
    
    result = [self matchingAtUseSourceString:result];
    result = [self matchingNumberUseSourceString:result];
    result = [self matchingUrlUsingSourceString:result];

    return result;
}

- (NSString *)convertToWebUsingTopic:(Topic *)topic
{
    NSString *result = [self convertTopic:topic];
    
    NSLog(@"%@", result);
    
    return result;
}

#pragma mark - Matching

- (NSString *)matchingUrlUsingSourceString:(NSString *)source
{
    NSMutableString *result = [source mutableCopy];
    NSDataDetector *linkDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSTextCheckingResult *checkResult = [linkDetector firstMatchInString:result options:kNilOptions range:NSMakeRange(0, result.length)];
    
    while (checkResult.range.location != NSNotFound && checkResult.range.length != 0) {
        NSString *converted = @"";
        if (checkResult.resultType == NSTextCheckingTypeLink) {
            NSString *urlString = [checkResult.URL absoluteString];
            if ([self isImageFileUrl:urlString]) {
                NSString *format = @"<img class=\"reply_body_img\" onload=\"replyImgOnload(this)\" src=\"%@\"/>";
                converted = [NSString stringWithFormat:format, urlString];
            } else {
                NSString *format = @"<a class=\"reply_body_a\" href=\"%@\" onclick=\"stopBubble()\">%@</a>";
                converted = [NSString stringWithFormat:format, urlString, urlString];
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

- (NSString *)matchingAtUseSourceString:(NSString *)source
{
    NSMutableString *result = [source mutableCopy];
    
    NSRegularExpression *atRegex = [NSRegularExpression regularExpressionWithPattern:@"@[a-zA-Z0-9]+"
                                                                             options:NSRegularExpressionCaseInsensitive
                                                                               error:nil];
    NSTextCheckingResult *checkResult = [atRegex firstMatchInString:result
                                                            options:kNilOptions
                                                              range:NSMakeRange(0, result.length)];
    
    while (checkResult.range.location != NSNotFound && checkResult.range.length != 0) {
        
        NSString *converted = @"";
        NSRange range = checkResult.range;
        range.location += 1;
        range.length -= 1;
        NSString *string = [result substringWithRange:range];
        NSString *format = @"<a class=\"reply_body_a\" href=\"gather:at:%@\" onclick=\"stopBubble()\">@%@</a>";
        converted = [NSString stringWithFormat:format, string, string];
        [result replaceCharactersInRange:checkResult.range withString:converted];
        
        checkResult = [atRegex firstMatchInString:result
                                          options:kNilOptions
                                            range:NSMakeRange(checkResult.range.location + converted.length,
                                                              result.length - checkResult.range.location - converted.length)];
    }
    
    return result;
}

- (NSString *)matchingNumberUseSourceString:(NSString *)source
{
    NSMutableString *result = [source mutableCopy];
    
    NSRegularExpression *numberRegex = [NSRegularExpression regularExpressionWithPattern:@"#[1-9]\\d*"
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:nil];
    
    NSTextCheckingResult *checkResult = [numberRegex firstMatchInString:result
                                                                options:kNilOptions
                                                                  range:NSMakeRange(0, result.length)];
    
    while (checkResult.range.location != NSNotFound && checkResult.range.length != 0) {
        
        NSString *converted = @"";
        NSRange range = checkResult.range;
        range.location += 1;
        range.length -= 1;
        NSString *string = [result substringWithRange:range];
        NSString *format = @"<a class=\"reply_body_a\" onclick=\"jumpToFloor('F%@')\" href=\"#F%@\">#%@</a>";
        converted = [NSString stringWithFormat:format, string, string, string];
        [result replaceCharactersInRange:checkResult.range withString:converted];
        
        checkResult = [numberRegex firstMatchInString:result
                                              options:kNilOptions
                                                range:NSMakeRange(checkResult.range.location + converted.length,
                                                                  result.length - checkResult.range.location - converted.length)];
    }
    
    return result;
}

- (BOOL)isImageFileUrl:(NSString *)url
{
    NSArray *array = [url componentsSeparatedByString:@"."];
    NSArray *filetypes = @[@"jpg", @"jpeg", @"gif", @"png"];
    return [filetypes containsObject:array.lastObject];
}

- (NSMutableString *)filterXSS:(NSString *)string
{
    NSMutableString *result = [string mutableCopy];
    
    [result replaceOccurrencesOfString:@"<"
                            withString:@"&lt;"
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, result.length)];
    
    [result replaceOccurrencesOfString:@">"
                            withString:@"&gt;"
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, result.length)];
    
    return result;
}

#pragma mark - Convert

- (NSString *)convertTopic:(Topic *)topic
{
    NSMutableString *result = [self.contentHTML mutableCopy];
    
    NSMutableString *topicTemplate = [self.topicTemplate mutableCopy];
    
    [topicTemplate replaceOccurrencesOfString:@"{{ topic_author }}"
                                   withString:[self filterXSS:topic.author.username]
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, topicTemplate.length)];
    
    [topicTemplate replaceOccurrencesOfString:@"{{ avatar }}"
                                   withString:[NSString stringWithFormat:@"http://gravatar.whouz.com/avatar/%@?s=100", topic.author.emailMD5]
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, topicTemplate.length)];
    
    [topicTemplate replaceOccurrencesOfString:@"{{ user_id }}"
                                   withString:[NSString stringWithFormat:@"%@", @(topic.author.userId)]
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, topicTemplate.length)];
    
    [topicTemplate replaceOccurrencesOfString:@"{{ topic_time }}"
                                   withString:[TimeOpreator convertStringFromDate:topic.created]
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, topicTemplate.length)];
    
    NSMutableString *content;
    if ([topic.content isEqualToString:@""])
        content = [self filterXSS:topic.title];
    else
        content = [self filterXSS:topic.content];
    
    [content replaceOccurrencesOfString:@"\r\n"
                             withString:@" <br> "
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, content.length)];
    
    [content replaceOccurrencesOfString:@"\n"
                             withString:@" <br> "
                                options:NSLiteralSearch
                                  range:NSMakeRange(0, content.length)];
    
    [topicTemplate replaceOccurrencesOfString:@"{{ topic_body }}"
                                   withString:[self convertToHTMLUsingString:content]
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, topicTemplate.length)];
    
    [result replaceOccurrencesOfString:@"{{ topic }}"
                            withString:topicTemplate
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, result.length)];
    
    [result replaceOccurrencesOfString:@"{{ reply_list }}"
                            withString:[self convertReplies:topic.replies]
                               options:NSLiteralSearch
                                 range:NSMakeRange(0, result.length)];
    
    return result;
}

- (NSString *)convertReplies:(NSArray *)replies
{
    NSMutableString *reply_list = [NSMutableString new];
    NSInteger count = 0;
    for (Reply *reply in replies) {
        count++;
        
        NSMutableString *replyTemplate = [self.replyTemplate mutableCopy];
        
        [replyTemplate replaceOccurrencesOfString:@"{{ reply_id }}"
                                       withString:[NSString stringWithFormat:@"%@", @(count - 1)]
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [replyTemplate replaceOccurrencesOfString:@"{{ user_id }}"
                                       withString:[NSString stringWithFormat:@"%@", @(reply.author.userId)]
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
                                       withString:[NSString stringWithFormat:@"%@", @(count)]
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [replyTemplate replaceOccurrencesOfString:@"{{ reply_author }}"
                                       withString:[self filterXSS:reply.author.username]
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        NSMutableString *content = [self filterXSS:reply.content];
        
        [content replaceOccurrencesOfString:@"\r\n"
                                 withString:@" <br> "
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, content.length)];
        
        [content replaceOccurrencesOfString:@"\n"
                                 withString:@" <br> "
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, content.length)];
        
        [replyTemplate replaceOccurrencesOfString:@"{{ reply_body }}"
                                       withString:[self convertToHTMLUsingString:content]
                                          options:NSLiteralSearch
                                            range:NSMakeRange(0, replyTemplate.length)];
        
        [reply_list appendString:replyTemplate];
    }
    
    return reply_list;
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
