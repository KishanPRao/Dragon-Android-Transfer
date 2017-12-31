//
//  DarkTheme.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 30/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class DarkTheme: Theme {
	
	var dark: Bool {
		get {
			return true
		}
	}
	
	var menuBgColor: NSColor {
		get {
			return colorWithHexString("071326")
		}
	}
}
