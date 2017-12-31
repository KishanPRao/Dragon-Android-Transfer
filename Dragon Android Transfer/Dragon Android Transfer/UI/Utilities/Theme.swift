//
//  Theme.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 30/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

protocol Theme {
	
	func colorWithHexString(_ hex: String) -> NSColor
	
	var dark: Bool { get }
	
	var menuBgColor: NSColor { get }
}

extension Theme {
	//var dark: Bool {
	//get {return false}
	//set {}
	//}
	func colorWithHexString(_ hex: String) -> NSColor {
		return ColorUtils.colorWithHexString(hex)
	}
}
