//
//  MenuCell.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class MenuCell: NSTableCellView {
    @IBOutlet weak var image: NSImageView!
    @IBOutlet weak var text: NSTextField!
    
    @IBOutlet var contentView: NSView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
 
    
    override init(frame frameRect: Foundation.NSRect) {
        super.init(frame: frameRect)
        Bundle.main.loadNibNamed("MenuCell", owner: self, topLevelObjects: nil)
        Swift.print("Test", contentView.frame, self)
        text.textColor = NSColor.white
        contentView.frame = frame
        addSubview(self.contentView)
        //contentView.autoresizingMask = [.viewMaxXMargin, .viewMinXMargin]
        text.frame.size.width = frame.size.width
        //contentView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        /*
        if let view = self.superview {
            view.needsLayout = true
            view.needsDisplay = true
        }
        if let view = self.contentView {
            view.needsLayout = true
            view.needsDisplay = true
        }*/
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    /*
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }*/
}
