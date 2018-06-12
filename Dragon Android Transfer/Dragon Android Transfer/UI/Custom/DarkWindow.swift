//
//  DarkWindow.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class DarkWindow: NSWindow {
	
	override init(contentRect: Foundation.NSRect, styleMask style: AppKit.NSWindow.StyleMask, backing bufferingType: AppKit.NSWindow.BackingStoreType, `defer` flag: Bool) {
		super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
		backgroundColor = R.color.windowBg
		titlebarAppearsTransparent = true
		titleVisibility = .hidden
//		styleMask = .hudWindow
	}
}
