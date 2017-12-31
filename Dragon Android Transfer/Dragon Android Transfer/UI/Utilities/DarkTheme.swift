//
//  DarkTheme.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 30/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class DarkTheme: Theme {
    
    var menuNavColor: NSColor { get {return color("071326")}}
    
    var menuTableColor: NSColor { get {return color("071326")}}
	
	var menuBgColor: NSColor {
		get {
            return color("000409", withAlpha: 0.4)
		}
        
	}
}
