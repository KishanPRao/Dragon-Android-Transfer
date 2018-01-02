//
//  Theme.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 30/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

protocol Theme {
    func color(_ hex: String) -> NSColor
    var black: NSColor { get }
    var white: NSColor { get }
    var clear: NSColor { get }
	
    var menuBgColor: NSColor { get }
    
    var menuNavColor: NSColor { get }
    var menuTableColor: NSColor { get }
    var toolbarColor: NSColor {get}
    var toolbarProgressFg: NSColor {get}
    var toolbarProgressBg: NSColor {get}
}

extension Theme {
    func color(_ hex: String, withAlpha alpha: CGFloat) -> NSColor {
        return ColorUtils.colorWithHexString(hex, withAlpha: alpha)
    }
    
	func color(_ hex: String) -> NSColor {
        return color(hex, withAlpha: 1.0)
    }
    
    var black: NSColor { get{return color("000000")}}
    var white: NSColor { get{return color("ffffff")}}
    var clear: NSColor { get{return color("000000", withAlpha: 0.0)}}
}