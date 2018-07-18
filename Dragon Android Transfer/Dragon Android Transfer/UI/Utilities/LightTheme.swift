//
//  LightTheme.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 30/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class LightTheme: Theme {
    let isDark = false
    let textColor = color("000000")
    
    static let menuNavigationColor = color("395fcb")
    let menuNavColor = menuNavigationColor
    let menuTableColor = menuNavigationColor
//    let menuBgColor = color("071a34", withAlpha: 0.4)
    let menuBgColor = color("002366", withAlpha: 0.4)
//    let menuItemBg = color("ffffff")
    static let menuItemSelectBgColor = "304497"
    let menuItemSelectBg = color(menuItemSelectBgColor)
    let menuItemSelectCellBg = color(menuItemSelectBgColor)
    let menuProgressFg = color("adbdff")
    let menuProgressBg = color("ebefff")
    let menuFontColor = color("ffffff")
    
    let toolbarColor = color("5172d1")
    let toolbarProgressFg = color("c2ffdc")
    let toolbarProgressBg = color("17e3ba")
    
    let pathSelectorSelectableItem = color("cfcac5")
    let pathSelectorBg = color("ffffff")
    
    let tableBg = color("ffffff")
    let tableItemBg = color("ffffff")
    let listSelectedBackgroundColor = color("bfcbff")
    
//    let transferBg = color("f8f8f8")
    let transferBg = color("e7f3ff")
    let transferTextColor = color("232323")
    let transferProgressFg = color("679af7")
    let transferProgressBg = color("646669")
    
    let dialogBgColor = color("edecec")
    let dialogWindowColor = color("fafafa")
    let dialogTextColor = color("2c2c2c")
    let dialogSelectionColor = color("79bdfc")
    let dialogSelectionDangerColor = color("f14545")
    
    let windowBg = color("fafafa")
    let mainViewColor = color("424242")
    
    let snackbarBg = color("7281c1")
    let snackbarTextColor = color("ffffff")
    
    let helpBgColor = color("fafafa")
    let tableScrollColor = color("fefefe")
//    var dark: Bool {
//        get {
//            return false
//        }
//    }
//
//    var menuBgColor: NSColor {
//        get {
//            return colorWithHexString("#ffffff")
//        }
//    }
}

