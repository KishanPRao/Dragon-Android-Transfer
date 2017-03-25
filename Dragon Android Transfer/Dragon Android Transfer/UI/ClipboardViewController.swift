//
//  ClipboardViewController.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 11/03/17.
//  Copyright © 2017 Untitled-TBA. All rights reserved.
//

import Foundation

class ClipboardViewController: NSViewController, NSTableViewDataSource {
	fileprivate let VERBOSE = true;
	@IBOutlet weak var clipboardTable: NSTableView!
	@IBOutlet weak var clipboardMainBG: NSView!
	@IBOutlet weak var clipboardCloseButton: NSButton!
    @IBOutlet weak var totalSizeText: NSTextField!
    @IBOutlet weak var updateSizesButton: NSButton!
	
	fileprivate let transferHandler = TransferHandler.sharedInstance
	
	var clipboardItems: Array<BaseFile>? = []
	var copyItemsAndroid: Array<BaseFile>? = []
	var copyItemsMac: Array<BaseFile>? = []
	var clipboardCloseIcon: NSImage?
	var clipboardDelegate: ClipboardDelegate? = nil
	
	func setClipboardDelegate(_ delegate: ClipboardDelegate) {
		clipboardDelegate = delegate
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		clipboardDelegate?.onOpened()
//		if (VERBOSE) {
//			Swift.print("ClipboardViewController, viewDidLoad");
//		}
		
		clipboardTable.target = self
		
		clipboardTable.backgroundColor = ColorUtils.colorWithHexString(ColorUtils.mainViewColor)
		clipboardTable.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.none
		
		clipboardCloseIcon = NSImage(named: "close_button.png")
		StyleUtils.updateButton(clipboardCloseButton, withImage: clipboardCloseIcon)
		
		let image = NSImage(named: "update_sizes.png")
		StyleUtils.updateButton(updateSizesButton, withImage: image)
		
		ColorUtils.setBackgroundColorTo(clipboardMainBG, color: ColorUtils.statusViewColor)
		
		clipboardItems = transferHandler.getClipboardItems()
		updateSizes()
	}
	
	@IBAction func clipboardButtonTapped(_ sender: AnyObject) {
		self.dismissViewController(self)
	}
	
	@IBAction func updateClipboardSizes(_ sender: AnyObject) {
		transferHandler.updateSizes()
		clipboardItems = transferHandler.getClipboardItems()
		updateSizes()
	}
	
	private func updateSizes() {
		if (clipboardItems!.count > 0) {
			clipboardTable.reloadData()
			var i = 0
			var total: UInt64 = 0
			while i < clipboardItems!.count {
                if (clipboardItems![i].size == UInt64.max || clipboardItems![i].size == 0 || total + clipboardItems![i].size >= UInt64.max) {
                    total = 0
					break
                } else {
					total = total + clipboardItems![i].size
                }
				i = i + 1
			}
			if (total == 0) {
				totalSizeText.stringValue = ""
			} else {
				totalSizeText.stringValue = SizeUtils.getBytesInFormat(total)
			}
		} else {
			totalSizeText.stringValue = ""
		}
	}
	
	func tableView(_ tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
		let cellView = tableView.make(withIdentifier: "clipboardCell", owner: self) as! ClipboardTableCellView
		//      Possibility “This NSLayoutConstraint is being configured with a constant that exceeds internal limits” error to occur. Old version SDK?
		let file = self.clipboardItems![row];
		cellView.nameField!.stringValue = file.fileName
		cellView.nameField!.textColor = ColorUtils.colorWithHexString(ColorUtils.listTextColor)
		cellView.sizeField!.stringValue = SizeUtils.getBytesInFormat(file.size)
		cellView.sizeField!.textColor = ColorUtils.colorWithHexString(ColorUtils.listTextColor)
		if (file.type == BaseFileType.Directory) {
			cellView.fileImage!.image = NSImage(named: "folder")
		} else {
			cellView.fileImage!.image = NSImage(named: "file")
		}
		cellView.showFullPath = false
		cellView.objectValue = file
		ColorUtils.setBackgroundColorTo(cellView, color: ColorUtils.listBackgroundColor)
		return cellView
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return self.clipboardItems!.count
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		print("Clicked Clipboard Item")
	}
	
	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		return 32;
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		print("Adding Observer")
		NotificationCenter.default.addObserver(self, selector: #selector(ClipboardViewController.updateClipboard), name: NSNotification.Name(rawValue: StatusTypeNotification.COPY_FROM_ANDROID), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ClipboardViewController.updateClipboard), name: NSNotification.Name(rawValue: StatusTypeNotification.COPY_FROM_MAC), object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.pasteToAndroid), name: StatusTypeNotification.PASTE_TO_ANDROID, object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.pasteToMac), name: StatusTypeNotification.PASTE_TO_MAC, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ClipboardViewController.activeChange), name: NSNotification.Name(rawValue: StatusTypeNotification.CHANGE_ACTIVE), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ClipboardViewController.clearClipboard), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_CLEAR_CLIPBOARD), object: nil)
	}
	
	func activeChange() {
	}
	
	func clearClipboard() {
		transferHandler.clearClipboardAndroidItems()
		transferHandler.clearClipboardMacItems()
		updateClipboard()
	}
	
	func updateClipboard() {
		clipboardItems = transferHandler.getClipboardItems()
		clipboardTable.reloadData()
		totalSizeText.stringValue = ""
	}
	
	deinit {
		print("Removing Observer")
		NotificationCenter.default.removeObserver(self)
	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
//		if (VERBOSE) {
//			Swift.print("ClipboardViewController, viewDidAppear");
//		}
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
	}
	
	override func viewDidDisappear() {
		super.viewDidDisappear()
		clipboardDelegate?.onClosed()
	}
	
}
