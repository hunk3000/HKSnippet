//
//  HKSnippetSetting.m
//  HKSnippet
//
//  Created by Hunk on 16/2/4.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import "HKSnippetSetting.h"

NSString * const kHKSnippetsKey = @"snippets";
NSString * const kHKSnippetEnabled = @"enabled";

@implementation HKSnippetSetting

- (instancetype)init {
    self = [super init];
    if (self) {
        _systemTriggers = @[@"@autoreleasepool",
                            @"@catch",
                            @"@class",
                            @"@compatibility_alias",
                            @"@defs",
                            @"@dynamic",
                            @"@encode",
                            @"@end",
                            @"@finally",
                            @"@import",
                            @"@interface",
                            @"@implementation",
                            @"@optional",
                            @"@package",
                            @"@private",
                            @"@property",
                            @"@protected",
                            @"@protocol",
                            @"@public",
                            @"@required",
                            @"@selector",
                            @"@synchronized",
                            @"@synthesize",
                            @"@throw"
                            ];
        _snippets = [NSMutableDictionary dictionaryWithDictionary:[self defaultConfig]];
    }
    return self;
}

+ (HKSnippetSetting *)defaultSetting {
    static HKSnippetSetting *defaultSetting;
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        defaultSetting = [[[self class] alloc] init];
        
        NSDictionary *defaults = @{kHKSnippetEnabled: @YES,
                                   kHKSnippetsKey : defaultSetting.snippets ?: @{}};
        [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    });
    return defaultSetting;
}

- (BOOL)enabled {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kHKSnippetEnabled];
}

- (void)setEnabled:(BOOL)enabled {
    [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:kHKSnippetEnabled];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)sychronizeSetting {
    NSMutableDictionary *snippets = [[self class] defaultSetting].snippets;
    [[NSUserDefaults standardUserDefaults] setObject:snippets forKey:kHKSnippetsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resetToDefaultSetting {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kHKSnippetsKey];
    [[NSUserDefaults standardUserDefaults] setObject:@{} forKey:kHKSnippetsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _snippets = nil;
    _snippets = [NSMutableDictionary dictionaryWithDictionary:[self defaultConfig]];
    [[NSUserDefaults standardUserDefaults] setObject:[self defaultConfig] forKey:kHKSnippetsKey];
    [self setEnabled:YES];
}

- (NSDictionary *)defaultConfig {
    NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:kHKSnippetsKey];
    if (0 < config.count) {
        return config;
    }

    NSString *selfPath = @"~/Library/Application Support/Developer/Shared/Xcode/Plug-ins/HKSnippet.xcplugin";
    NSBundle *selfBundle = [NSBundle bundleWithPath:[selfPath stringByExpandingTildeInPath]];
    NSString *default_snippet_file = [selfBundle pathForResource:@"default_snippets"
                                                          ofType:@"plist"];
    config = [NSDictionary dictionaryWithContentsOfFile:default_snippet_file];
    return config;
}

@end