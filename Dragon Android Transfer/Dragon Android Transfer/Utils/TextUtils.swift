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
											_ color: NSColor = R.color.white,
                                            _ fontName: String = R.font.mainFont) -> NSAttributedString {
		let style = NSMutableParagraphStyle()
		style.alignment = alignment
		//        style.headIndent = indentSize
		//        style.firstLineHeadIndent = indentSize
		//        style.tailIndent = -indentSize
		style.lineBreakMode = .byTruncatingTail
        let fontSize = NSFont.systemFontSize()
		return NSMutableAttributedString(string: text, attributes: [
            NSFontAttributeName: NSFont(name: R.font.mainFont, size: fontSize),
			NSForegroundColorAttributeName: color,
			NSParagraphStyleAttributeName: style
		])
	}
	
	static func attributedBoldString(from string: String, color: NSColor,
                                     nonBoldRange: NSRange?,
                                     _ alignment: NSTextAlignment = .natural) -> NSAttributedString {
		let fontSize = NSFont.systemFontSize()
		let style = NSMutableParagraphStyle()
		style.lineBreakMode = .byTruncatingTail
		style.alignment = alignment
		let attrs = [
            //            TODO: Bold font
			NSFontAttributeName: NSFont.boldSystemFont(ofSize: fontSize),
			NSForegroundColorAttributeName: color,
			NSParagraphStyleAttributeName: style
		]
		let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
		if let range = nonBoldRange {
			let nonBoldAttribute = [
                NSFontAttributeName: NSFont.systemFont(ofSize: fontSize),
//                NSFontAttributeName: NSFont(name: R.font.mainFont, size: fontSize)
			]
			attrStr.setAttributes(nonBoldAttribute, range: range)
		}
		return attrStr
	}
}
