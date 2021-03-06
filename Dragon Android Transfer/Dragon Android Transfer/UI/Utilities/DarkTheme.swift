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
    
    static let windowColor = "212121"
    
    let textColor = color("ffffff")
    //    let textColor = color("d0d0d0")
    
//    static let menuNavigationColor = "181e28"
    static let menuNavigationColor = "19286a"
    let menuNavColor = color(menuNavigationColor)
    let menuTableColor = color(menuNavigationColor)
//    let menuBgColor = color("000409", withAlpha: 0.4)
    let menuBgColor = color("000000", withAlpha: 0.4)
//    let menuItemBg = color("040a14")
    static let menuItemSelectBgColor = "4456a5"
    let menuItemSelectBg = color(menuItemSelectBgColor)
    let menuItemSelectCellBg = color(menuItemSelectBgColor)
//    let menuProgressFg = color("204582")
    let menuProgressFg = color("b0baf5")
    let menuProgressBg = color("81858e")
    let menuFontColor = color("ffffff")
    //    let menuItemSelectCellBg = color("000000")
    //    let menuItemSelectCellBg = color("091f45")
    
    let toolbarColor = color("1c2f83")
    let toolbarProgressFg = color("9dbdf1")
    let toolbarProgressBg = color("438aff")
    
//    let pathSelectorSelectableItem = color("0e2343")
//    let pathSelectorSelectableItem = color("30353a")
//    let pathSelectorBg = color("000000")
//    let pathSelectorSelectableItem = color("30353a")
    let pathSelectorSelectableItem = color("30353a")
    let pathSelectorBg = color("131313")
    
    //    let tableBg = color("050505")
    //    let tableBg = color("101010")
    //    let tableBg = color("000000")
    let tableBg = color(windowColor)
    //	let tableItemBg = color("050505")
    let tableItemBg = color("000000")
    //    let listSelectedBackgroundColor = color("0d3475")
    let listSelectedBackgroundColor = color("3e4c8a")
    //    let listSelectedBackgroundColor = color("2f2f2f")
    
    static let dialogColor = "3b4152"
    
    let transferBg = color(dialogColor)
    let transferTextColor = color("b8c2c9")
//    let transferProgressFg = color("ffffff")
    let transferProgressFg = color("6789f7")
//    let transferProgressFg = color("204582")
//    let transferProgressBg = color("6a7991")
    let transferProgressBg = color("ffffff")
    //    let transferProgressFg = color("15468a")
    //    let transferProgressBg = color("406ead")
    
    //    let dialogBgColor = color("193360")
    let dialogBgColor = color(dialogColor)
    //    let dialogWindowColor = color("0f1217")
    let dialogWindowColor = color(dialogColor)
    //    let dialogWindowColor = color("0b0d11")
    let dialogTextColor = color("b8c2c9")
    let dialogSelectionColor = color("5a95f5")
    let dialogSelectionDangerColor = color("e45454")
    
    //	let windowBg = color("050505")
    let windowBg = color("0a0a0a")
    let mainViewColor = color("#424242")
    
    let snackbarBg = color("3f445a")
    let snackbarTextColor = color("ffffff")
    
    let helpBgColor = color("282828")
    let tableScrollColor = color("313131")
    
    let pathSelectorTextColor = color("b8c2c9")
    let pathSelectorLastTextColor = color("ffffff")
    
    let firstLaunchBg = color("282828")
    let firstLaunchText = color("cccccc")
    let firstLaunchCtaText = color("000000")
    let firstLaunchCtaBg = color("ffffff")
}
