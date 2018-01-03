//
//  DarkTheme.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 30/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class DarkTheme: Theme {
    static let color = DarkTheme.color(_:)
    
    var menuNavColor = color("071326")
    
    var menuTableColor = color("071326")
	
	var menuBgColor = color("000409", withAlpha: 0.4)
    
    var toolbarColor =  color("102038")
    var toolbarProgressFg =  color("163666")
    var toolbarProgressBg =  color("3369bc")
    
    var tableBg = color("050505")
    var tableItemBg = color("050505")
}
