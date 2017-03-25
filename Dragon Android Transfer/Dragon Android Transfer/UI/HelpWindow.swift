//
//  HelpWindow.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 12/03/17.
//  Copyright © 2017 Untitled-TBA. All rights reserved.
//

import Cocoa

class HelpWindow: NSWindowController {
	private static let VERBOSE = true;

    @IBOutlet weak var textClipView: NSClipView!
    @IBOutlet var helpText: NSTextView!
	var mainW: NSWindow = NSWindow()
    @IBOutlet weak var textScrollView: NSScrollView!
//	init() {
//		super.init()
//	}
	
	override init(window: NSWindow!) {
		super.init(window: window)
		//Initialization code here.
	}
	
	required init(coder: NSCoder) {
		super.init(coder: coder)!;
	}
	
	override func windowDidLoad() {
		super.windowDidLoad()
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        ColorUtils.setBackgroundColorTo(self.window!.contentView!, color: ColorUtils.blackColor)
        ColorUtils.setBackgroundColorTo(helpText, color: ColorUtils.blackColor)
//                ColorUtils.setBackgroundColorTo(textScrollView, color: ColorUtils.blackColor)
//                ColorUtils.setBackgroundColorTo(textClipView, color: ColorUtils.blackColor)
        helpText.string = StringUtils.helpString
		let length = StringUtils.helpString.characters.count
		self.helpText.scrollRangeToVisible(NSRange(location: 0, length: length))
		helpText.needsDisplay = true
		helpText.needsLayout = true
//		textScrollView.drawsBackground = false
        //		helpText.drawsBackground = false
//        self.window?.backgroundColor = NSColor.clear
//        self.window?.backgroundColor = NSColor.clear
//		self.window?.isOpaque = false
	
	
//		textClipView.drawsBackground = false
		
//		if let cell = helpText.cell as? NSTextFieldCell {
//			if (HelpWindow.VERBOSE) {
//				Swift.print("HelpWindow, cell");
//				cell.isScrollable = true
//			}
//		}
//		TODO: Use NSTextView
	}
	
	//method called to slide out the modal window
	func endSheet() {
//        NSApp.endSheet(self.window!)
		self.window!.endSheet(self.window!)
		self.window!.orderOut(mainW)
	}
	
	@IBAction func closeHelp(_ sender: Any) {
		self.endSheet();
	}
}
