//
//  TextUtils.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 04/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class TextUtils {
    static func getTruncatedAttributeString(_ text: String, _ color: NSColor = R.color.white) -> NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        //        style.headIndent = indentSize
        //        style.firstLineHeadIndent = indentSize
        //        style.tailIndent = -indentSize
        style.lineBreakMode = .byTruncatingTail
        return NSMutableAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: style
        ])
    }
}
