//
//  EmoticonManager.m
//  Gather
//
//  Created by Madimo on 6/26/14.
//  Copyright (c) 2014 Madimo. All rights reserved.
//

#import "EmoticonManager.h"
#import "Emoticon.h"

@interface EmoticonManager ()
@property (strong, nonatomic) NSDictionary *emoticonsDict;
@property (strong, nonatomic) NSArray *emoticons;
@end

@implementation EmoticonManager

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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Emoticons" ofType:@"plist"];
    NSDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    self.emoticonsDict = dict;
    NSMutableArray *emoticons = [NSMutableArray new];
    for (NSString *name in dict.allKeys) {
        Emoticon *emoticon = [Emoticon new];
        emoticon.name = name;
        emoticon.url = dict[name];
        NSString *emoticonPath = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        emoticon.emoticon = [UIImage imageWithContentsOfFile:emoticonPath];
        [emoticons addObject:emoticon];
    }
    self.emoticons = emoticons;
}

- (NSString *)translateEmoticonName:(NSString *)content
{
    NSMutableString *result = [content mutableCopy];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<#[0-9a-zA-z]+>"
                                                                           options:kNilOptions
                                                                             error:nil];
    
    NSTextCheckingResult *match = [regex firstMatchInString:result options:kNilOptions range:NSMakeRange(0, result.length)];
    while (match) {
        NSString *name;
        NSRange range = match.range;
        name = [result substringWithRange:range];
        name = [name substringWithRange:NSMakeRange(2, name.length - 3)];
        NSInteger length = 0;
        if ([self.emoticonsDict.allKeys containsObject:name]) {
            NSString *url = [NSString stringWithFormat:@" %@ ", self.emoticonsDict[name]];
            [result replaceCharactersInRange:match.range withString:url];
            length = url.length;
        }
        
        match = [regex firstMatchInString:result options:kNilOptions range:NSMakeRange(range.location + length, result.length - range.location - length)];
    }
    
    return result;
}

#pragma mark - Singleton

+ (instancetype)manager
{
    static EmoticonManager *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[super allocWithZone:NULL] init];
    });
    return sharedObject;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self manager];
}


@end
