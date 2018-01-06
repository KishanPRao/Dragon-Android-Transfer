//
//  FileOptions.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 06/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift

class FileOptions: NSView {
	@IBOutlet weak var rootView: NSView!
	@IBOutlet weak var copyButton: NSButton!
	@IBOutlet weak var pasteButton: NSButton!
	@IBOutlet weak var deleteButton: NSButton!
	@IBOutlet weak var optionsButton: NSButton!
	
	let transferHandler = TransferHandler.sharedInstance
	
	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		commonInit()
	}
	
	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		commonInit()
	}
	
	private func commonInit() {
		loadNib()
		self.addSubview(rootView)
		copyButton.setImage(name: R.drawable.clipboard)
		pasteButton.setImage(name: R.drawable.paste)
		deleteButton.setImage(name: R.drawable.remove)
		optionsButton.setImage(name: R.drawable.options)
		observeListOptions()
	}
	
//	TODO: Copy direct in Mac?
    @IBAction func copy(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.COPY_FROM_ANDROID), object: nil)
    }
    
    @IBAction func paste(_ sender: Any) {
    }
    
    @IBAction func delete(_ sender: Any) {
    }
    
    @IBAction func options(_ sender: Any) {
    }
    
    
    internal func observeListOptions() {
		AppDelegate.hasClipboardItems.asObservable()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					hasClipboardItems in
//					self.LogV("Clipboard Items: \(hasClipboardItems), count: \(self.transferHandler.getClipboardMacItems().count)")
					let pasteboard = NSPasteboard.general()
//                    if let copiedString = pasteboard.string(forType: NSPasteboardTypeString) {
//                        self.LogI("File: \(copiedString)")
//                    }
                    /*
                    if let copiedString = pasteboard.string(forType: NSPasteboardTypeFileURL) {
                        self.LogI("File: \(copiedString)")
                    }
                    if let copiedString = pasteboard.string(forType: NSPasteboardTypeURL) {
                        self.LogI("File: \(copiedString)")
                    }*/
                    for item in pasteboard.pasteboardItems! {
//                        self.LogI("Item, \(item)", item)
						if let itemData = item.data(forType: kUTTypeFileURL as String),
						   let path = (URL(dataRepresentation: itemData, relativeTo: nil)?.path) {
							self.LogV("Path:", path)
						}
                    }
					if (hasClipboardItems && self.transferHandler.getClipboardMacItems().count > 0) {
						self.pasteButton.isEnabled = true
					} else {
						self.pasteButton.isEnabled = false
					}
				})
	}
}
