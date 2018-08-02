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
    
    static let windowColor = "ececec"
    
    static let menuNavigationColor = color("2044a9")
    let menuNavColor = menuNavigationColor
    let menuTableColor = menuNavigationColor
//    let menuBgColor = color("071a34", withAlpha: 0.4)
//    let menuBgColor = color("002366", withAlpha: 0.4)
    let menuBgColor = color("000000", withAlpha: 0.4)
//    let menuItemBg = color("ffffff")
    static let menuItemSelectBgColor = "5772e1"
    let menuItemSelectBg = color(menuItemSelectBgColor)
    let menuItemSelectCellBg = color(menuItemSelectBgColor)
    let menuProgressFg = color("7d9be4")
    let menuProgressBg = color("ebefff")
    let menuFontColor = color("ffffff")
    
    let toolbarColor = color("5172d1")
    let toolbarProgressFg = color("f8fbff")
    let toolbarProgressBg = color("6caaf0")
    
//    let pathSelectorSelectableItem = color("cfcac5")
//    let pathSelectorBg = color("ffffff")
//    let pathSelectorSelectableItem = color("f7f7f7")
    let pathSelectorSelectableItem = color("ffffff")
    let pathSelectorBg = color("d8dbdf")
    
    let tableBg = color(windowColor)
    let tableItemBg = color(windowColor)
    let listSelectedBackgroundColor = color("bfcbff")
    
//    let transferBg = color("f8f8f8")
    let transferBg = color("f8f9fd")
    let transferTextColor = color("505050")
    let transferProgressFg = color("6789f7")
    let transferProgressBg = color("646669")
    
    let dialogBgColor = color("edecec")
    let dialogWindowColor = color("edecec")
    let dialogTextColor = color("2c2c2c")
    let dialogSelectionColor = color("79bdfc")
    let dialogSelectionDangerColor = color("f14545")
    
    let windowBg = color("fafafa")
    let mainViewColor = color("424242")
    
    let snackbarBg = color("7281c1")
    let snackbarTextColor = color("e8e8e8")
    
    let helpBgColor = color("fafafa")
    let tableScrollColor = color("fefefe")
    
    
    let pathSelectorTextColor = color("d3d8df")
    let pathSelectorLastTextColor = color("ffffff")
    
    let firstLaunchBg = color("fafafa")
    let firstLaunchText = color("222222")
    let firstLaunchCtaText = color("ffffff")
    let firstLaunchCtaBg = color("7f7f7f")
}

