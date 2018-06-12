//
//  SelectableTableRowView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class SelectableTableRowView: NSTableRowView {
    
    
    
    override func drawSelection(in dirtyRect: NSRect) {
        if (self.selectionHighlightStyle != NSTableView.SelectionHighlightStyle.none) {
//            NSRect selectionRect = NSInsetRect(self.bounds, 2.5, 2.5);
//            [[NSColor colorWithCalibratedWhite:.65 alpha:1.0] setStroke];
//            [[NSColor colorWithCalibratedWhite:.82 alpha:1.0] setFill];
//            NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionRect xRadius:6 yRadius:6];
//            [selectionPath fill];
//            [selectionPath stroke];

            let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
            NSColor.blue.setStroke()
            NSColor.green.setStroke()
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
            selectionPath.fill()
            selectionPath.stroke()
        }
    }
}
