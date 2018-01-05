//
//  DarkAlert.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 06/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class DarkAlert: NSAlert {
    
    init(message: String, info: String) {
        super.init()
        let alert = self
        alert.messageText = message
        //        var image: NSImage
        //        alert.icon = image
        alert.informativeText = info
        alert.addButton(withTitle: "Ok")
        alert.addButton(withTitle: "Cancel")
        alert.window.styleMask = .fullSizeContentView
        alert.window.contentView?.setBackground(R.color.black)
        
        for view in (alert.window.contentView?.subviews)! {
            if let text = (view as? NSTextField) {
                text.textColor = R.color.white
                text.isSelectable = false
            }
        }
        
        for button in alert.buttons {
//            button.setBackground(R.color.menuBgColor)
            button.image = NSImage.swatchWithColor(color: R.color.gray, size: button.frame.size)
            button.isBordered = false
        }
    }
}
