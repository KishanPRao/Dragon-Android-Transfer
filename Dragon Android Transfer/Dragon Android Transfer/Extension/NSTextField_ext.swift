//
//  NSTextField_ext.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 12/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

extension NSTextField {
    
    func updateMainFont(_ inFontSize: CGFloat? = nil) {
        let fontSize = inFontSize ?? (self.font?.pointSize ?? 10.0)
        let mainFont = NSFont(name: R.font.mainFont, size: fontSize)
        self.font = mainFont
    }
    
    func updateMainFontInIncrement(_ incrementAmount: CGFloat? = nil) {
        let fontSize = (self.font?.pointSize ?? 10.0) + (incrementAmount ?? 0.0)
        let mainFont = NSFont(name: R.font.mainFont, size: fontSize)
        self.font = mainFont
    }
}
