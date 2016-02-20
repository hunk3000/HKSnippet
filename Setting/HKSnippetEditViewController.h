//
//  HKSnippetEditViewController.h
//  HKSnippet
//
//  Created by Hunk on 16/2/14.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void(^save_snippet_block)(NSString *oldTrigger, NSString *newTrigger, NSString *snippet);

@interface HKSnippetEditViewController : NSWindowController

@property (weak) IBOutlet NSTextField *triggerTextField;
@property (unsafe_unretained) IBOutlet NSTextView *snippetTextView;
@property (nonatomic, strong) NSString *triggerString;
@property (nonatomic, strong) NSString *snippet;
@property (nonatomic, copy) save_snippet_block saveBlock;

- (IBAction)saveSnippet:(id)sender;
- (IBAction)cancelSnippet:(id)sender;

@end