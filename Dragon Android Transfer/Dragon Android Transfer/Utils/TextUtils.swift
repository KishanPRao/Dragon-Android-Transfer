//
//  TextUtils.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 04/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class TextUtils {
	static func getTruncatedAttributeString(_ text: String, 
											_ alignment: NSTextAlignment = .center,
											_ color: NSColor = R.color.white) -> NSAttributedString {
		let style = NSMutableParagraphStyle()
		style.alignment = alignment
		//        style.headIndent = indentSize
		//        style.firstLineHeadIndent = indentSize
		//        style.tailIndent = -indentSize
		style.lineBreakMode = .byTruncatingTail
		return NSMutableAttributedString(string: text, attributes: [
			NSForegroundColorAttributeName: color,
			NSParagraphStyleAttributeName: style
		])
	}
	
	static func attributedString(from string: String, color: NSColor, nonBoldRange: NSRange?) -> NSAttributedString {
		let fontSize = NSFont.systemFontSize()
		let style = NSMutableParagraphStyle()
		style.lineBreakMode = .byTruncatingTail
		style.alignment = .natural
		let attrs = [
			NSFontAttributeName: NSFont.boldSystemFont(ofSize: fontSize),
			NSForegroundColorAttributeName: color,
			NSParagraphStyleAttributeName: style
		]
		let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
		if let range = nonBoldRange {
			let nonBoldAttribute = [
				NSFontAttributeName: NSFont.systemFont(ofSize: fontSize),
			]
			attrStr.setAttributes(nonBoldAttribute, range: range)
		}
		return attrStr
	}
}
