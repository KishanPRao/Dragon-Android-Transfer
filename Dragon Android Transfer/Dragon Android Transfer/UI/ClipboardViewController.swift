//
//  ClipboardViewController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 11/03/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class ClipboardViewController: NSViewController, NSTableViewDataSource {
	fileprivate let VERBOSE = true;
	@IBOutlet weak var clipboardTable: NSTableView!
	@IBOutlet weak var clipboardMainBG: NSView!
	@IBOutlet weak var clipboardCloseButton: NSButton!
	@IBOutlet weak var totalSizeText: NSTextField!
	@IBOutlet weak var totalSizeLabel: NSTextField!
	@IBOutlet weak var updateSizesButton: NSButton!
	@IBOutlet weak var clipboardLabel: NSTextField!
	
	fileprivate let transferHandler = TransferHandler.sharedInstance
	
	var clipboardItems: Array<BaseFile>? = []
	var copyItemsAndroid: Array<BaseFile>? = []
	var copyItemsMac: Array<BaseFile>? = []
	var clipboardCloseIcon: NSImage?
	var clipboardDelegate: ClipboardDelegate? = nil
	var dirtyWindow: Bool = true
	
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
	
	override func viewWillAppear() {
		super.viewWillAppear()
		if (dirtyWindow) {
			updateWindowSize()
		}
	}
	
	override func viewWillLayout() {
		super.viewWillLayout()
		if (dirtyWindow) {
			updateWindowSize()
		}
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
		if (dirtyWindow) {
			updateWindowSize()
		}
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
		cellView.frame = DimenUtils.getUpdatedRect2(frame: cellView.frame, dimensions: [Dimens.clipboard_controller_clip_cell_width, Dimens.clipboard_controller_clip_cell_height])
		//      Possibility “This NSLayoutConstraint is being configured with a constant that exceeds internal limits” error to occur. Old version SDK?
		let file = self.clipboardItems![row];
		let fileName = cellView.nameField!
		fileName.stringValue = file.fileName
		fileName.textColor = ColorUtils.colorWithHexString(ColorUtils.listTextColor)
		fileName.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.clipboard_controller_clip_cell_file_name_text_size))
		fileName.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.clipboard_controller_clip_cell_file_name)
		
		let fileSize = cellView.sizeField!
		fileSize.stringValue = SizeUtils.getBytesInFormat(file.size)
		fileSize.textColor = ColorUtils.colorWithHexString(ColorUtils.listTextColor)
		fileSize.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.clipboard_controller_clip_cell_file_size_text_size))
		fileSize.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.clipboard_controller_clip_cell_file_size)
		
		let fileImage = cellView.fileImage!
		fileImage.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.clipboard_controller_clip_cell_file_image)
		if (file.type == BaseFileType.Directory) {
			fileImage.image = NSImage(named: "folder")
		} else {
			fileImage.image = NSImage(named: "file")
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
//		return 32;
		return DimenUtils.getDimension(dimension: Dimens.clipboard_controller_clip_cell_height) - DimenUtils.getDimension(dimension: Dimens.clipboard_controller_clip_cell_margin)
	}
	
	func updateWindowSize() {
		Swift.print("ClipboardViewController, updateWindowSize")
		if (self.view.window == nil) {
			Swift.print("AndroidViewController, Warning! Null Window")
			return
		}
		let screen = self.view.window!.screen!
		DimenUtils.updateRatio(currentWidth: screen.visibleFrame.width)
		
		
		let windowFrame = self.view.window!.frame
		let newSize = DimenUtils.getUpdatedRect2(frame: windowFrame, dimensions: Dimens.clipboard_controller_size)
		Swift.print("ClipboardViewController, current:", windowFrame.width)
		Swift.print("ClipboardViewController, new:", newSize.width)
		if (newSize.width != windowFrame.width) {
			self.view.window!.setContentSize(NSSize(width: newSize.width, height: newSize.height))
		}
		view.frame = DimenUtils.getUpdatedRect2(frame: view.frame, dimensions: Dimens.clipboard_controller_size)
		
		clipboardMainBG.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.clipboard_controller_main_bg)
		clipboardTable.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.clipboard_controller_clip_table)
		clipboardTable.enclosingScrollView!.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.clipboard_controller_clip_table)
		clipboardTable.reloadData()
		
		totalSizeLabel.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.clipboard_controller_total_size_label)
		totalSizeLabel.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.clipboard_controller_total_size_label_text_size))
		
		totalSizeText.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.clipboard_controller_total_size_text)
		totalSizeText.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.clipboard_controller_total_size_text_size))
		
		updateSizesButton.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.clipboard_controller_update_sizes_button)
		
		clipboardLabel.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.clipboard_controller_clipboard_label)
		clipboardLabel.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.clipboard_controller_clipboard_label_text_size))
		
		clipboardCloseButton.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.clipboard_controller_clipboard_close_button)
		
		dirtyWindow = false
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
		NotificationCenter.default.addObserver(self, selector: #selector(ClipboardViewController.updateWindowSize), name: NSNotification.Name.NSWindowDidChangeScreen, object: nil)
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
