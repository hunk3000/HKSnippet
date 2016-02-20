//
//  NSTextView+TextGetter.m
//  HKSnippet
//
//  Created by Hunk on 16/2/4.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import "NSTextView+Snippet.h"
#import "NSString+Snippet.h"

@implementation NSTextView (Snippet)

- (NSInteger)currentCurseLocation {
    return [[self selectedRanges][0] rangeValue].location;
}

- (HKTextResult *)textResultOfCurrentLine {
    return [self.textStorage.string textResultOfCurrentLineAtLocation:[self currentCurseLocation]];
}

@end