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
    lazy var menuItemBg = { color("040a14") }()
    lazy var menuItemSelectBg = { color("091f45") }()
    
    lazy var toolbarColor = { color("102038") }()
    lazy var toolbarProgressFg = { color("163666") }()
    lazy var toolbarProgressBg = { color("3369bc") }()
    
    lazy var tableBg = { color("050505") }()
    lazy var tableItemBg = { color("050505") }()
    lazy var transferBg = {color("313b4c")}()
}
