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
	
    let textColor = color("ffffff")
//    let textColor = color("d0d0d0")
    
	let menuNavColor = color("071326")
	let menuTableColor = color("071326")
	let menuBgColor = color("000409", withAlpha: 0.4)
	let menuItemBg = color("040a14")
	let menuItemSelectBg = color("091f45")
    let menuItemSelectCellBg = color("11326c")
//    let menuItemSelectCellBg = color("091f45")
	
//    let toolbarColor = color("003b6f")
    let toolbarColor = color("134876")
	let toolbarProgressFg = color("1a64a3")
	let toolbarProgressBg = color("47a0f2")

	let pathSelectorSelectableItem = color("0e2343")

//    let tableBg = color("050505") 
//    let tableBg = color("101010") 
//    let tableBg = color("000000")
    let tableBg = color("131415")
//	let tableItemBg = color("050505")
	let tableItemBg = color("000000")
//    let listSelectedBackgroundColor = color("0d3475")
    let listSelectedBackgroundColor = color("092c61")
//    let listSelectedBackgroundColor = color("2f2f2f")

	let transferBg = color("313b4c")
	let transferTextColor = color("b8c2c9")
    let transferProgressFg = color("204582")
    let transferProgressBg = color("6a7991")
    
//    let dialogBgColor = color("193360")
    let dialogBgColor = color("313b4c")
//    let dialogWindowColor = color("0f1217")
    let dialogWindowColor = color("313b4c")
//    let dialogWindowColor = color("0b0d11")

//	let windowBg = color("050505")
    let windowBg = color("0a0a0a")
    let mainViewColor = color("#424242")
}
