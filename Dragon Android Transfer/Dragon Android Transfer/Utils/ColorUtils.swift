//
//  ColorUtils.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 01/02/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class ColorUtils {
    static let blackColor = "#000000"
	static let mainViewColor = "#424242"
	static let toolbarColor = "#102038"
	static let storageToolbarSelectedColor = "#102038"
	static let storageToolbarPressedSelectedColor = "#102038"
	static let storageToolbarDeselectedColor = "#071326"
	static let storageSelectedTextColor = "#ffffff"
	static let storageDeselectedTextColor = "#bdbdbd"
    static let listBackgroundColor = blackColor
//    static let listItemBackgroundColor = "#29303b"
    static let listItemBackgroundColor = blackColor
    static let listSelectedBackgroundColor = "#092c61"
    static let listDragBackgroundColor = "#000000"
	static let listTextColor = "#ffffff"
	static let statusViewColor = "#071326"
	
	static let progressBackgroundColor = "#0091ea"
	static let progressForegroundColor = "#01579b"
    static let indeterminateProgressForegroundColor = "#17d85e"
    
    static func colorWithHexString(_ hex: String) -> NSColor {
        return ColorUtils.colorWithHexString(hex, withAlpha: 1.0)
    }
    
    static func colorWithHexString(_ hex: String, withAlpha alpha: CGFloat) -> NSColor {
        var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString = (cString as NSString).substring(from: 1)
        }
        
        if cString.count != 6 {
            return NSColor.gray
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return NSColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
    
    static func setBackgroundColorTo(_ view: NSView, color: NSColor) {
        view.wantsLayer = true
        view.layer?.backgroundColor = color.cgColor
    }
	
	static func setBackgroundColorTo(_ view: NSView, color: String) {
		view.wantsLayer = true
		view.layer?.backgroundColor = ColorUtils.colorWithHexString(color).cgColor
	}
}
