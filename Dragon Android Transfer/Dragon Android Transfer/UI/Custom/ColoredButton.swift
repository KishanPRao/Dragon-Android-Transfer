//
// Created by Kishan P Rao on 04/03/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class ColoredButton: NSButton {
	var normalColor: NSColor = NSColor.black
	var pressedColor: NSColor = NSColor.blue
	var pressedSelectedColor: NSColor = NSColor.cyan
	var textSelectedColor: NSColor = NSColor.white
	var textDeselectedColor: NSColor = NSColor.gray
	var isSelected: Bool = false
//	var currentFont: NSFont?
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		if (NSObject.VERBOSE) {
//			Swift.print("ColoredButton: init");
		}
		setSelected(isSelected)
	}
	
	func updateSelected() {
		setSelected(isSelected)
	}
	
	func setSelected(_ selected: Bool) {
		isSelected = selected
		if (NSObject.VERBOSE) {
//			Swift.print("ColoredButton: Selected:", isSelected, ", Title:", title);
		}
//		if (currentFont == nil) {
//			currentFont = NSFont(name: font!.fontName, size: DimenUtils.getDimension(dimension: Dimens.android_controller_device_selector_storage_text_size))
//		}
		let style = NSMutableParagraphStyle()
		style.alignment = .center
		var attrsDictionary: [NSAttributedStringKey: AnyObject]
		if (isSelected) {
			attrsDictionary = [NSAttributedStringKey.foregroundColor: textSelectedColor, NSAttributedStringKey.paragraphStyle: style, NSAttributedStringKey.font: font!];
		} else {
			attrsDictionary = [NSAttributedStringKey.foregroundColor: textDeselectedColor, NSAttributedStringKey.paragraphStyle: style, NSAttributedStringKey.font: font!];
		}
//        NSAttributedString(string: title, attributes: attrsDictionary)
		let attString = NSAttributedString(string: title, attributes: attrsDictionary)
		attributedTitle = attString
		setNeedsDisplay()
	}
	
	override func draw(_ dirtyRect: Foundation.NSRect) {
		if (NSObject.VERBOSE) {
//			Swift.print("ColoredButton: draw, Highlighted:", isHighlighted, ", Selected:", isSelected, ", Title:", title);
		}
		if (isHighlighted) {
//			if (isSelected && highlighted) {
			pressedSelectedColor.set()
//			} else {
//				pressedColor.set()
//			}
		} else if (isSelected) {
			pressedColor.set()
		} else {
			normalColor.set()
//			NSRectFill(dirtyRect)
		}
		dirtyRect.fill()
		super.draw(dirtyRect)
	}
}
