//
//  HKSnippetEditViewController.m
//  HKSnippet
//
//  Created by Hunk on 16/2/14.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import "HKSnippetEditViewController.h"
#import "HKSnippetSetting.h"

@interface HKSnippetEditViewController ()

@end

@implementation HKSnippetEditViewController

- (void)windowDidLoad {
    [super windowDidLoad];
    _snippetTextView.font = [NSFont systemFontOfSize:18.0f];
}

- (IBAction)saveSnippet:(id)sender {
    // Check trigger conflict with system keyword
    for (NSString *sysTrigger in [HKSnippetSetting defaultSetting].systemTriggers) {
        if ([sysTrigger containsString:_triggerTextField.stringValue]) {
            NSString *msg = [NSString stringWithFormat:@"The trigger %@ has conflict with system keyword %@ , Continue?",
                             _triggerTextField.stringValue,
                             sysTrigger];
            __weak typeof(self) weakSelf = self;
            [self showConfirmWithMessage:msg
                          positiveAction:^{
                              if (weakSelf.saveBlock) {
                                  weakSelf.saveBlock(_triggerString,
                                                     _triggerTextField.stringValue,
                                                     _snippetTextView.textStorage.string);
                              }
                              [weakSelf close];
                          } negativeAction:nil];
            return;
        }
    }
    
    if (self.saveBlock) {
        self.saveBlock(_triggerString,
                       _triggerTextField.stringValue,
                       _snippetTextView.textStorage.string);
    }
    [self close];
}

- (IBAction)cancelSnippet:(id)sender {
    [self close];
}

#pragma mark - Private Method
- (void)showConfirmWithMessage:(NSString *)message
                positiveAction:(void(^)(void))postiveAction
                negativeAction:(void(^)(void))negativeAction {
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"YES"];
    [alert addButtonWithTitle:@"NO"];
    [alert setMessageText:@"Warnning"];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self.window
                  completionHandler:^(NSModalResponse returnCode) {
                      if (returnCode == NSAlertFirstButtonReturn) {
                          if (postiveAction) {
                              postiveAction();
                          }
                      }
                      if (returnCode  == NSAlertSecondButtonReturn) {
                          if (negativeAction) {
                              negativeAction();
                          }
                      }
                  }];
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