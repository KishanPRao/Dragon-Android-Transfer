//
//  NSButton_Extension.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension NSButton {
	
	public func setImage(image: NSImage) {
		self.image = image
		self.imageScaling = .scaleProportionallyUpOrDown
		self.imagePosition = .imageOnly
		self.isBordered = false
	}
	
	public func setImage(name: String) {
		self.setImage(image: NSImage(named: NSImage.Name(rawValue: name))!)
	}
	
	func setColorBackground(_ color: NSColor, _ rounded: Bool = false) {
		var image = NSImage.swatchWithColor(color: color, size: self.frame.size)
		LogV("Color Bg: \(self.frame.size)")
		if (rounded) {
			image = image.roundCorners()
		}
//		self.setImage(image: image)
		self.image = image
		self.isBordered = false
	}
	
	func setText(text: String, textColor: NSColor,
                 alignment: NSTextAlignment, bgColor: NSColor,
                 rounded: Bool = false) {
		let style = NSMutableParagraphStyle()
		style.alignment = alignment
		var image = NSImage.swatchWithColor(color: bgColor, size: self.frame.size)
		if (rounded) {
			image = image.roundCorners()
		}
		self.setImage(image: image)
		self.imageScaling = .scaleAxesIndependently
        //        Color change not working:
//        self.attributedTitle = TextUtils.attributedBoldString(from: text, color: R.color.white, nonBoldRange: nil, fontSize: 15.0, .center)
//        self.attributedStringValue = TextUtils.attributedBoldString(from: text, color: R.color.white, nonBoldRange: nil, fontSize: 15.0, .center)
	}
    
    func updateMainFont(_ fontSize: CGFloat = 40.0) {
//        let fontSize = self.font?.pointSize ?? 10.0
//        let mainFont = NSFont(name: R.font.mainFont, size: fontSize)
        let mainFont = NSFont(name: R.font.mainFont, size: fontSize)
        self.font = mainFont
    }
}
