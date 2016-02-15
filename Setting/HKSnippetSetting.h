//
//  HKSnippetSetting.h
//  HKSnippet
//
//  Created by Hunk on 16/2/4.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kHKSnippetsKey;

@interface HKSnippetSetting : NSObject

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) NSMutableDictionary *snippets;

+ (HKSnippetSetting *)defaultSetting;
- (void)sychronizeSetting;
- (void)resetToDefaultSetting;


@end
