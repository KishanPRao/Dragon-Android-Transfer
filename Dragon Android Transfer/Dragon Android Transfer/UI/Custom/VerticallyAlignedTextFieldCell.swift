//
//  VerticallyAlignedTextFieldCell.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 12/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

//class VerticallyAlignedTextFieldCell: NSTextFieldCell {
//    override func drawingRect(forBounds rect: NSRect) -> NSRect {
//        let newRect = NSRect(x: 0, y: (rect.size.height - 22) / 2, width: rect.size.width, height: 22)
//        return super.drawingRect(forBounds: newRect)
//    }
//}

class VerticallyAlignedTextFieldCell: NSTextFieldCell {
    
    func adjustedFrame(toVerticallyCenterText rect: NSRect) -> NSRect {
        // super would normally draw text at the top of the cell
        var titleRect = super.titleRect(forBounds: rect)
        
        let minimumHeight = self.cellSize(forBounds: rect).height
        titleRect.origin.y += (titleRect.height - minimumHeight) / 2
        titleRect.size.height = minimumHeight
        
        return titleRect
    }
    
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        super.edit(withFrame: adjustedFrame(toVerticallyCenterText: rect), in: controlView, editor: textObj, delegate: delegate, event: event)
    }
    
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        super.select(withFrame: adjustedFrame(toVerticallyCenterText: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.drawInterior(withFrame: adjustedFrame(toVerticallyCenterText: cellFrame), in: controlView)
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.draw(withFrame: cellFrame, in: controlView)
    }
}
