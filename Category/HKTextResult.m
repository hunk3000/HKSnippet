//
//  HKTextResult.m
//  HKSnippet
//
//  Created by Hunk on 16/2/4.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import "HKTextResult.h"

@implementation HKTextResult

- (instancetype)initWithRange:(NSRange)range
                       string:(NSString *)string {
    if (self = [super init]) {
        _range = range;
        _string = string;
    }
    return self;
}

@end
