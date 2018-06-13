//
//  DarkAlert.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 06/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class DarkAlert: NSAlert {
	
    init(message: String, info: String, buttonNames: [String], fullScreen: Bool = true, textColor: NSColor = R.color.white) {
		super.init()
		let alert = self
		alert.messageText = message
		alert.informativeText = info
        for buttonName in buttonNames.reversed() {
			alert.addButton(withTitle: buttonName)
        }
        if fullScreen {
			alert.window.styleMask = NSWindow.StyleMask.fullSizeContentView
        } else {
            alert.window.backgroundColor = R.color.dialogWindowColor
            alert.window.titlebarAppearsTransparent = true
            alert.window.titleVisibility = .hidden
        }
//		alert.window.contentView?.setBackground(R.color.black)
		alert.window.contentView?.setBackground(R.color.dialogBgColor)
        
        //        TODO: Update Colors, first responder during Transfer.
		
		for view in (alert.window.contentView?.subviews)! {
			if let text = (view as? NSTextField) {
				text.textColor = textColor
				text.isSelectable = false
                text.updateMainFont()
			}
		}
		
		for button in alert.buttons {
//            button.setBackground(R.color.menuBgColor)
//            button.image = NSImage.swatchWithColor(color: R.color.gray, size: button.frame.size)
//            button.isBordered = false

//			button.setColorBackground(R.color.white, true)
			button.setText(text: button.title, textColor: R.color.black,
					alignment: .center, bgColor: R.color.white,
					rounded: true)
			button.imageScaling = .scaleNone
		}
	}
	
	public func end() {
		ThreadUtils.runInMainThreadIfNeeded {
//            NSApp.endSheet(self.window)
            self.window.endSheet(self.window)
		}
	}
}
