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
                                            alignment: NSTextAlignment = .center,
                                            useUnderline: Bool = false,
                                            color: NSColor = R.color.textColor,
                                            fontName: String = R.font.mainFont) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = alignment
        //        style.headIndent = indentSize
        //        style.firstLineHeadIndent = indentSize
        //        style.tailIndent = -indentSize
        style.lineBreakMode = .byTruncatingTail
        let fontSize = NSFont.systemFontSize
        let attrString = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: attrString.length)
        attrString.beginEditing()
        attrString.addAttribute(NSAttributedStringKey.font,
                                value: NSFont(name: R.font.mainFont, size: fontSize),
                                range: range)
        attrString.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        attrString.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: range)
        /*if (useUnderline) {
            attrString.addAttribute(NSAttributedStringKey.underlineStyle,
                                    value: NSUnderlineStyle.styleSingle.rawValue,
                                    range: range)
        }*/
        attrString.endEditing()
        return attrString
    }
    
    static func attributedBoldString(from string: String,
                                     color: NSColor = R.color.textColor,
                                     nonBoldRange: NSRange? = nil,
                                     fontSize: CGFloat = NSFont.systemFontSize,
                                     _ alignment: NSTextAlignment = .natural) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        style.alignment = alignment
        let attrs = [
            //            TODO: Bold font
            //            NSAttributedStringKey.font: NSFont.boldSystemFont(ofSize: fontSize),
            NSAttributedStringKey.font: NSFont(name: R.font.mainBoldFont, size: fontSize),
            NSAttributedStringKey.foregroundColor: color,
            NSAttributedStringKey.paragraphStyle: style
        ]
        let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
        if let range = nonBoldRange {
            let nonBoldAttribute = [
                //                NSAttributedStringKey.font: NSFont.systemFont(ofSize: fontSize),
                NSAttributedStringKey.font: NSFont(name: R.font.mainFont, size: fontSize)
            ]
            attrStr.setAttributes(nonBoldAttribute, range: range)
        }
        return attrStr
    }
}
