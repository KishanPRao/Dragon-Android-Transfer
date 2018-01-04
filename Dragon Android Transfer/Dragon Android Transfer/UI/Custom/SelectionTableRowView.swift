//
//  SelectionTableRowView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 04/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class SelectionTableRowView: NSTableRowView {
    /*
    static let radius = 3.0 as CGFloat
    
    override func drawSelection(in dirtyRect: NSRect) {
        if self.selectionHighlightStyle != .none {
//            let selectionRect = NSInsetRect(self.bounds, 0, 0)
//            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
            let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
//            R.color.menuItemSelectBg.setStroke()
            R.color.menuItemSelectBg.setFill()
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect,
                                                  xRadius: SelectionTableRowView.radius,
                                                  yRadius: SelectionTableRowView.radius)
            selectionPath.fill()
            selectionPath.stroke()
        }
    }*/
    
    
    override var isSelected: Bool {
        willSet(newValue) {
            super.isSelected = newValue;
            needsDisplay = true
        }
    }
    
    
    override func drawBackground(in dirtyRect: NSRect) {
        let context: CGContext = NSGraphicsContext.current()!.cgContext
        
        if self.isSelected {
            context.setFillColor(R.color.menuItemSelectBg.cgColor)
//            context.setFillColor(R.color.menuItemBg.cgColor)
        } else {
            context.setFillColor(self.backgroundColor.cgColor)
//            context.setFillColor(R.color.menuItemBg.cgColor)
        }
        
        context.fill(dirtyRect)
    }
}

