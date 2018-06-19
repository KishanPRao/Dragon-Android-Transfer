//
//  DarkAlertUtils.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 19/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa

class DarkAlertUtils: NSObject {

    static func showAlert(_ message: String, info: String, confirm: Bool) -> Bool {
        var buttons: [String] = []
        buttons.append("OK")
        if (confirm) {
            buttons.append("Cancel")
        }
        let alert = DarkAlert(message: message, info: info, buttonNames: buttons)
        let button = alert.runModal()
        if (button == NSApplication.ModalResponse.alertFirstButtonReturn) {
            return true
        }
        return false
    }
    
//    TODO
    /*
    + (NSString *)input:(NSString *)title info:(NSString *)info defaultValue:(NSString *)defaultValue {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:title];
    [alert setInformativeText:info];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setTranslatesAutoresizingMaskIntoConstraints:true];
    [input setStringValue:defaultValue];
    
    [alert setAccessoryView:input];
    [[alert window] setInitialFirstResponder: input];
    NSInteger button = [alert runModal];
    if (button == NSAlertFirstButtonReturn) {
    [input validateEditing];
    return [input stringValue];
    } else if (button == NSAlertSecondButtonReturn) {
    return nil;
    } else {
    //        NSAssert1(NO, @"Invalid input dialog button %d", button);
    return nil;
    }
    }*/
}
