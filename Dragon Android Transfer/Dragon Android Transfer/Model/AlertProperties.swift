//
//  AlertProperties.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 23/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa

class AlertButtonProperty: NSObject {
    var title: String
    var bgColor: NSColor
    var textColor: NSColor
    var textSize: TextSizeType
    
    init(title: String = "",
         bgColor: NSColor = R.color.white,
         textColor: NSColor  = R.color.black,
         textSize: TextSizeType = R.number.dialogButtonTextSize) {
        self.title = title
        self.bgColor = bgColor
        self.textColor = textColor
        self.textSize = textSize
    }
}

class AlertProperty: NSObject {
    var message: String = ""
    var info: String = ""
    var textColor = R.color.textColor
    var fullScreen = false
    var style: NSAlert.Style = .informational
    var buttons: [AlertButtonProperty] = []
    
    func addButton(button: AlertButtonProperty) {
        buttons.append(button)
    }
}

class InputAlertProperty: AlertProperty {
    var defaultValue: String = ""
}
