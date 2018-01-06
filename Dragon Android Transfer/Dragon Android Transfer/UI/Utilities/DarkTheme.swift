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
	
	let menuNavColor = color("071326")
	let menuTableColor = color("071326")
	let menuBgColor = color("000409", withAlpha: 0.4)
	let menuItemBg = color("040a14")
	let menuItemSelectBg = color("091f45")
	
	let toolbarColor = color("102038")
	let toolbarProgressFg = color("163666")
	let toolbarProgressBg = color("3369bc")

//    let tableBg = color("050505") 
//    let tableBg = color("101010") 
	let tableBg = color("000000")
//	let tableItemBg = color("050505")
	let tableItemBg = color("000000")
	let transferBg = color("313b4c")
	let textColor = color("ffffff")
	let transferTextColor = color("b8c2c9")

//	let windowBg = color("050505")
	let windowBg = color("101010")
}
