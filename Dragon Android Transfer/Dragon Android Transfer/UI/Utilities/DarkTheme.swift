//
//  DarkTheme.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 30/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class DarkTheme: Theme {
    let isDark = true
    static let color = DarkTheme.color(_:)
    
    let textColor = color("ffffff")
    //    let textColor = color("d0d0d0")
    
//    static let menuNavigationColor = "181e28"
    static let menuNavigationColor = "0d1c33"
    let menuNavColor = color(menuNavigationColor)
    let menuTableColor = color(menuNavigationColor)
    let menuBgColor = color("000409", withAlpha: 0.4)
    let menuItemBg = color("040a14")
    let menuItemSelectBg = color("2a4a83")
    let menuItemSelectCellBg = color("2a4a83")
//    let menuProgressFg = color("204582")
    let menuProgressFg = color("4065a2")
    let menuProgressBg = color("414854")
    let menuFontColor = color("ffffff")
    //    let menuItemSelectCellBg = color("000000")
    //    let menuItemSelectCellBg = color("091f45")
    
    //    let toolbarColor = color("003b6f")
    let toolbarColor = color("134876")
    let toolbarProgressFg = color("1a64a3") //TODO: Confirm color
    let toolbarProgressBg = color("47a0f2")
    
//    let pathSelectorSelectableItem = color("0e2343")
    let pathSelectorSelectableItem = color("30353a")
    let pathSelectorBg = color("000000")
    
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
//    let transferProgressFg = color("ffffff")
    let transferProgressFg = color("4a94d3")
//    let transferProgressFg = color("204582")
//    let transferProgressBg = color("6a7991")
    let transferProgressBg = color("ffffff")
    //    let transferProgressFg = color("15468a")
    //    let transferProgressBg = color("406ead")
    
    //    let dialogBgColor = color("193360")
    let dialogBgColor = color("313b4c")
    //    let dialogWindowColor = color("0f1217")
    let dialogWindowColor = color("313b4c")
    //    let dialogWindowColor = color("0b0d11")
    let dialogTextColor = color("b8c2c9")
    let dialogSelectionColor = color("5a95f5")
    let dialogSelectionDangerColor = color("e45454")
    
    //	let windowBg = color("050505")
    let windowBg = color("0a0a0a")
    let mainViewColor = color("#424242")
    
    let snackbarBg = color("313b4c")
    let snackbarTextColor = color("ffffff")
    
    let helpBgColor = color("282828")
    let tableScrollColor = color("313131")
}
