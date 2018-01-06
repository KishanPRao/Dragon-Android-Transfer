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
		alert.informativeText = info
		alert.addButton(withTitle: "Ok")
		alert.addButton(withTitle: "Cancel")
		alert.window.styleMask = .fullSizeContentView
//		alert.window.contentView?.setBackground(R.color.black)
		alert.window.contentView?.setBackground(R.color.menuNavColor)
		
		for view in (alert.window.contentView?.subviews)! {
			if let text = (view as? NSTextField) {
				text.textColor = R.color.white
				text.isSelectable = false
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
			NSApp.endSheet(self.window)
		}
	}
}
