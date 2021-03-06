//
//  Theme.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 30/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

protocol Theme {
	//func color(_ hex: String) -> NSColor
    var isDark: Bool {get}
	var black: NSColor { get }
	var gray: NSColor { get }
	var white: NSColor { get }
	var clear: NSColor { get }
	
	var menuBgColor: NSColor { get }
	
	var menuNavColor: NSColor { get }
	var menuTableColor: NSColor { get }
    var menuProgressFg: NSColor { get }
    var menuProgressBg: NSColor { get }
    var menuFontColor: NSColor {get}
    
	var toolbarColor: NSColor { get }
	var toolbarProgressFg: NSColor { get }
	var toolbarProgressBg: NSColor { get }
	
	var tableBg: NSColor { get }
	var tableItemBg: NSColor { get }
    var tableScrollColor: NSColor{get}
//    var menuItemBg: NSColor { get }
	var menuItemSelectBg: NSColor { get }
	var transferBg: NSColor { get }
	var textColor: NSColor { get }
	var transferTextColor: NSColor { get }
    var transferProgressFg: NSColor { get }
    var transferProgressBg: NSColor { get }
    var menuItemSelectCellBg: NSColor {get}
    var listSelectedBackgroundColor: NSColor{get}

    var pathSelectorSelectableItem: NSColor{get}
    var pathSelectorBg: NSColor{get}
    var pathSelectorTextColor: NSColor {get}
    var pathSelectorLastTextColor: NSColor {get}
    
    var dialogBgColor: NSColor{get}
    var dialogWindowColor: NSColor{get}
    var dialogTextColor: NSColor{get}
    var dialogSelectionColor: NSColor{get}
    var dialogSelectionDangerColor: NSColor{get}
	
	var windowBg: NSColor { get }
    var mainViewColor: NSColor { get }
    
    var snackbarBg: NSColor {get}
    var snackbarTextColor: NSColor {get}
    
    var dockProgressFg: NSColor{get}
    var dockProgressBg: NSColor{get}
    
//    var helpTextColor: NSColor{get}
    var helpBgColor: NSColor{get}
    
    var firstLaunchBg: NSColor{get}
    var firstLaunchText: NSColor{get}
    var firstLaunchCtaText: NSColor{get}
    var firstLaunchCtaBg: NSColor{get}
}

extension Theme {
	/*func color(_ hex: String, withAlpha alpha: CGFloat) -> NSColor {
		return ColorUtils.colorWithHexString(hex, withAlpha: alpha)
	}
	
	func color(_ hex: String) -> NSColor {
		return color(hex, withAlpha: 1.0)
	}*/
	
	static func color(_ hex: String, withAlpha alpha: CGFloat) -> NSColor {
		return ColorUtils.colorWithHexString(hex, withAlpha: alpha)
	}
	
	static func color(_ hex: String) -> NSColor {
		return Self.color(hex, withAlpha: 1.0)
	}
    
    var dockProgressFg: NSColor {get {return Self.color("0ec932")}}
    var dockProgressBg: NSColor {get {return NSColor.clear}}
	
	var black: NSColor {
		get {
			return Self.color("000000")
		}
	}
	var white: NSColor {
		get {
			return Self.color("ffffff")
		}
	}
	var clear: NSColor {
		get {
			return Self.color("000000", withAlpha: 0.0)
		}
	}
	var gray: NSColor {
		get {
			return Self.color("BEBEBE")
		}
	}
}
