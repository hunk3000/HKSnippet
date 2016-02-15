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
@property (nonatomic, strong) HKSnippetEditViewController *snippetEditViewController;
@property (nonatomic, strong) NSMutableArray *keyArr;

@end

@implementation HKSnippetSettingController

- (void)awakeFromNib {
    [super awakeFromNib];
    [self reloadData];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.btnEnabled.state = (NSCellStateValue)[[HKSnippetSetting defaultSetting] enabled];
}

- (void)reloadData {
    NSArray *allKeys = [[HKSnippetSetting defaultSetting].snippets allKeys];
    NSArray *sortedKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    _keyArr = [NSMutableArray arrayWithArray:sortedKeys];
    [self.tableView reloadData];
}

- (IBAction)btnEnabledPressed:(NSButton *)sender {
    [[HKSnippetSetting defaultSetting] setEnabled:sender.state];
}

- (IBAction)btnResetPressed:(NSButton *)sender {
    [[HKSnippetSetting defaultSetting] resetToDefaultSetting];
    self.btnEnabled.state = (NSCellStateValue)[[HKSnippetSetting defaultSetting] enabled];
    [self reloadData];
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
        [self reloadData];
    }
}

- (IBAction)addNewSnippet:(id)sender {
    [self showEditViewControllerWithTriggerString:@""
                                          snippet:@""
                                           sender:sender];
}

- (IBAction)removeSelectedSnippet:(id)sender {
    NSArray *allKeys = [[HKSnippetSetting defaultSetting].snippets allKeys];
    NSArray *sortedKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSInteger row = self.tableView.selectedRow;
    NSString *triggerString = sortedKeys[row];
    [[HKSnippetSetting defaultSetting].snippets removeObjectForKey:triggerString];
    [[HKSnippetSetting defaultSetting] sychronizeSetting];
    [self reloadData];
}

- (IBAction)editSnippet:(id)sender {
    NSArray *allKeys = [[HKSnippetSetting defaultSetting].snippets allKeys];
    NSArray *sortedKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSInteger row = self.tableView.selectedRow;
    NSString *triggerString = sortedKeys[row];
    NSString *snippetString = [HKSnippetSetting defaultSetting].snippets[triggerString];
    
   [self showEditViewControllerWithTriggerString:triggerString
                                         snippet:snippetString
                                          sender:sender];
}

#pragma mark - Private Method
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
        if (newTrigger.length < 2) {
            return;
        }
        if (![oldTrigger isEqualToString:newTrigger]) {
            [[HKSnippetSetting defaultSetting].snippets removeObjectForKey:oldTrigger];
        }
        
        [[HKSnippetSetting defaultSetting].snippets setObject:snippet forKey:newTrigger];
        [[HKSnippetSetting defaultSetting] sychronizeSetting];
        [weakSelf reloadData];
    };
    [self.snippetEditViewController showWindow:sender];
}

#pragma mark - NSTableView Datasource
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [HKSnippetSetting defaultSetting].snippets.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    NSString *key = _keyArr[row];
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
    NSString *value = [HKSnippetSetting defaultSetting].snippets[_keyArr[row]];
    NSArray *lines = [value componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    if (lines.count == 0 || lines.count == 1) {
        return 30;
    }
    return lines.count * 18;
}

@end
