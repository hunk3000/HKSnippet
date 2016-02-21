//
//  HKSnippet.m
//  HKSnippet
//
//  Created by Hunk on 16/2/4.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import "HKSnippet.h"
#import "HKTextResult.h"
#import "HKSnippetSetting.h"
#import "NSTextView+Snippet.h"
#import "HKSnippetSettingController.h"
#import "VVKeyboardEventSender.h"

static HKSnippet *sharedPlugin;

@interface HKSnippet()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) HKSnippetSettingController *settingWindow;
@property (nonatomic, strong) id eventMonitor;
@property (nonatomic, assign) BOOL shouldReplace;

@end

@implementation HKSnippet

#pragma mark - LifeCycle
+ (void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

+ (instancetype)sharedPlugin {
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        self.bundle = plugin;
        self.shouldReplace = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textStorageDidChange:)
                                                     name:NSTextDidChangeNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(xcodeDidLoad)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)xcodeDidLoad {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSApplicationDidFinishLaunchingNotification
                                                  object:nil];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self addMenuItem];
    }];
}

#pragma mark - Notification Callback
- (void)textStorageDidChange:(NSNotification *)notification {
    if (![[HKSnippetSetting defaultSetting] enabled]) {
        return;
    }
    
    if ([[notification object] isKindOfClass:[NSTextView class]]) {
        NSTextView *textView = (NSTextView *)[notification object];
        HKTextResult *currentLineResult = [textView textResultOfCurrentLine];
        NSString *cmdString = currentLineResult.string;
        __weak typeof(self) weakSelf = self;
        // start with "@", means no parameters
        if ([cmdString hasPrefix:@"@"]) {
            // replacement snippet exist
            if ([HKSnippetSetting defaultSetting].snippets[cmdString]) {
                [self pasteSnippet:[HKSnippetSetting defaultSetting].snippets[cmdString]
                   byTriggerString:cmdString
                        toTextView:textView
                    withParameters:nil];
            }
        } else {
            // Replace part (start with ^) exist
            if ([cmdString containsString:@"^"]) {
                NSUInteger replaceIndex = [cmdString rangeOfString:@"^"].location;
                NSString *replaceTrigger = [cmdString substringFromIndex:replaceIndex];
                NSString *snippet = [HKSnippetSetting defaultSetting].snippets[replaceTrigger];
                if (snippet) {
                    [self pasteSnippet:snippet
                       byTriggerString:replaceTrigger
                            toTextView:textView
                        withParameters:nil];
                }
            }
            
            // Get parameters
            NSArray *cmdArr = [cmdString componentsSeparatedByString:@"@"];
            if (cmdArr.count > 1) {
                NSString *parameterString = cmdArr[0];
                NSString *triggerString = [NSString stringWithFormat:@"@%@",cmdArr[1]];
                NSArray *parameters = [parameterString componentsSeparatedByString:@","];
                NSString *snippet = [HKSnippetSetting defaultSetting].snippets[triggerString];
                if (snippet) {
                    [self pasteSnippet:[HKSnippet replacedSnippet:snippet withParameters:parameters]
                       byTriggerString:cmdString
                            toTextView:textView
                        withParameters:parameters];
                }
            }
        }
    }
}

#pragma mark - UI
- (void)addMenuItem {
    NSMenu *mainMenu = [NSApp mainMenu];
    NSMenuItem *pluginsMenuItem = [mainMenu itemWithTitle:@"Plugins"];
    if (!pluginsMenuItem) {
        pluginsMenuItem = [[NSMenuItem alloc] init];
        pluginsMenuItem.title = @"Plugins";
        pluginsMenuItem.submenu = [[NSMenu alloc] initWithTitle:pluginsMenuItem.title];
        NSInteger windowIndex = [mainMenu indexOfItemWithTitle:@"Window"];
        [mainMenu insertItem:pluginsMenuItem atIndex:windowIndex];
    }
    NSMenuItem *mainMenuItem = [[NSMenuItem alloc] initWithTitle:@"HKSnippet"
                                                          action:@selector(showSettingWindow)
                                                   keyEquivalent:@""];
    [mainMenuItem setTarget:self];
    [pluginsMenuItem.submenu addItem:mainMenuItem];
}

- (void)showSettingWindow {
    self.settingWindow = [[HKSnippetSettingController alloc] initWithWindowNibName:@"HKSnippetSettingController"];
    [self.settingWindow showWindow:self.settingWindow];
}

#pragma mark - Private Method
+ (void)setPasteboardString:(NSString *)aString {
    NSPasteboard *thePasteboard = [NSPasteboard generalPasteboard];
    [thePasteboard clearContents];
    [thePasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [thePasteboard setString:aString forType:NSStringPboardType];
}

+ (NSString *)getPasteboardString {
    NSString *retValue = nil;
    NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
    NSArray *types = [pasteboard types];
    if ([types containsObject:NSStringPboardType]) {
        retValue = [pasteboard stringForType:NSStringPboardType];
    }
    return retValue;
}

- (void)resetShouldReplace {
    self.shouldReplace = YES;
}

- (void)pasteSnippet:(NSString *)snippet
     byTriggerString:(NSString *)triggerString
          toTextView:(NSTextView *)textView
      withParameters:(NSArray *)parameters {
    
    if (!self.shouldReplace) {
        [self resetShouldReplace];
        return;
    }
    
    NSUInteger length = triggerString.length;
    // save pasteboard string for restore
    NSString *oldPasteString = [HKSnippet getPasteboardString];
    [HKSnippet setPasteboardString:snippet];
    
    [textView setSelectedRange:NSMakeRange(textView.currentCurseLocation - length, length)];

    //Begin to simulate keyborad pressing
    VVKeyboardEventSender *kes = [[VVKeyboardEventSender alloc] init];
    [kes beginKeyBoradEvents];
    
    //Cmd+delete Delete current line
    [kes sendKeyCode:kVK_Delete withModifierCommand:YES alt:NO shift:NO control:NO];

    //Cmd+V, paste (which key to actually use is based on the current keyboard layout)
    NSInteger kKeyVCode = [kes keyVCode];
    [kes sendKeyCode:kKeyVCode withModifierCommand:YES alt:NO shift:NO control:NO];
    
    //The key down is just a defined finish signal by me. When we receive this key,
    //we know operation above is finished.
    [kes sendKeyCode:kVK_F19];
    
    __weak typeof(self) weakSelf = self;
    self.eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask
                                                              handler:^ NSEvent *(NSEvent *incomingEvent) {
        if ([incomingEvent type] == NSKeyDown &&
            [incomingEvent keyCode] == kVK_F19) {
            //Finish signal arrived, no need to observe the event
            [NSEvent removeMonitor:weakSelf.eventMonitor];
            weakSelf.eventMonitor = nil;
            
            //Restore previois patse board content
            if (oldPasteString) {
                [HKSnippet setPasteboardString:oldPasteString];
            }
            if ([snippet containsString:@"<#"]) {
                //Set cursor before the inserted snippet. So we can use tab to begin edit.
                int snippetLength = (int)snippet.length;
                [textView setSelectedRange:NSMakeRange(textView.currentCurseLocation - snippetLength, 0)];
                
                //Send a 'tab' after insert the snippet. For our lazy programmers. :-)
                [kes sendKeyCode:kVK_Tab];
                [kes endKeyBoradEvents];
            }

            weakSelf.shouldReplace = NO;
            //Invalidate the finish signal, in case you set it to do some other thing.
            return nil;
        } else {
            return incomingEvent;
        }
    }];
    [self performSelector:@selector(resetShouldReplace)
               withObject:nil
               afterDelay:4.0f];
}

+ (NSString *)replacedSnippet:(NSString *)orgSnippet
               withParameters:(NSArray *)parameter {
    NSString *snippet = [NSString stringWithString:orgSnippet];
    snippet = [snippet stringByReplacingOccurrencesOfString:@"<#name#>"
                                                 withString:parameter[0]];
    for (NSString *p in parameter) {
        // replace font
        if ([p containsString:@"font"] || [p containsString:@"Font"] || [p containsString:@"FONT"]) {
            snippet = [snippet stringByReplacingOccurrencesOfString:@"<#font#>"
                                                         withString:p];
        }
        // replace color
        if ([p containsString:@"color"] || [p containsString:@"Color"] || [p containsString:@"COLOR"]) {
            snippet = [snippet stringByReplacingOccurrencesOfString:@"<#color#>"
                                                         withString:p];
        }
    }
    return snippet;
}

@end