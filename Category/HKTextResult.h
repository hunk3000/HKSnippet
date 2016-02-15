//
//  HKTextResult.h
//  HKSnippet
//
//  Created by Hunk on 16/2/4.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKTextResult : NSObject

@property (nonatomic, assign) NSRange range;
@property (nonatomic, copy) NSString *string;

- (instancetype)initWithRange:(NSRange)range
                       string:(NSString *)string;

@end
