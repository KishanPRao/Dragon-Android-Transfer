//
//  DarkAlert.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 06/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class DarkAlert: NSAlert {
	
    //    TODO: Show dialog in middle of screen? Window?
    init(property: AlertProperty) {
		super.init()
		let alert = self
        for buttonProperty in property.buttons {
			let button = alert.addButton(withTitle: buttonProperty.title)
            button.setText(text: buttonProperty.title,
                           textColor: buttonProperty.textColor,
                           alignment: .center,
                           bgColor: buttonProperty.bgColor,
                           isSelected: buttonProperty.isSelected,
                           rounded: true)
            button.imageScaling = .scaleNone
            button.updateMainFont(buttonProperty.textSize)
        }
        if property.fullScreen {
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
                text.isSelectable = false
                text.updateMainFontInIncrement(2.0)
                text.textColor = property.textColor
                text.translatesAutoresizingMaskIntoConstraints = true
            }
        }
        alert.messageText = property.message
        alert.informativeText = property.info
        alert.alertStyle = property.style
        
		/*
		for button in alert.buttons {
//            button.setBackground(R.color.menuBgColor)
//            button.image = NSImage.swatchWithColor(color: R.color.gray, size: button.frame.size)
//            button.isBordered = false

//			button.setColorBackground(R.color.white, true)
			button.setText(text: button.title, textColor: R.color.black,
					alignment: .center, bgColor: R.color.white,
					rounded: true)
			button.imageScaling = .scaleNone
            button.updateMainFont(13.0)
            button
		}*/
	}
	
	public func end() {
		ThreadUtils.runInMainThreadIfNeeded {
//            NSApp.endSheet(self.window)
            self.window.endSheet(self.window)
		}
	}
}
