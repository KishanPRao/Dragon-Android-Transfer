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
	
	var isSelected: Bool = false {
		didSet {
			/*
			if (isSelected) {
				self.contentView.setBackground(R.color.menuItemSelectCellBg)
			} else {
//                self.contentView.setBackground(R.color.menuTableColor)
				self.contentView.setBackground(NSColor.clear)
//                self.contentView.wantsLayer = false
			}*/
		}
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
	
	override init(frame frameRect: Foundation.NSRect) {
		super.init(frame: frameRect)
		Bundle.main.loadNibNamed(NSNib.Name(rawValue: "MenuCell"), owner: self, topLevelObjects: nil)
//        Swift.print("Test", contentView.frame, self)
		text.textColor = R.color.white
		text.updateMainFont()
//        contentView.setBackground(R.color.black)
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
//        setBackground(R.color.black)
	}

//    override func drawBackgroundInRect(dirtyRect: NSRect) {
//        let context: CGContext = NSGraphicsContext.currentContext()!.CGContext
//
//        if !self.selected {
//            CGContextSetFillColorWithColor(context, NSColor.clearColor().CGColor)
//        } else {
//            CGContextSetFillColorWithColor(context, NSColor.redColor().CGColor)
//        }
//
//        CGContextFillRect(context, dirtyRect)
//    }
	
	override func resize(withOldSuperviewSize oldSize: NSSize) {
		super.resize(withOldSuperviewSize: oldSize)
//        contentView.frame = frame
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	/*
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}*/
}
