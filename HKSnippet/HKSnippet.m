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

static HKSnippet *sharedPlugin;

@interface HKSnippet()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) HKSnippetSettingController *settingWindow;

//@autoreleasepool
//@catch
//@class
//@compatibility_alias
//@defs
//@dynamic
//@encode
//@end
//@finally
//@import
//@interface
//@implementation
//@optional
//@package
//@private
//@property
//@protected
//@protocol
//@public
//@required
//@selector
//@synchronized
//@synthesize
//@throw
//@try

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

        // replacement snippet exist ?
        if ([HKSnippetSetting defaultSetting].snippets[currentLineResult.string]) {
            NSUInteger length = currentLineResult.string.length;

            // make sure the undo function is working fine.
            NSUndoManager *undoManager = [textView undoManager];
            [undoManager disableUndoRegistration];
            
            // save pasteboard string for restore
            NSString *oldPasteString = [[self class] getPasteboardString];
            
            [textView setSelectedRange:NSMakeRange(textView.currentCurseLocation - length, length)];
            [[self class] setPasteboardString:@""];
            [textView cut:self];
            
            [undoManager enableUndoRegistration];
            [[self class] setPasteboardString:[HKSnippetSetting defaultSetting].snippets[currentLineResult.string]];
            [textView paste:self];
            
            if (oldPasteString) {
                [[self class] setPasteboardString:oldPasteString];
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

@end