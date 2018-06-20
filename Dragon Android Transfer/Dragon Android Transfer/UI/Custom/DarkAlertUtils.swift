//
//  DarkAlertUtils.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 19/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa

class DarkAlertUtils: NSObject {

//    Key value pairs, send all params, include image for 'info' action.
    static func showAlert(_ message: String, info: String, confirm: Bool,
                          style: NSAlert.Style = .informational) -> Bool {
        var buttons: [String] = []
        buttons.append("OK")
        if (confirm) {
            buttons.append("Cancel")
        }
        let alert = DarkAlert(message: message, info: info, buttonNames: buttons,
            fullScreen: false,
            textColor: R.color.transferTextColor)
        alert.alertStyle = style
        let button = alert.runModal()
        if (button == NSApplication.ModalResponse.alertFirstButtonReturn) {
            return true
        }
        return false
    }
    
    
    static func input(_ title: String, info: String, defaultValue: String) -> String? {
        let alert = DarkAlert(message: title, info: info,
                              buttonNames: ["OK", "Cancel"],
                              fullScreen: false,
                              textColor: R.color.transferTextColor)
        alert.alertStyle = .informational
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.isEditable = true
        input.translatesAutoresizingMaskIntoConstraints = true
        input.stringValue = defaultValue
        
        alert.accessoryView = input
        alert.window.initialFirstResponder = input
        let response = alert.runModal()
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            input.validateEditing()
            return input.stringValue
        } else if (response == NSApplication.ModalResponse.alertSecondButtonReturn) {
            return nil
        }
//        print("Invalid input dialog response \(response)")
        return nil
    }
}
