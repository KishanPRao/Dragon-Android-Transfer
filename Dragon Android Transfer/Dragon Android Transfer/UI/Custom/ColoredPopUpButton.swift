//
// Created by Kishan P Rao on 04/03/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class ColoredPopUpButton : NSPopUpButtonCell {
	public required init(coder: NSCoder) {
		super.init(coder: coder)
		if (NSObject.VERBOSE) {
			Swift.print("ColoredPopUpButton, init")
		}
	}
	
	
//	required init?(coder aDecoder: NSCoder) {
//		super.init(coder: aDecoder)
////		if (VERBOSE) {
////			Swift.print("ColoredPopUpButton: init:", menu, menuItem, itemArray, itemTitles);
////		}
//	}
	
//	override func drawBorderAndBackgroundWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
////		super.drawBorderAndBackgroundWithFrame(cellFrame, inView: controlView)
//		NSColor.redColor().set()
//		NSRectFill(cellFrame)
//	}
	
//	override func drawSeparatorItemWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
////		super.drawSeparatorItemWithFrame(cellFrame, inView: controlView)
//		NSColor.redColor().set()
//		NSRectFill(cellFrame)
//	}
	
//	override func drawStateImageWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
//		NSColor.redColor().set()
//		NSRectFill(cellFrame)
//		super.drawStateImageWithFrame(cellFrame, inView: controlView)
//	}
	
//	override func drawImageWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
////		super.drawImageWithFrame(cellFrame, inView: controlView)
//		NSColor.redColor().set()
//		NSRectFill(cellFrame)
//	}
//	
//	override func drawTitleWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
////		super.drawTitleWithFrame(cellFrame, inView: controlView)
//		NSColor.redColor().set()
//		NSRectFill(cellFrame)
//	}
//	
////	override func drawKeyEquivalentWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
//////		super.drawKeyEquivalentWithFrame(cellFrame, inView: controlView)
////		NSColor.redColor().set()
////		NSRectFill(cellFrame)
////	}
//	
////	override func drawInteriorWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
//////		super.drawInteriorWithFrame(cellFrame, inView: controlView)
////	}
//	
//	override func drawingRectForBounds(theRect: Foundation.NSRect) -> Foundation.NSRect {
////		return super.drawingRectForBounds(theRect)
//		NSColor.redColor().set()
//		NSRectFill(theRect)
//		return theRect
//	}
//	
//	
//	override func drawWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
////		super.drawWithFrame(cellFrame, inView: controlView)
//		NSColor.redColor().set()
//		NSRectFill(cellFrame)
//	}
//	
//	override func drawFocusRingMaskWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
////		super.drawFocusRingMaskWithFrame(cellFrame, inView: controlView)
//		NSColor.redColor().set()
//		NSRectFill(cellFrame)
//	}
//	
//	
//	override func drawWithExpansionFrame(_ cellFrame: NSRect, inView view: NSView) {
////		super.drawWithExpansionFrame(cellFrame, inView: view)
//		NSColor.redColor().set()
//		NSRectFill(cellFrame)
//	}
//	
////	....
//	
//	override func drawInteriorWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
////		super.drawInteriorWithFrame(cellFrame, inView: controlView)
//		NSColor.redColor().set()
//		NSRectFill(cellFrame)
//	}
//	
//	override func drawImage(image: NSImage, withFrame frame: Foundation.NSRect, inView controlView: NSView) {
////		super.drawImage(image, withFrame: frame, inView: controlView)
//		NSColor.redColor().set()
//		NSRectFill(frame)
//	}
	
//	override func drawTitle(title: NSAttributedString, withFrame frame: Foundation.NSRect, inView controlView: NSView) -> Foundation.NSRect {
////		return super.drawTitle(title, withFrame: frame, inView: controlView)
//		NSColor.redColor().set()
//		NSRectFill(frame)
//		return frame
//	}
	
	override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
		super.draw(withFrame: cellFrame, in: controlView)
		NSColor.red.set()
		NSRectFill(cellFrame)
	}
	
	
//	override func drawSeparatorItem(withFrame cellFrame: NSRect, in controlView: NSView) {
//		super.drawSeparatorItem(withFrame: cellFrame, in: controlView)
//		NSColor.red.set()
//		NSRectFill(cellFrame)
//	}
	
	
//	override func drawStateImageWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
////		super.drawStateImageWithFrame(cellFrame, inView: controlView)
//		NSColor.redColor().set()
//		NSRectFill(cellFrame)
//	}
//	
//	override func drawKeyEquivalentWithFrame(cellFrame: Foundation.NSRect, inView controlView: NSView) {
////		super.drawKeyEquivalentWithFrame(cellFrame, inView: controlView)
//		NSColor.redColor().set()
//		NSRectFill(cellFrame)
//	}
	
//	override func drawBorderAndBackground(withFrame cellFrame: NSRect, in controlView: NSView) {
//		super.drawBorderAndBackground(withFrame: cellFrame, in: controlView)
//		if (NSObject.VERBOSE) {
//			Swift.print("ColoredPopUpButton, drawBorderAndBackgroundWithFrame")
//		}
//		NSColor.red.set()
//		NSRectFill(cellFrame)
//	}
//
//	override func drawBezel(withFrame frame: Foundation.NSRect, in controlView: NSView) {
//		super.drawBezel(withFrame: frame, in: controlView)
//		if (NSObject.VERBOSE) {
//			Swift.print("ColoredPopUpButton: drawBezelWithFrame");
//		}
//		NSColor.yellow.set()
//		NSRectFill(frame)
//	}
	
}
