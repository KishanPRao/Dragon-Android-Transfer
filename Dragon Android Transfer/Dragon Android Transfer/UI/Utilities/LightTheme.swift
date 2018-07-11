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
    
    static let menuNavigationColor = color("002366")
    let menuNavColor = menuNavigationColor
    let menuTableColor = menuNavigationColor
//    let menuBgColor = color("071a34", withAlpha: 0.4)
    let menuBgColor = color("002366", withAlpha: 0.4)
    let menuItemBg = color("ffffff")
    let menuItemSelectBg = color("2258b9")
    let menuItemSelectCellBg = color("2258b9")
    let menuProgressFg = color("1057d4")
    let menuProgressBg = color("749adc")
    let menuFontColor = color("ffffff")
    
    let toolbarColor = color("2b83f1")
    let toolbarProgressFg = color("e0f0ff")
    let toolbarProgressBg = color("44a8e8")
    
    let pathSelectorSelectableItem = color("cfcac5")
    let pathSelectorBg = color("ffffff")
    
    let tableBg = color("ffffff")
    let tableItemBg = color("ffffff")
    let listSelectedBackgroundColor = color("a7cbfc")
    
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
    
    let snackbarBg = color("1b54a9")
    let snackbarTextColor = color("ffffff")
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

