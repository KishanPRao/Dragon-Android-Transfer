//
//  ColorUtils.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 01/02/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class ColorUtils {
	static let mainViewColor = "#424242"
	static let toolbarColor = "#212121"
	static let storageToolbarSelectedColor = "#0091ea"
	static let storageToolbarPressedSelectedColor = "#0277bd"
	static let storageToolbarDeselectedColor = "#616161"
	static let storageSelectedTextColor = "#ffffff"
	static let storageDeselectedTextColor = "#bdbdbd"
    static let listBackgroundColor = "#616161"
    static let listSelectedBackgroundColor = "#0091ea"
    static let listDragBackgroundColor = "#000000"
	static let listTextColor = "#ffffff"
	static let statusViewColor = "#212121"
	static let blackColor = "#000000"
	
	static let progressBackgroundColor = "#0091ea"
	static let progressForegroundColor = "#01579b"
	static let indeterminateProgressForegroundColor = "#17d85e"
	
	static func colorWithHexString(_ hex: String) -> NSColor {
		var cString: String = hex.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
		
		if cString.hasPrefix("#") {
			cString = (cString as NSString).substring(from: 1)
		}
		
		if cString.characters.count != 6 {
			return NSColor.gray
		}
		
		var rgbValue: UInt32 = 0
		Scanner(string: cString).scanHexInt32(&rgbValue)
		
		return NSColor(
				red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
				green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
				blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
				alpha: CGFloat(1.0)
		)
	}
	
	static func setBackgroundColorTo(_ view: NSView, color: String) {
		view.wantsLayer = true
		view.layer?.backgroundColor = ColorUtils.colorWithHexString(color).cgColor
	}
}
