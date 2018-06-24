//
//  DarkAlertUtils.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 19/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa

//DarkAlertGenerator/Builder?
class DarkAlertUtils: NSObject {

//    Include image param for 'info' action.
    static func showAlert(property: AlertProperty) -> Bool {
        let alert = DarkAlert(property: property)
        let button = alert.runModal()
        if (button == NSApplication.ModalResponse.alertFirstButtonReturn) {
            return true
        }
        return false
    }
    
    
    static func input(property: InputAlertProperty) -> String? {
        let alert = DarkAlert(property: property)
        alert.alertStyle = .informational
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.isEditable = true
        input.translatesAutoresizingMaskIntoConstraints = true
        input.stringValue = property.defaultValue
        
        alert.accessoryView = input
        alert.icon = property.icon
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
