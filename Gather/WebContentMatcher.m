//
//  WebContentMatcher.m
//  Gather
//
//  Created by Madimo on 14-5-15.
//  Copyright (c) 2014年 Madimo. All rights reserved.
//

#import "WebContentMatcher.h"
#import <RegexKitLite.h>

@interface WebContentMatcher ()
@property (strong, nonatomic) NSString *ContentHTML;
@end

@implementation WebContentMatcher

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *path;
        path = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"html"];
        self.ContentHTML = [[NSString alloc] initWithContentsOfFile:path
                                                           encoding:NSUTF8StringEncoding
                                                              error:nil];
        path = [[NSBundle mainBundle] pathForResource:@"style" ofType:@"css"];
        NSString *style = [[NSString alloc] initWithContentsOfFile:path
                                                          encoding:NSUTF8StringEncoding
                                                             error:nil];
        self.ContentHTML = [self.ContentHTML stringByReplacingOccurrencesOfString:@"{{ style }}"
                                                                       withString:style];
    }
    return self;
}

- (NSString *)ConvertToHTMLUsingContent:(NSString *)content
{
    NSMutableString *mContent = [content mutableCopy];
    NSMutableString *sContent = [content mutableCopy];
    NSString *HTML = [self.ContentHTML copy];
    
    [self ConvertBrUsingContent:mContent sContent:sContent];
    [self ConvertImgUsingContent:mContent sContent:sContent];

    
    while (1) {
        NSString *matched = [sContent stringByMatching:[self urlMatchRegex]];
        if (!matched)
            break;
        NSString *a = [NSString stringWithFormat:@"<a href=\"%@\">%@</a>", matched, matched];
        [mContent replaceOccurrencesOfString:matched
                                  withString:a
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, mContent.length)];
        [sContent replaceOccurrencesOfString:matched
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, sContent.length)];
    }
    
    HTML = [HTML stringByReplacingOccurrencesOfString:@"{{ content }}"
                                           withString:mContent];
    
    return HTML;
}

- (void)ConvertBrUsingContent:(NSMutableString *)mContent sContent:(NSMutableString *)sContent
{
    [mContent replaceOccurrencesOfString:@"\r\n"
                              withString:@"<br>"
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, mContent.length)];
    [sContent replaceOccurrencesOfString:@"\r\n"
                              withString:@" "
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, sContent.length)];
}

- (void)ConvertImgUsingContent:(NSMutableString *)mContent sContent:(NSMutableString *)sContent
{
    while (1) {
        NSString *matched = [sContent stringByMatching:[self imageMatchRegex]];
        if (!matched)
            break;

        NSString *img = [NSString stringWithFormat:@"<img class=\"content-img\" src=\"%@\"/>", matched];
        [mContent replaceOccurrencesOfString:matched
                                  withString:img
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, mContent.length)];
        [sContent replaceOccurrencesOfString:matched
                                  withString:@" "
                                     options:NSLiteralSearch
                                       range:NSMakeRange(0, sContent.length)];
    }
}


- (NSString *)imageMatchRegex
{
    //return [NSString stringWithFormat:@"%@.(jpeg|jpg|png)", [self urlMatchRegex]];
        return @"([hH][tT][tT][pP][sS]?:\\/\\/[^ ,'\">\\]\\)]*[^\\. ,'\">\\]\\)])[.](jpeg|jpg|png)";
}

- (NSString *)urlMatchRegex
{
    return @"(?i)\\b((?:https?:(?:/{1,3}|[a-z0-9%])|[a-z0-9.\\-]+[.](?:com|net|org|edu|gov|mil|aero|asia|biz|cat|coop|info|int|jobs|mobi|museum|name|post|pro|tel|travel|xxx|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cs|cu|cv|cx|cy|cz|dd|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|Ja|sk|sl|sm|sn|so|sr|ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw)/)(?:[^\\s()<>{}\\[\\]]+|\\([^\\s()]*?\\([^\\s()]+\\)[^\\s()]*?\\)|\\([^\\s]+?\\))+(?:\\([^\\s()]*?\\([^\\s()]+\\)[^\\s()]*?\\)|\\([^\\s]+?\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’])|(?:(?<!@)[a-z0-9]+(?:[.\\-][a-z0-9]+)*[.](?:com|net|org|edu|gov|mil|aero|asia|biz|cat|coop|info|int|jobs|mobi|museum|name|post|pro|tel|travel|xxx|ac|ad|ae|af|ag|ai|al|am|an|ao|aq|ar|as|at|au|aw|ax|az|ba|bb|bd|be|bf|bg|bh|bi|bj|bm|bn|bo|br|bs|bt|bv|bw|by|bz|ca|cc|cd|cf|cg|ch|ci|ck|cl|cm|cn|co|cr|cs|cu|cv|cx|cy|cz|dd|de|dj|dk|dm|do|dz|ec|ee|eg|eh|er|es|et|eu|fi|fj|fk|fm|fo|fr|ga|gb|gd|ge|gf|gg|gh|gi|gl|gm|gn|gp|gq|gr|gs|gt|gu|gw|gy|hk|hm|hn|hr|ht|hu|id|ie|il|im|in|io|iq|ir|is|it|je|jm|jo|jp|ke|kg|kh|ki|km|kn|kp|kr|kw|ky|kz|la|lb|lc|li|lk|lr|ls|lt|lu|lv|ly|ma|mc|md|me|mg|mh|mk|ml|mm|mn|mo|mp|mq|mr|ms|mt|mu|mv|mw|mx|my|mz|na|nc|ne|nf|ng|ni|nl|no|np|nr|nu|nz|om|pa|pe|pf|pg|ph|pk|pl|pm|pn|pr|ps|pt|pw|py|qa|re|ro|rs|ru|rw|sa|sb|sc|sd|se|sg|sh|si|sj|Ja|sk|sl|sm|sn|so|sr|ss|st|su|sv|sx|sy|sz|tc|td|tf|tg|th|tj|tk|tl|tm|tn|to|tp|tr|tt|tv|tw|tz|ua|ug|uk|us|uy|uz|va|vc|ve|vg|vi|vn|vu|wf|ws|ye|yt|yu|za|zm|zw)\\b/?(?!@)))";
}

#pragma mark - Singleton

+ (instancetype)matcher
{
    static WebContentMatcher *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[super allocWithZone:NULL] init];
    });
    return sharedObject;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self matcher];
}


@end
