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
        _snippets = [NSMutableDictionary dictionaryWithDictionary:[self defaultConfig]];
    }
    return self;
}

+ (HKSnippetSetting *)defaultSetting {
    static HKSnippetSetting *defaultSetting;
    static dispatch_once_t once;
    dispatch_once(&once, ^ {
        defaultSetting = [[HKSnippetSetting alloc] init];
        
        NSDictionary *defaults = @{kHKSnippetEnabled: @YES,
                                   kHKSnippetsKey : defaultSetting.snippets ? defaultSetting.snippets : @{}};
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
    NSMutableDictionary *snippets = [HKSnippetSetting defaultSetting].snippets;
    [[NSUserDefaults standardUserDefaults] setObject:snippets forKey:kHKSnippetsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)resetToDefaultSetting {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kHKSnippetsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    _snippets = nil;
    _snippets = [NSMutableDictionary dictionaryWithDictionary:[self defaultConfig]];
    [[NSUserDefaults standardUserDefaults] setObject:[self defaultConfig] forKey:kHKSnippetsKey];
    [self setEnabled:YES];
}

- (NSDictionary *)defaultConfig {
    NSDictionary *config = [[NSUserDefaults standardUserDefaults] objectForKey:kHKSnippetsKey];
    if (config.count > 0) {
        return config;
    }
    
    config = @{

/* Properties */
@"@ps" :
@"@property (strong) <#type#> *<#value#>;",

@"@prs" :
@"@property (strong, readonly) <#type#> *<#value#>;",

@"@pns" :
@"@property (nonatomic, strong) <#type#> *<#value#>;",

@"@prns" :
@"@property (nonatomic, strong, readonly) <#type#> *<#value#>;",

@"@pw" :
@"@property (weak) <#type#> *<#value#>;",

@"@prw" :
@"@property (weak, readonly) <#type#> *<#value#>;",

@"@pnw" :
@"@property (nonatomic, weak) <#type#> *<#value#>;",

@"@prnw" :
@"@property (nonatomic, weak, readonly) <#type#> *<#value#>;",

@"@pc" :
@"@property (copy) <#type#> *<#value#>;",

@"@prc" :
@"@property (copy, readonly) <#type#> *<#value#>;",

@"@pnc" :
@"@property (nonatomic, copy) <#type#> *<#value#>;",

@"@prnc" :
@"@property (nonatomic, copy, readonly) <#type#> *<#value#>;",

@"@pa" :
@"@property (assign) <#type#> <#value#>;",

@"@pra" :
@"@property (assign, readonly) <#type#> <#value#>;",

@"@pna" :
@"@property (nonatomic, assign) <#type#> <#value#>;",

@"@prna" :
@"@property (nonatomic, assign, readonly) <#type#> <#value#>;",

/* Fast Snippets */
@"@cs" :
@"static NSString * const <#name#> = @\"<#value#>\";",

@"@log" :
@"NSLog(@\"<#format#>\",<#data#>);",

@"@ws" :
@"__weak typeof(self) weakSelf = self;",

@"@ss" :
@"__strong typeof(weakSelf) strongSelf = weakSelf;",

@"@mk" :
@"#pragma mark - <#section title#>",

@"@pmk" :
@"#pragma mark - Private Method",

@"@lmk" :
@"#pragma mark - LifeCycle",

@"@gmk" :
@"#pragma mark - Getters & Setters",

@"@init" :
@"\
- (instancetype)init {\n\
    self = [super init];\n\
    if (self) {\n\
        <#statements#>\n\
    }\n\
    return self;\n\
}",

@"@de" :
@"\
- (void)dealloc {\n\
    [[NSNotificationCenter defaultCenter] removeObserver:self];\n\
}",

@"@ff" :
@"- (<#type#> *)<#name#> {\n\
    if(!_<#name#>) {\n\
        <#Init Code#>\n\
    }\n\
    return _<#name#>;\n\
}",

@"@fv" :
@"- (UIView *)<#name#> {\n\
    if(!_<#name#>) {\n\
        _<#name#> = [UIView new];\n\
        _<#name#>.backgroundColor = <#color#>;\n\
    }\n\
    return _<#name#>;\n\
}",

@"@fl" :
@"- (UILabel *)<#name#> {\n\
    if(!_<#name#>) {\n\
        _<#name#> = [UILabel new];\n\
        _<#name#>.backgroundColor = [UIColor clearColor];\n\
        _<#name#>.textAlignment = NSTextAlignmentCenter;\n\
        _<#name#>.numberOfLines = 0;\n\
        _<#name#>.textColor = <#color#>;\n\
        _<#name#>.font = <#font#>;\n\
        _<#name#>.text = <#text#>;\n\
    }\n\
    return _<#name#>;\n\
}",

@"@fi" :
@"- (UIImageView *)<#name#> {\n\
    if(!_<#name#>) {\n\
        _<#name#> = [UIImageView new];\n\
        _<#name#>.layer.cornerRadius = <#radius#>;\n\
        _<#name#>.layer.masksToBounds = YES;\n\
        _<#name#>.backgroundColor = [UIColor clearColor];\n\
        _<#name#>.image = <#image#>;\n\
    }\n\
    return _<#name#>;\n\
}",

@"@fb" :
@"- (UIButton *)<#name#> {\n\
    if(!_<#name#>) {\n\
        _<#name#> = [UIButton new];\n\
        _<#name#>.layer.cornerRadius = <#radius#>;\n\
        _<#name#>.layer.masksToBounds = YES;\n\
        _<#name#>.backgroundColor = [UIColor clearColor];\n\
        [_<#name#> setTitleColor:<#title color#> forState:UIControlStateNormal];\n\
        [_<#name#> setTitle:<# title #> forState:UIControlStateNormal];\n\
        [_<#name#> setImage:<#image#> forState:UIControlStateNormal];\n\
    }\n\
    return _<#name#>;\n\
}",

@"@ft" :
@"- (UITableView *)<#name#> {\n\
    if(!_<#name#>) {\n\
        _<#name#> = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];\n\
        _<#name#>.backgroundColor = [UIColor clearColor];\n\
        _<#name#>.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);\n\
        _<#name#>.separatorStyle = UITableViewCellSeparatorStyleSingleLine;\n\
        _<#name#>.separatorColor = <#color#>;\n\
        _<#name#>.delegate = <#table delegate#>;\n\
        _<#name#>.dataSource = <#table datasource#>;\n\
\n\
        [_<#name#> registerClass:[<#class name#> class] forCellReuseIdentifier:<#cellId#>];\n\
    }\n\
    return _<#name#>;\n\
}",

@"@lv" :
@"- (void)loadView {\n\
    [super loadView];\n\
\n\
}",

@"@ls" :
@"- (void)layoutSubviews {\n\
    [super layoutSubviews];\n\
    CGFloat w = self.frame.size.width;\n\
    CGFloat h = self.frame.size.height;\n\
    <#set subview frames#>\n\
}",

@"@vl" :
@"- (void)viewWillLayoutSubviews {\n\
    [super viewWillLayoutSubviews];\n\
    CGFloat w = self.view.frame.size.width;\n\
    CGFloat h = self.view.frame.size.height;\n\
    <# set subview frames #>\n\
}",

@"@tdd" :
@"#pragma mark - UITableViewDataSource\n\
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {\n\
    return <#rows#>;\n\
}\n\
\n\
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {\n\
\n\
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:<#CellId#>];\n\
    \n\
    return cell;\n\
}\n\
\n\
#pragma mark - UITableViewDelegate\n\
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {\n\
    return <#height#>;\n\
}\n\
\n\
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {\n\
    [tableView deselectRowAtIndexPath:indexPath animated:YES];\n\
    \n\
}\n\
"
};
    return config;
}


@end
