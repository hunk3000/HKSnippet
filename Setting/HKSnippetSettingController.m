//
//  HKSnippetSettingController.m
//  HKSnippet
//
//  Created by Hunk on 16/2/4.
//  Copyright © 2016年 Taobao.com. All rights reserved.
//

#import "HKSnippetSettingController.h"
#import "HKSnippetSetting.h"
#import "HKSnippetEditViewController.h"

@interface HKSnippetSettingController ()<NSTableViewDataSource, NSTableViewDelegate>

@property (weak) IBOutlet NSButton *btnEnabled;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSSearchField *searchField;

@property (nonatomic, strong) HKSnippetEditViewController *snippetEditViewController;
@property (nonatomic, strong) NSMutableArray *listOfKeys;

@end

@implementation HKSnippetSettingController

#pragma mark - LifeCycle
- (void)awakeFromNib {
    [super awakeFromNib];
    _listOfKeys = [NSMutableArray array];
    [self reloadDataWithKeyFilter:nil];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.btnEnabled.state = (NSCellStateValue)[[HKSnippetSetting defaultSetting] enabled];
}

#pragma mark - UI Action
- (IBAction)btnEnabledPressed:(NSButton *)sender {
    [[HKSnippetSetting defaultSetting] setEnabled:sender.state];
}

- (IBAction)btnResetPressed:(NSButton *)sender {
    [[HKSnippetSetting defaultSetting] resetToDefaultSetting];
    self.btnEnabled.state = (NSCellStateValue)[[HKSnippetSetting defaultSetting] enabled];
    [self reloadDataWithKeyFilter:nil];
}

- (IBAction)addNewSnippet:(id)sender {
    [self showEditViewControllerWithTriggerString:@""
                                          snippet:@""
                                           sender:sender];
}

- (IBAction)removeSelectedSnippet:(id)sender {
    NSInteger row = self.tableView.selectedRow;
    if (row == -1) {
        [self showErrorAlertWithMessage:@"You didn't select any row."];
        return;
    }

    __weak typeof(self) weakSelf = self;
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Delete the snippet?"];
    [alert setInformativeText:@"Deleted snippet cannot be restored."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self.window
                  completionHandler:^(NSModalResponse returnCode) {
                      if (returnCode == NSAlertFirstButtonReturn) {
                          NSString *triggerString = _listOfKeys[row];
                          [[HKSnippetSetting defaultSetting].snippets removeObjectForKey:triggerString];
                          [[HKSnippetSetting defaultSetting] sychronizeSetting];
                          [weakSelf reloadDataWithKeyFilter:nil];
                      }
                  }];
}

- (IBAction)editSnippet:(id)sender {
    NSInteger row = self.tableView.selectedRow;
    if (row == -1) {
        [self showErrorAlertWithMessage:@"You didn't select any row."];
        return;
    }

    NSString *triggerString = _listOfKeys[row];
    NSString *snippetString = [HKSnippetSetting defaultSetting].snippets[triggerString];
   [self showEditViewControllerWithTriggerString:triggerString
                                         snippet:snippetString
                                          sender:sender];
}

- (IBAction)checkTriggers:(id)sender {
    NSMutableArray *conflictMessages = [NSMutableArray array];

    // Check trigger conflict with system keyword
    for (NSString *trigger in _listOfKeys) {
        for (NSString *sysTrigger in [HKSnippetSetting defaultSetting].systemTriggers) {
            if ([sysTrigger containsString:trigger]) {
                [conflictMessages addObject:[NSString stringWithFormat:@"%@ conflict with %@", trigger, sysTrigger]];
            }
        }
    }
    [self showErrorAlertWithMessage:[conflictMessages description]];
}
- (IBAction)SearchTextFieldAction:(NSSearchField *)sender {
    //NSLog(@"SearchTextFieldAction %@",sender);
    if (sender.stringValue.length == 0) {
        [self reloadDataWithKeyFilter:nil];
    } else {
        [self reloadDataWithKeyFilter:sender.stringValue];
    }
}

#pragma mark - Private Method
- (void)reloadDataWithKeyFilter:(NSString *)filter {
    NSArray *allKeys = [[HKSnippetSetting defaultSetting].snippets allKeys];
    NSArray *sortedKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    [_listOfKeys removeAllObjects];
    if (filter.length > 0) {
        for (NSString *key in sortedKeys) {
            if ([key containsString:filter]) {
                [_listOfKeys addObject:key];
            }
        }
    } else {
        [_listOfKeys addObjectsFromArray:sortedKeys];
    }
    
    [self.tableView reloadData];
}

- (void)showEditViewControllerWithTriggerString:(NSString *)triggerString
                                        snippet:(NSString *)snippet
                                         sender:(id)sender {
    _snippetEditViewController = [[HKSnippetEditViewController alloc] initWithWindowNibName:@"HKSnippetEditViewController"];
    [_snippetEditViewController loadWindow];
    
    NSRect windowFrame = [[self window] frame];
    NSRect prefsFrame = [[_snippetEditViewController window] frame];
    prefsFrame.origin = NSMakePoint(windowFrame.origin.x + (windowFrame.size.width - prefsFrame.size.width) / 2.0,
                                    NSMaxY(windowFrame) - NSHeight(prefsFrame) - 20.0);
    [[_snippetEditViewController window] setFrame:prefsFrame
                                          display:NO];
    self.snippetEditViewController.triggerString = triggerString;
    self.snippetEditViewController.snippet = snippet;

    __weak typeof(self) weakSelf = self;
    self.snippetEditViewController.saveBlock = ^(NSString *oldTrigger, NSString *newTrigger, NSString *snippet) {
        // Check trigger length
        if (newTrigger.length < 2) {
            [weakSelf showErrorAlertWithMessage:@"Trigger is too short, 2 characters at least."];
            return;
        }
        // trigger string changed, remove old trigger
        if (![oldTrigger isEqualToString:newTrigger]) {
            [[HKSnippetSetting defaultSetting].snippets removeObjectForKey:oldTrigger];
        }
        
        [[HKSnippetSetting defaultSetting].snippets setObject:snippet forKey:newTrigger];
        [[HKSnippetSetting defaultSetting] sychronizeSetting];
        [weakSelf reloadDataWithKeyFilter:nil];
    };
    [self.snippetEditViewController showWindow:sender];
}

- (void)showErrorAlertWithMessage:(NSString *)message {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Error"];
    [alert setInformativeText:message];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:self.window
                  completionHandler:^(NSModalResponse returnCode) {
                      if (returnCode == NSAlertFirstButtonReturn) {
                      }
                  }];
}

- (IBAction)exportSnippets:(id)sender {
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"Untitle.plist"];
    [panel setMessage:@"Choose the path to save the config file."];
    [panel setAllowsOtherFileTypes:YES];
    [panel setAllowedFileTypes:@[@"plist"]];
    [panel setExtensionHidden:YES];
    [panel setCanCreateDirectories:YES];
    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton)
        {
            NSString *path = [[panel URL] path];
            [[HKSnippetSetting defaultSetting].snippets writeToFile:path
                                                         atomically:YES];
        }
    }];
}

- (IBAction)importSnippets:(id)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setTitle:@"Choose a config file"];
    [openPanel setCanChooseDirectories:NO];
    
    if([openPanel runModal] == NSModalResponseOK) {
        NSURL *theFileURL = [openPanel URL];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfURL:theFileURL];
        [HKSnippetSetting defaultSetting].snippets = [NSMutableDictionary dictionaryWithDictionary:dic];
        [[HKSnippetSetting defaultSetting] sychronizeSetting];
        [self reloadDataWithKeyFilter:nil];
    }
}

#pragma mark - NSTableView Datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _listOfKeys.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    NSString *key = _listOfKeys[row];
    NSString *value = [HKSnippetSetting defaultSetting].snippets[key];
    
    if(tableColumn == tableView.tableColumns[0]) {
        tableColumn.title = @"Trigger";
        return key;
    }
    if (tableColumn == tableView.tableColumns[1]) {
        tableColumn.title = @"Snippet";
        return value;
    }

    return nil;
}

#pragma mark - NSTableView Delegate

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    NSString *value = [HKSnippetSetting defaultSetting].snippets[_listOfKeys[row]];
    NSArray *lines = [value componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if (lines.count == 0 || lines.count == 1) {
        return 30;
    }
    return lines.count * 18;
}

@end
