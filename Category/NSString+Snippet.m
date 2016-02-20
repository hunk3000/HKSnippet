//
//  NSString+TextGetter.m
//  HKSnippet
//
//  Created by Hunk on 16/2/4.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import "NSString+Snippet.h"
#import "HKTextResult.h"

@implementation NSString (Snippet)

- (HKTextResult *)textResultOfCurrentLineAtLocation:(NSInteger)location {
    NSInteger curseLocation = location;
    NSRange range = NSMakeRange(0, curseLocation);
    NSRange currentLineRange = [self rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
                                                     options:NSBackwardsSearch range:range];
    NSString *line = nil;
    if (currentLineRange.location != NSNotFound) {
        NSRange lineRange = NSMakeRange(currentLineRange.location + 1, curseLocation - currentLineRange.location - 1);
        if (lineRange.location < [self length] && NSMaxRange(lineRange) < [self length]) {
            line = [self substringWithRange:lineRange];
            line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            return [[HKTextResult alloc] initWithRange:lineRange string:line];
        }
    }
    return nil;
}

@end