//
//  NSTextView+TextGetter.h
//  HKSnippet
//
//  Created by Hunk on 16/2/4.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HKTextResult;

@interface NSTextView (Snippet)

- (NSInteger)currentCurseLocation;
- (HKTextResult *)textResultOfCurrentLine;

@end