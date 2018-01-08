//
//  HelpWindow.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 12/03/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Cocoa

class HelpWindow: NSWindowController {
    @IBOutlet weak var textClipView: NSClipView!
    @IBOutlet var helpText: NSTextView!
	var mainW: NSWindow = NSWindow()
    @IBOutlet weak var textScrollView: NSScrollView!
	fileprivate var isIntro = false
	fileprivate var initialized = false
	var isShowing = false
//	init() {
//		super.init()
//	}
    @IBOutlet weak var closeButton: NSButton!

	func setIsIntro(intro: Bool) {
		self.isIntro = intro
		updateText()
	}
	
	override init(window: NSWindow!) {
		super.init(window: window)
		//Initialization code here.
	}
	
	required init(coder: NSCoder) {
		super.init(coder: coder)!;
	}
	
	override func windowDidLoad() {
		super.windowDidLoad()
		Swift.print("HelpWindow, windowDidLoad")
		isShowing = true
		initialized = true
        // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
        ColorUtils.setBackgroundColorTo(self.window!.contentView!, color: ColorUtils.blackColor)
        ColorUtils.setBackgroundColorTo(helpText, color: ColorUtils.blackColor)
//                ColorUtils.setBackgroundColorTo(textScrollView, color: ColorUtils.blackColor)
//                ColorUtils.setBackgroundColorTo(textClipView, color: ColorUtils.blackColor)
//		if let rtfPath = Bundle.mainBundle().URLForResource("help", withExtension: "rtf") {
		updateText()
		updateSizes()
	}
	
	func updateText() {
		if (NSObject.VERBOSE) {
			Swift.print("HelpWindow, update Text, init:", initialized)
		}
		if (!initialized) {
			return
		}
		var fileName = "help"
		if (isIntro) {
			fileName = "intro_guide"
		}
		if let rtfPath = Bundle.main.path(forResource: fileName, ofType: "rtf") {
			helpText.readRTFD(fromFile: rtfPath)
		}
		
		let length = helpText.string!.count
		self.helpText.scrollRangeToVisible(NSRange(location: 0, length: length))
		helpText.needsDisplay = true
		helpText.needsLayout = true
		helpText.enclosingScrollView!.hasHorizontalScroller = false
		helpText.enclosingScrollView!.horizontalScrollElasticity = NSScrollElasticity.none
	}
	
	func needsUpdating() -> Bool {
		let origFrame = self.window!.frame
		let newFrame = DimenUtils.getUpdatedRect2(frame: origFrame, dimensions: Dimens.help_window)
		return origFrame.width != newFrame.width
	}
	
	func updateSizes() {
		Swift.print("HelpWindow, update Sizes, init:", initialized)
		if (!initialized) {
			return
		}
//		let origFrame = self.contentViewController!.view.frame
		let origFrame = self.window!.frame
//		self.window!.setFrame(DimenUtils.getUpdatedRect2(frame: origFrame, dimensions: Dimens.help_window), display: true)
//        self.window!.setFrame(DimenUtils.getUpdatedRect2(frame: origFrame, dimensions: Dimens.help_window), display: true)
		
		textScrollView.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.help_window_text)
		
//		helpText.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.hew)
		helpText.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.help_window_text_size))
		
		closeButton.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.help_window_close_text_size))
		closeButton.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.help_window_close)
		closeButton.needsDisplay = true
		closeButton.needsLayout = true
		
		let length = helpText.string!.count
		self.helpText.scrollRangeToVisible(NSRange(location: 0, length: length))
		helpText.needsDisplay = true
		helpText.needsLayout = true
		helpText.enclosingScrollView!.hasHorizontalScroller = false
		helpText.enclosingScrollView!.horizontalScrollElasticity = NSScrollElasticity.none
	}
	
	func cancel(_ sender: Any) {
		if (NSObject.VERBOSE) {
			Swift.print("HelpWindow, cancel!")
		}
		endSheet()
	}
	
	//method called to slide out the modal window
	func endSheet() {
		isShowing = false
//        NSApp.endSheet(self.window!)
		self.window!.endSheet(self.window!)
		self.window!.orderOut(mainW)
	}
	
	@IBAction func closeHelp(_ sender: Any) {
		self.endSheet();
	}
}
