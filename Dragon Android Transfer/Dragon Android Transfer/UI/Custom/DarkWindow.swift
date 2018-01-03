//
//  DarkWindow.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class DarkWindow: NSWindow {
	
	override init(contentRect: Foundation.NSRect, styleMask style: AppKit.NSWindowStyleMask, backing bufferingType: AppKit.NSBackingStoreType, `defer` flag: Bool) {
		super.init(contentRect: contentRect, styleMask: style, backing: bufferingType, defer: flag)
		backgroundColor = R.color.tableBg
		titlebarAppearsTransparent = true
	}
}
