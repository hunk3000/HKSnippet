//
//  HKSnippetEditViewController.m
//  HKSnippet
//
//  Created by Hunk on 16/2/14.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import "HKSnippetEditViewController.h"

@interface HKSnippetEditViewController ()

@end

@implementation HKSnippetEditViewController

- (void)windowDidLoad {
    [super windowDidLoad];
    _snippetTextView.font = [NSFont systemFontOfSize:18.0f];
}

- (IBAction)saveSnippet:(id)sender {
    if (self.saveBlock) {
        self.saveBlock(_triggerString, _triggerTextField.stringValue, _snippetTextView.textStorage.string);
    }
    [self close];
}

- (IBAction)cancelSnippet:(id)sender {
    [self close];
}

#pragma mark - Getters & Setters
- (void)setTriggerString:(NSString *)triggerString {
    _triggerString = triggerString;
    _triggerTextField.stringValue = _triggerString;
}

- (void)setSnippet:(NSString *)snippet {
    _snippet = snippet;
    NSAttributedString* attr = [[NSAttributedString alloc] initWithString:_snippet];
    [_snippetTextView.textStorage appendAttributedString:attr];
}

@end
