//
//  NSString+TextGetter.h
//  HKSnippet
//
//  Created by Hunk on 16/2/4.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HKTextResult;

@interface NSString (Snippet)

- (HKTextResult *)textResultOfCurrentLineAtLocation:(NSInteger)location;

@end