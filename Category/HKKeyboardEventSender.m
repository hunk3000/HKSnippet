//
//  VVKeyboardEventSender.m
//  VVDocumenter-Xcode
//
//  Created by 王 巍 on 13-7-26.
//
//  Copyright (c) 2015 Wei Wang <onevcat@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "HKKeyboardEventSender.h"

@interface HKKeyboardEventSender()
{
    CGEventSourceRef _source;
    CGEventTapLocation _location;
}
@end

@implementation HKKeyboardEventSender
-(void) beginKeyBoradEvents
{
    _source = CGEventSourceCreate(kCGEventSourceStateCombinedSessionState);
    _location = kCGHIDEventTap;
}

-(void) sendKeyCode:(NSInteger)keyCode
{
    [self sendKeyCode:keyCode withModifier:0];
}

-(void) sendKeyCode:(NSInteger)keyCode withModifierCommand:(BOOL)command
                alt:(BOOL)alt
              shift:(BOOL)shift
            control:(BOOL)control
{
    NSInteger modifier = 0;
    if (command) {
        modifier = modifier ^ kCGEventFlagMaskCommand;
    }
    if (alt) {
        modifier = modifier ^ kCGEventFlagMaskAlternate;
    }
    if (shift) {
        modifier = modifier ^ kCGEventFlagMaskShift;
    }
    if (control) {
        modifier = modifier ^ kCGEventFlagMaskControl;
    }

    [self sendKeyCode:keyCode withModifier:modifier];
}

-(void) sendKeyCode:(NSInteger)keyCode withModifier:(NSInteger)modifierMask
{
    NSAssert(_source != NULL, @"You should call -beginKeyBoradEvents before sending a key event");
    CGEventRef event;
    event = CGEventCreateKeyboardEvent(_source, keyCode, true);
    CGEventSetFlags(event, modifierMask);
    CGEventPost(_location, event);
    CFRelease(event);
    
    event = CGEventCreateKeyboardEvent(_source, keyCode, false);
    CGEventSetFlags(event, modifierMask);
    CGEventPost(_location, event);
    CFRelease(event);
}

-(void) endKeyBoradEvents
{
    NSAssert(_source != NULL, @"You should call -beginKeyBoradEvents before end current keyborad event");
    CFRelease(_source);
    _source = nil;
}

-(NSInteger) keyVCode
{
    TISInputSourceRef inputSource = TISCopyCurrentKeyboardLayoutInputSource();
    NSString *layoutID = (__bridge NSString *)TISGetInputSourceProperty(inputSource, kTISPropertyInputSourceID);
    CFRelease(inputSource);
    
    // Possible dvorak layout SourceIDs:
    //    com.apple.keylayout.Dvorak (System Qwerty)
    // But exclude:
    //    com.apple.keylayout.DVORAK-QWERTYCMD (System Qwerty ⌘)
    //    org.unknown.keylayout.DvorakImproved-Qwerty⌘ (http://www.macupdate.com/app/mac/24137/dvorak-improved-keyboard-layout)
    if ([layoutID localizedCaseInsensitiveContainsString:@"dvorak"] && ![layoutID localizedCaseInsensitiveContainsString: @"qwerty"]) {
        return kVK_ANSI_Period;
    }
    
    // Possible workman layout SourceIDs (https://github.com/ojbucao/Workman):
    //    org.sil.ukelele.keyboardlayout.workman.workman
    //    org.sil.ukelele.keyboardlayout.workman.workmanextended
    //    org.sil.ukelele.keyboardlayout.workman.workman-io
    //    org.sil.ukelele.keyboardlayout.workman.workman-p
    //    org.sil.ukelele.keyboardlayout.workman.workman-pextended
    //    org.sil.ukelele.keyboardlayout.workman.workman-dead
    if ([layoutID localizedCaseInsensitiveContainsString:@"workman"]) {
        return kVK_ANSI_B;
    }
    
    return kVK_ANSI_V;
}
@end
