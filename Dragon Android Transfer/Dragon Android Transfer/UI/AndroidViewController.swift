//
//  AndroidViewController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/16.
//  Copyright © 2016 Kishan P Rao. All rights reserved.
//

import Cocoa
import MASShortcut

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func <<T:Comparable>(lhs: T?, rhs: T?) -> Bool {
	switch (lhs, rhs) {
	case let (l?, r?):
		return l < r
	case (nil, _?):
		return true
	default:
		return false
	}
}


class AndroidViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDataSource, NSComboBoxDelegate, NSControlTextEditingDelegate,
		FileProgressDelegate, DeviceNotficationDelegate, ClipboardDelegate, CopyDialogDelegate, NSUserInterfaceValidations {
	private static let VERBOSE = false;
	
	var androidDirectoryItems: Array<BaseFile> = []
	@IBOutlet weak var fileTable: DraggableTableView!
	@IBOutlet weak var backButton: NSButtonCell!
	@IBOutlet weak var overlayView: OverlayView!
//    @IBOutlet weak var devicesBox: NSComboBox!
	@IBOutlet weak var devicesPopUp: NSPopUpButtonCell!
	
	@IBOutlet weak var statusView: NSView!

//    TODO: Try other phones! Or keep backup as /sdcard, if check..
//	let INIT_DIRECTORY = "/sdcard"
//    let INIT_DIRECTORY = "/storage"
	
	var androidDevices: NSMutableArray = []
	@IBOutlet weak var toolbarView: NSView!
	@IBOutlet weak var deviceSelectorView: NSView!
	@IBOutlet weak var currentDirectoryText: NSTextField!
	@IBOutlet weak var spaceStatusText: NSTextField!
	@IBOutlet weak var refreshButton: NSButton!
	@IBOutlet weak var currentDirectoryLabel: NSTextField!
	@IBOutlet weak var spaceStatusLabel: NSTextField!
	
	@IBOutlet weak var internalStorageButton: ColoredButton!
	@IBOutlet weak var externalStorageButton: ColoredButton!
	
	@IBOutlet weak var messageText: NSTextField!
	
	@IBOutlet weak var devicesPopupButton: NSPopUpButton!
	@IBOutlet weak var clipboardItemsCount: DisabledTextField!
	@IBOutlet weak var clipboardButton: NSButton!
	
	var clipboardIcon: NSImage?
	var clipboardIconPlain: NSImage?
	
	var progress: CGFloat = 0
	var copyDialog = nil as CopyDialog?
	
	fileprivate var copyDestination = ""
	fileprivate var currentCopyFile = ""
	fileprivate var transferType = -1
	fileprivate var currentFile: BaseFile? = nil
	fileprivate var currentCopiedSize = 0 as UInt64
	
	fileprivate let transferHandler = TransferHandler.sharedInstance
	fileprivate var dirtyWindow: Bool = true
	fileprivate var showGuide: Bool = false
	
	var helpWindow: HelpWindow? = nil
	
	private var needsUpdatePopupDimens = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		print("View Loaded")
		transferHandler.setDeviceNotificationDelegate(self)
		
		showGuide = transferHandler.isFirstLaunch()
		transferHandler.initializeAndroid()
		
		fileTable.target = self
		fileTable.reloadData()
		let doubleClickSelector: Selector = #selector(AndroidViewController.doubleClickList(_:))
		fileTable.doubleAction = doubleClickSelector
		fileTable.allowsMultipleSelection = true
		
		self.devicesPopUp.removeAllItems()
		self.devicesPopUp.action = #selector(AndroidViewController.onPopupSelected(_:))
		self.devicesPopUp.target = self
		updatePopupDimens()
		
		overlayView.isHidden = true
		
		setBackgroundColorTo(view, color: ColorUtils.mainViewColor)
		setBackgroundColorTo(toolbarView, color: ColorUtils.toolbarColor)
		setBackgroundColorTo(deviceSelectorView, color: ColorUtils.storageToolbarDeselectedColor)
		setBackgroundColorTo(statusView, color: ColorUtils.statusViewColor)
		
		internalStorageButton.normalColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarDeselectedColor)
		internalStorageButton.pressedColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarSelectedColor)
		internalStorageButton.pressedSelectedColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarPressedSelectedColor)
		internalStorageButton.textSelectedColor = ColorUtils.colorWithHexString(ColorUtils.storageSelectedTextColor)
		internalStorageButton.textDeselectedColor = ColorUtils.colorWithHexString(ColorUtils.storageDeselectedTextColor)
		
		externalStorageButton.normalColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarDeselectedColor)
		externalStorageButton.pressedColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarSelectedColor)
		externalStorageButton.pressedSelectedColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarPressedSelectedColor)
		externalStorageButton.textSelectedColor = ColorUtils.colorWithHexString(ColorUtils.storageSelectedTextColor)
		externalStorageButton.textDeselectedColor = ColorUtils.colorWithHexString(ColorUtils.storageDeselectedTextColor)
		
		fileTable.backgroundColor = ColorUtils.colorWithHexString(ColorUtils.mainViewColor)
		fileTable.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.none
		
		externalStorageButton.isHidden = true
		
		var image = NSImage(named: "back_button.png")
		image!.size = backButton.cellSize
		backButton.image = image!
		
//		backButton.imageScaling = NSImageScaling.ScaleProportionallyDown
//		backButton.imageScaling = NSImageScaling.ScaleProportionallyUpOrDown
		backButton.imageScaling = NSImageScaling.scaleAxesIndependently
		
		clipboardIcon = NSImage(named: "clipboard_icon.png")
		clipboardIconPlain = NSImage(named: "clipboard_icon_plain.png")
		StyleUtils.updateButton(clipboardButton, withImage: clipboardIcon)
		
		image = NSImage(named: "refresh.png")
		updateButton(refreshButton, withImage: image)
//		backButton.imageScaling = NSImageScaling.ScaleProportionallyDown
//		clipboardButton.scale = NSImageScaling.ScaleProportionallyUpOrDown
		messageText.alignment = NSCenterTextAlignment
		messageText.font = NSFont(name: messageText.font!.fontName, size: DimenUtils.getDimension(dimension: Dimens.error_message_text_size))
		updateDeviceStatus()
		updateActiveStorageButton()

//		Testing:
//		showCopyDialog()
//		getScreenResolution()
		transferHandler.start()
	}
	
	private func updatePopupDimens() {
		devicesPopUp.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_toolbar_device_popup_text_size))
		let popupRect = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_toolbar_device_popup)
		var width: CGFloat
		if (androidDevices.count > 0) {
			devicesPopupButton.sizeToFit()
			width = devicesPopupButton.frame.width
		} else {
			width = popupRect.width
		}
		devicesPopupButton.frame = CGRect(x: popupRect.origin.x, y: popupRect.origin.y, width: width, height: popupRect.height)
	}
	
	fileprivate func updateButton(_ button: NSButton, withImage image: NSImage?) {
		if let cell = button.cell as? NSButtonCell {
			image!.size = cell.cellSize
			cell.image = image!
			cell.imageScaling = NSImageScaling.scaleAxesIndependently
		}
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return self.androidDirectoryItems.count
	}
	
	func updateDeviceStatus() {
		if (!transferHandler.hasActiveDevice()) {
			AppDelegate.hasItems = false
			AppDelegate.canGoBackward = false
			AppDelegate.hasMacClipboardItems = false
			AppDelegate.itemSelected = false
			AppDelegate.directoryItemSelected = false
			AppDelegate.multipleItemsSelected = false
			AppDelegate.hasClipboardItems = false
			
			messageText.isHidden = false
			messageText.stringValue = "No Active Device.\nPlease connect a device with USB Debugging enabled."
			return
		}
		
		if (androidDirectoryItems.count == 0) {
			AppDelegate.hasItems = false
			
			messageText.isHidden = false
			messageText.stringValue = "Empty Directory"
		} else {
			AppDelegate.hasItems = true
			
			messageText.isHidden = true
		}
		
		AppDelegate.itemSelected = false
		AppDelegate.directoryItemSelected = false
		AppDelegate.multipleItemsSelected = false
		
		if (transferHandler.getClipboardMacItems().count > 0) {
			AppDelegate.hasMacClipboardItems = true
		} else {
			AppDelegate.hasMacClipboardItems = false
		}
		
		if (transferHandler.isRootDirectory()) {
			AppDelegate.canGoBackward = false
		} else {
			AppDelegate.canGoBackward = true
		}
//		if (AndroidViewController.VERBOSE) {
//			Swift.print("AndroidViewController, Can go backward:", AppDelegate.canGoBackward);
//		}
	}
	
	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
//		return 25
		return DimenUtils.getDimension(dimension: Dimens.android_controller_file_table_file_cell_height) - DimenUtils.getDimension(dimension: Dimens.android_controller_file_table_file_cell_margin)
	}
	
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		if (AndroidViewController.VERBOSE) {
//			TODO: Check later..
			Swift.print("AndroidViewController: select:", row, ", Table:", tableView, ", FileTable:", fileTable, ", Item:", androidDirectoryItems[row]);
		}
//		if (tableView == fileTable) {
//			let rowItem = tableView.rowView(atRow: row, makeIfNecessary: true)
//			//        print("Row:", rowItem?.viewAtColumn(0))
//			let cellView = rowItem?.view(atColumn: 0) as! NSView
//			setBackgroundColorTo(cellView, color: ColorUtils.listSelectedBackgroundColor)
//		}
		return true
	}
	
	@IBAction func tableSelectionChanged(_ sender: Any) {
		if (AndroidViewController.VERBOSE) {
			Swift.print("AndroidViewController: tableSelectionChanged:", fileTable.selectedRow);
		}
	}
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		if (row >= self.androidDirectoryItems.count) {
			print("Warning: Row out of range!")
			return nil
		}
		let cellView = tableView.make(withIdentifier: "fileCell", owner: self) as! FileCellView
		cellView.frame = DimenUtils.getUpdatedRect2(frame: cellView.frame, dimensions: [Dimens.android_controller_file_table_file_cell_width, Dimens.android_controller_file_table_file_cell_height])
		
		//        print("Items:", self.androidDirectoryItems)
		//      Possibility “This NSLayoutConstraint is being configured with a constant that exceeds internal limits” error to occur. Old version SDK?
		let file = self.androidDirectoryItems[row];
		//            print("File:", file)
		let fileName = cellView.nameField!
		fileName.stringValue = file.fileName
		fileName.textColor = ColorUtils.colorWithHexString(ColorUtils.listTextColor)
		fileName.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_file_table_file_cell_file_name_text_size))
		fileName.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table_file_cell_file_name)
		
		let fileSize = cellView.sizeField!
		fileSize.stringValue = SizeUtils.getBytesInFormat(file.size)
		fileSize.textColor = ColorUtils.colorWithHexString(ColorUtils.listTextColor)
		fileSize.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_file_table_file_cell_file_size_text_size))
		fileSize.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table_file_cell_file_size)
		
		let fileImage = cellView.fileImage!
		fileImage.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table_file_cell_file_image)
		if (file.type == BaseFileType.Directory) {
			fileImage.image = NSImage(named: "folder")
		} else {
			fileImage.image = NSImage(named: "file")
		}
		let indexSet = fileTable.selectedRowIndexes
		if (indexSet.contains(row)) {
			setBackgroundColorTo(cellView, color: ColorUtils.listSelectedBackgroundColor)
		} else {
			setBackgroundColorTo(cellView, color: ColorUtils.listBackgroundColor)
		}
		return cellView
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
		if (self.fileTable.numberOfSelectedRows > 0) {
			let selectedItem = self.androidDirectoryItems[self.fileTable.selectedRow].fileName
			print("Selected:", selectedItem)
			
			let indexSet = fileTable.selectedRowIndexes
			var i = 0
			AppDelegate.itemSelected = false
			AppDelegate.multipleItemsSelected = false
			AppDelegate.directoryItemSelected = false
			var itemSelected = false
			while (i < androidDirectoryItems.count) {
				let rowItem = fileTable.rowView(atRow: i, makeIfNecessary: false)
				if (rowItem != nil) {
					let cellView = rowItem?.view(atColumn: 0) as! NSView
					if (indexSet.contains(i)) {
						setBackgroundColorTo(cellView, color: ColorUtils.listSelectedBackgroundColor)
						
						if (itemSelected) {
							AppDelegate.multipleItemsSelected = true
						}
						itemSelected = true
						if (self.androidDirectoryItems[i].type == BaseFileType.Directory) {
							AppDelegate.directoryItemSelected = true
						}
						AppDelegate.itemSelected = true
					} else {
						setBackgroundColorTo(cellView, color: ColorUtils.listBackgroundColor)
					}
				}
				i = i + 1
			}
		}
	}
	
	func onPopupSelected(_ sender: AnyObject) {
		let index = self.devicesPopUp.indexOfSelectedItem
		print("Popup Selected:", index)
		var activeDevice = nil as AndroidDevice?
		if (index > -1) {
			activeDevice = androidDevices[index] as? AndroidDevice
		}
		updateActiveDevice(activeDevice)
	}

//    func numberOfItemsInComboBox(aComboBox: NSComboBox) -> Int {
//        return self.androidDevices!.count
//    }
//
//    func comboBox(aComboBox: NSComboBox, objectValueForItemAtIndex index: Int) -> AnyObject {
//        return (self.androidDevices![index] as! AndroidDevice).name
//    }
//
//    func comboBox(aComboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
//        return self.androidDevices!.indexOfObject(string)
//    }
//
//    func comboBoxSelectionDidChange(notification: NSNotification) {
//        print("Selection Changed:", devicesBox.indexOfSelectedItem)
//        if (devicesBox.indexOfSelectedItem > -1) {
//            let selectedDevice = androidDevices?.objectAtIndex(devicesBox.indexOfSelectedItem)
//            print("Selection Changed:", selectedDevice)
//        } else {
////            devicesBox.sele
//        }
//    }
	
	
	
	override func viewWillAppear() {
		super.viewWillAppear()
//        start()
		if (fileTable.acceptsFirstResponder) {
			self.view.window?.makeFirstResponder(fileTable)
//			if (AndroidViewController.VERBOSE) {
//				Swift.print("AndroidViewController, First Responder!");
//			}
		}
		if (dirtyWindow) {
			updateWindowSize()
		}
		checkGuide()
	}
	
	override func viewWillLayout() {
		super.viewWillLayout()
		Swift.print("AndroidViewController, viewWillLayout")
		if (dirtyWindow) {
			updateWindowSize()
		}
		checkGuide()
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
		if (dirtyWindow) {
			updateWindowSize()
		}
		checkGuide()
	}
	
	func shouldShowGuide() -> Bool {
		return showGuide
	}
	
	func checkGuide() {
		if (showGuide) {
//			TODO: Guide.
			if (AndroidViewController.VERBOSE) {
				Swift.print("AndroidViewController, Opening Intro Guide")
			}
//			if (NSApplication.shared().mainWindow == nil) {
//				if (AndroidViewController.VERBOSE) {
//					Swift.print("AndroidViewController, Warning, window not created yet!")
//				}
//				return
//			}
//			let delegate = NSApplication.shared().delegate as! AppDelegate
//			delegate.showHelpWindow([])
			showHelpWindow()
			showGuide = false
		}
	}
	
	override func updateViewConstraints() {
		super.updateViewConstraints()
		Swift.print("AndroidViewController, 2")
	}
	
	override func viewWillDisappear() {
		super.viewWillDisappear()
//        self.stop()
	}
	
	func onConnected(_ device: AndroidDevice) {
//        print("Connected:", )
	}
	
	func onDisconnected(_ device: AndroidDevice) {
		
	}
	
	func onUpdate() {
		print("onUpdate")
		let devices = transferHandler.getAndroidDevices()
		var devicesNames = [] as Array<String>
		var i = 0
		androidDevices.removeAllObjects()
		androidDevices.addObjects(from: devices)
		while i < devices.count {
			devicesNames.append(devices[i].name)
			i = i + 1
		}
		self.devicesPopUp.removeAllItems()
		self.devicesPopUp.addItems(withTitles: devicesNames)
		let selectedIndex = self.devicesPopUp.indexOfSelectedItem
		print("Update Selected:", selectedIndex)
		externalStorageButton.isHidden = true
		updatePopupDimens()
		var activeDevice = nil as AndroidDevice?
		if (selectedIndex > -1) {
			activeDevice = devices[selectedIndex]
		}
		updateActiveDevice(activeDevice)
	}
	
	fileprivate func updateActiveDevice(_ activeDevice: AndroidDevice?) {
		if (AndroidViewController.VERBOSE) {
			Swift.print("AndroidViewController, update:" + TimeUtils.getCurrentTime());
		}
		transferHandler.setActiveDevice(activeDevice)
		if (activeDevice != nil) {
			androidDirectoryItems = transferHandler.openDirectoryData(transferHandler.getInternalStorage())
			transferHandler.setUsingExternalStorage(false)
			transferHandler.updateStorage()
			spaceStatusText.stringValue = transferHandler.getAvailableSpace() + " of " + transferHandler.getTotalSpaceInString()
			if (transferHandler.getExternalStorage() != "") {
				externalStorageButton.isHidden = false
			}
		} else {
			reset()
		}
		updateList()
		updateClipboard()
		updateActiveStorageButton()
		updateDeviceStatus()
		if (AndroidViewController.VERBOSE) {
			Swift.print("AndroidViewController, update fin:" + TimeUtils.getCurrentTime());
		}
	}
	
	fileprivate func updateActiveStorageButton() {
		if (transferHandler.hasActiveDevice()) {
			if (transferHandler.isUsingExternalStorage()) {
				externalStorageButton.setSelected(true)
				internalStorageButton.setSelected(false)
			} else {
				externalStorageButton.setSelected(false)
				internalStorageButton.setSelected(true)
			}
		} else {
			externalStorageButton.setSelected(false)
			internalStorageButton.setSelected(false)
		}
	}
	
	func start() {
//		transferHandler.start()
	}
	
	func stop() {
//		transferHandler.stop()
	}
	
	func doubleClickList(_ sender: AnyObject) {
		print("Double Clicked:", fileTable.clickedRow)
		if (fileTable.clickedRow < 0) {
			return
		}
		let selectedItem = self.androidDirectoryItems[fileTable.clickedRow].fileName
//		print("Selected", fileTable.selectedRowIndexes)
		
		if (transferHandler.isDirectory(selectedItem)) {
			reloadFileList(transferHandler.openDirectoryData(transferHandler.getCurrentPath() + HandlerConstants.SEPARATOR + selectedItem))
		} else {
			self.fileTable.deselectRow(self.fileTable.selectedRow)
		}
	}
	
	func openSelectedDirectory() {
		if (AndroidViewController.VERBOSE) {
			Swift.print("AndroidViewController, openSelectedDirectory");
		}
		let selectedItem = self.androidDirectoryItems[fileTable.selectedRow].fileName
//		print("Selected", fileTable.selectedRow)
//		print("Selected", self.androidDirectoryItems[fileTable.selectedRow])
		
		if (transferHandler.isDirectory(selectedItem)) {
			reloadFileList(transferHandler.openDirectoryData(transferHandler.getCurrentPath() + HandlerConstants.SEPARATOR + selectedItem))
		} else {
			self.fileTable.deselectRow(self.fileTable.selectedRow)
		}
	}
	
	func getSelectedItemInfo() {
		if (AndroidViewController.VERBOSE) {
			Swift.print("AndroidViewController, getSelectedItemInfo");
		}
		let selectedFile = self.androidDirectoryItems[fileTable.selectedRow]
		print("Selected", fileTable.selectedRow)
		print("Selected", self.androidDirectoryItems[fileTable.selectedRow])
		
		transferHandler.updateAndroidFileSize(file: selectedFile)
		let alert = NSAlert()
		alert.messageText = "Name: " + selectedFile.fileName
		var infoText: String = ""
		var image: NSImage
		if (selectedFile.type == BaseFileType.Directory) {
			image = NSImage(named: "folder")!
		} else {
			image = NSImage(named: "file")!
		}
		if (AndroidViewController.VERBOSE) {
			Swift.print("AndroidViewController, image size:", image.size);
		}
		alert.icon = image
		infoText = "Path: " + selectedFile.path + "\n"
		var type = "File"
		if (selectedFile.type == BaseFileType.Directory) {
			type = "Directory"
		}
		infoText = infoText + "Type: " + type + "\n"
		infoText = infoText + "Size: " + SizeUtils.getBytesInFormat(selectedFile.size) + "\n"
		alert.informativeText = infoText
		alert.runModal()
//		alert.addButton(withTitle: "Ok")
//		let response = alert.runModal()
//		if (AndroidViewController.VERBOSE) {
//			Swift.print("AndroidViewController, alert resp:", response);
//		}
	}
	
	func activeChange() {
//        print("Active Changed:", AppDelegate.isAppInForeground())
		if (AppDelegate.isAppInForeground()) {
			start()
		} else {
			stop()
		}
	}
	
	func onStart(_ totalSize: UInt64, transferType: Int) {
		AppDelegate.isPastingOperation = true
		overlayView.isHidden = false;
		currentCopyFile = ""
		showCopyDialog()
		if (copyDialog != nil) {
			var transferTypeString = ""
			if (transferType == TransferType.AndroidToMac) {
				transferTypeString = "Copy From Android To Mac"
			} else if (transferType == TransferType.MacToAndroid) {
				transferTypeString = "Copy From Mac To Android"
			}
			self.transferType = transferType
			print("Transfer Type:", transferTypeString)
			copyDialog?.setTotalCopySize(totalSize)
			copyDialog?.setTransferType(transferTypeString)
		}
	}
	
	func currentFile(_ fileName: String) {
		if (copyDialog != nil && currentCopyFile != fileName) {
//            currentCopyFile = fileName
			var files: Array<BaseFile>?
			if (transferType == TransferType.AndroidToMac) {
				files = transferHandler.getClipboardAndroidItems()
			} else if (transferType == TransferType.MacToAndroid) {
				files = transferHandler.getClipboardMacItems()
			}
			var i = 0
			print("Files:", files)
			print("File Name:", fileName)
			currentCopiedSize = 0
			while (i < files!.count) {
				if (fileName.contains(files![i].fileName)) {
					currentFile = files![i]
					currentCopyFile = currentFile!.fileName
					break
				}
				currentCopiedSize = currentCopiedSize + files![i].size
				i = i + 1
			}
			print("Update Current File:", currentCopyFile)
			copyDialog?.setCurrentTransfer(currentCopyFile, to: copyDestination)
		}
	}
	
	func onProgress(_ progress: Int) {
		if (copyDialog != nil) {
//			print("Current Copy Size:", currentCopiedSize)
//            copyDialog?.setProgress(CGFloat(progress))
			if (currentFile != nil) {
//				if (AndroidViewController.VERBOSE) {
//					Swift.print("AndroidViewController, progress:", progress);
//				}
				let currentFileCopiedSize = UInt64(CGFloat(currentFile!.size) * (CGFloat(progress) / 100.0)) as UInt64
				copyDialog?.setCopiedSize(currentCopiedSize + currentFileCopiedSize)
			}
		}
	}
	
	func onCompletion() {
		AppDelegate.isPastingOperation = false
		print("Done!")
		
		print("End Time:", TimeUtils.getCurrentTime())
		NSSound(named: "endCopy")?.play()
		NSApp.requestUserAttention(NSRequestUserAttentionType.informationalRequest)
		overlayView.isHidden = true;
		if (copyDialog != nil) {
//            copyDialog!.rootView.removeFromSuperview()
			copyDialog!.removeFromSuperview()
			copyDialog = nil
			currentFile = nil
		}
		refresh()
	}
	
	func copyFromAndroid(_ notification: Notification) {
		print("Copy From Android")
		print("Selected", fileTable.selectedRowIndexes)
		let indexSet = fileTable.selectedRowIndexes
		var currentIndex = indexSet.first
		transferHandler.clearClipboardMacItems()
		transferHandler.clearClipboardAndroidItems()
		var copyItemsAndroid: Array<BaseFile> = []
//        Swift.print("Index:", currentIndex)
//        Swift.print("Index:", indexSet)
//        Swift.print("Index:", indexSet.first)
		
		while (currentIndex != nil && currentIndex != NSNotFound) {
			let currentItem = androidDirectoryItems[currentIndex!];
			copyItemsAndroid.append(currentItem)
			print("Current Index:", currentIndex, " Item:", currentItem.fileName)
			currentIndex = indexSet.integerGreaterThan(currentIndex!)
		}
		print("Copy:", copyItemsAndroid)
		transferHandler.updateClipboardAndroidItems(copyItemsAndroid)
		updateClipboard()
	}
	
	func copyFromMac(_ notification: Notification) {
		print("Copy From Mac", TimeUtils.getCurrentTime())
		var copyItemsMac: Array<BaseFile> = []
		if (transferHandler.isFinderActive()) {
			transferHandler.clearClipboardMacItems()
			transferHandler.clearClipboardAndroidItems()
			copyItemsMac = transferHandler.getActiveFiles()
			print("Copy:", copyItemsMac, TimeUtils.getCurrentTime())
			transferHandler.updateClipboardMacItems(copyItemsMac)
		} else {
			print("Warning, inactive Finder")
		}
		updateClipboard()
	}
	
	fileprivate func updateClipboard() {
		if (transferHandler.getClipboardItems()!.count > 0) {
			updateButton(clipboardButton, withImage: clipboardIconPlain)
			clipboardItemsCount.stringValue = String(transferHandler.getClipboardItems()!.count)
		} else {
			updateButton(clipboardButton, withImage: clipboardIcon)
			clipboardItemsCount.stringValue = ""
		}
		
		if (transferHandler.getClipboardMacItems().count > 0) {
			AppDelegate.hasMacClipboardItems = true
		} else {
			AppDelegate.hasMacClipboardItems = false
		}
		
		if (transferHandler.getClipboardItems()!.count > 0) {
			AppDelegate.hasClipboardItems = true
		} else {
			AppDelegate.hasClipboardItems = false
		}
	}
	
	fileprivate func showCopyDialog() {
		let width = DimenUtils.getDimensionInInt(dimension: Dimens.copy_dialog_width)
		let height = DimenUtils.getDimensionInInt(dimension: Dimens.copy_dialog_height)
		let x = Int(getWindowWidth() / 2) - width / 2
		let y = Int(getWindowHeight() / 2) - height / 2
		copyDialog = CopyDialog(frame: CGRect(x: x, y: y, width: width, height: height))
		copyDialog!.setCopyDialogDelegate(delegate: self)
		copyDialog!.updateSize(x: x, y: y, width: width, height: height)
		self.view.addSubview(copyDialog!)
	}
	
	private func getWindowHeight() -> CGFloat {
		return self.view.bounds.height
	}
	
	private func getWindowWidth() -> CGFloat {
		return self.view.bounds.width
	}
	
	private func getScreenResolution() {
		let screenArray = NSScreen.screens()
		var index = 0
		while (index < screenArray!.count) {
			let screen = screenArray![index]
			index = index + 1
			Swift.print("AndroidViewController, screen:", screen)
//			screen.
		}
		Swift.print("AndroidViewController, screens:", screenArray)
//		let screenRect = 
	}
	
	func screenUpdated() {
		updateWindowSize()
		checkGuide()
	}
	
	func updateWindowSize() {
		if (self.view.window == nil) {
			Swift.print("AndroidViewController, Warning! Null Window")
			return
		}
		let screen = self.view.window!.screen!
//		Swift.print("AndroidViewController, current screen:", screen.visibleFrame.width)
		DimenUtils.updateRatio(currentWidth: screen.visibleFrame.width)
		
		let windowFrame = self.view.window!.frame
		let newSize = DimenUtils.getUpdatedRect2(frame: windowFrame, dimensions: Dimens.android_controller_size)
		let extraHeight = (screen.frame.height - screen.visibleFrame.height) + (screen.frame.origin.y - screen.visibleFrame.origin.y)
		
		let finalRect = CGRect(x: newSize.origin.x, y: newSize.origin.y + (windowFrame.height - newSize.height) - extraHeight, width: newSize.width, height: newSize.height + extraHeight)

//		Swift.print("AndroidViewController, previous:", windowFrame)
//		Swift.print("AndroidViewController, new:", finalRect)
		
		if (finalRect.width == windowFrame.width) {
            if (AndroidViewController.VERBOSE) {
                Swift.print("AndroidViewController, Warning! No Changes to Window")
            }
			return
		}
//		TODO: Fix flickering screen update, if occurs again..
//		Swift.print("AndroidViewController, extra H:", extraHeight)
//		Swift.print("AndroidViewController, frame:", screen.frame)
//		Swift.print("AndroidViewController, v frame:", screen.visibleFrame)
//		Swift.print("AndroidViewController, origin:", self.view.window!.frame.origin.y)
//		self.view.window!.setContentSize(NSSize(width: newSize.width, height: newSize.height))
		self.view.window!.setFrame(finalRect, display: true)
		view.frame = DimenUtils.getUpdatedRect2(frame: view.frame, dimensions: Dimens.android_controller_size)
		
		toolbarView.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_toolbar)
		clipboardButton.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_toolbar_clipboard_button)
		clipboardItemsCount.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_toolbar_clipboard_items_count)
		clipboardItemsCount.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_toolbar_clipboard_items_count_text_size))
		updatePopupDimens()
		
		backButton.controlView!.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_toolbar_back)
		
		deviceSelectorView.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_device_selector)
		internalStorageButton.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_device_selector_storage_text_size))
		internalStorageButton.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_device_selector_internal)
		internalStorageButton.updateSelected()
		externalStorageButton.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_device_selector_storage_text_size))
		externalStorageButton.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_device_selector_external)
		externalStorageButton.updateSelected()
//		Swift.print("AndroidViewController, ext frame:", externalStorageButton.frame)
		
		statusView.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_status_view)
		currentDirectoryLabel.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_status_view_current_directory_label_text_size))
		currentDirectoryLabel.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_status_view_current_directory_label)
		currentDirectoryText.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_status_view_current_directory_text_size))
		currentDirectoryText.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_status_view_current_directory_text)
		spaceStatusLabel.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_status_view_space_status_label_size))
		spaceStatusLabel.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_status_view_space_status_label)
		spaceStatusText.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_status_view_space_status_text_size))
		spaceStatusText.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_status_view_space_status_text)
		refreshButton.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_status_view_refresh)
		
		fileTable.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table)
//		let scrollViewFrame = fileTable.enclosingScrollView!.frame
		fileTable.enclosingScrollView!.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table)
		updateList()
		
		overlayView.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_overlay)
		
		messageText.font = NSFont(name: messageText.font!.fontName, size: DimenUtils.getDimension(dimension: Dimens.error_message_text_size))
		messageText.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.error_message_text)
		
		if (copyDialog != nil) {
			let width = DimenUtils.getDimensionInInt(dimension: Dimens.copy_dialog_width)
			let height = DimenUtils.getDimensionInInt(dimension: Dimens.copy_dialog_height)
			let x = Int(getWindowWidth() / 2) - width / 2
			let y = Int(getWindowHeight() / 2) - height / 2
			copyDialog!.updateSize(x: x, y: y, width: width, height: height)
		}
//		if (helpWindow != nil && helpWindow!.isShowing) {
		if (helpWindow != nil && helpWindow!.isShowing && helpWindow!.needsUpdating()) {
//			helpWindow!.updateSizes()
			Swift.print("AndroidViewController, updating Help")
			helpWindow!.endSheet()
			helpWindow!.setIsIntro(intro: shouldShowGuide())
			helpWindow!.updateSizes()
			helpWindow!.isShowing = true
			self.view.window!.beginSheet(helpWindow!.window!) { response in
				if (AndroidViewController.VERBOSE) {
					Swift.print("AndroidViewController, Resp!");
				}
			}
		}
		dirtyWindow = false
	}
	
	func showHelpWindow() {
		if (helpWindow == nil) {
			helpWindow = HelpWindow(windowNibName: "HelpWindow")
		}
		if (self.view.window == nil) {
			if (AndroidViewController.VERBOSE) {
				Swift.print("AndroidViewController, Warning, window not created yet!")
			}
			return
		}
//		let window = NSApplication.shared().mainWindow!
		let window = self.view.window!
//		let androidViewController = getAndroidController()
//		if (androidViewController != nil) {
//		helpWindow!.setIsIntro(intro: androidViewController!.shouldShowGuide())
		helpWindow!.setIsIntro(intro: shouldShowGuide())
		helpWindow!.updateSizes()
		helpWindow!.isShowing = true
		window.beginSheet(helpWindow!.window!) { response in
			if (AndroidViewController.VERBOSE) {
				Swift.print("AndroidViewController, Resp!");
			}
		}
//		}
	}
	
	func selectAllFiles() {
		fileTable.selectAll(nil)
	}
	
	func pasteToAndroid(_ notification: Notification) {
		print("Paste to Android")
		let files = transferHandler.getClipboardMacItems()
		if (files.count == 0) {
			if (AndroidViewController.VERBOSE) {
				Swift.print("AndroidViewController, paste to android, Warning, NO ITEMS");
			}
			return
		} else {
			var i = 0
			var updateSizes = false
			while (i < files.count) {
				if (files[i].size == 0 || files[i].size == UInt64.max) {
					updateSizes = true
				}
				i = i + 1
			}
			if (updateSizes) {
				transferHandler.updateSizes()
			}
		}
		copyDestination = transferHandler.getCurrentPath()
		AppDelegate.isPastingOperation = true
		transferHandler.push(files, destination: transferHandler.getCurrentPath(), delegate: self)
	}
	
	func pasteToMac(_ notification: Notification) {
		print("Paste to Mac")
		let files = transferHandler.getClipboardAndroidItems()
		if (files!.count == 0) {
			if (AndroidViewController.VERBOSE) {
				Swift.print("AndroidViewController, paste to mac, Warning, NO ITEMS");
			}
			return
		}
		copyDestination = transferHandler.getActivePath()
		AppDelegate.isPastingOperation = true
		transferHandler.pull(files!, destination: transferHandler.getActivePath(), delegate: self)
	}
	
	func clearClipboard() {
		if (AndroidViewController.VERBOSE) {
			Swift.print("AndroidViewController, clearClipboard");
		}
		transferHandler.clearClipboardAndroidItems()
		transferHandler.clearClipboardMacItems()
		updateClipboard()
	}
	
	func cancelTask() {
		if (AndroidViewController.VERBOSE) {
			Swift.print("AndroidViewController, Cancel Active Task");
		}
		transferHandler.cancelActiveTask()
	}
	
	func updateList() {
		currentDirectoryText.stringValue = transferHandler.getCurrentPathForDisplay()
		fileTable.reloadData()
		updateDeviceStatus()
	}
	
	func reloadFileList(_ items: Array<BaseFile>) {
		androidDirectoryItems = items
		updateList()
	}
	
	@IBAction func useInternalStorage(_ sender: AnyObject) {
		transferHandler.setUsingExternalStorage(false)
		updateToStorage(transferHandler.getInternalStorage())
	}
	
	@IBAction func useExternalStorage(_ sender: AnyObject) {
		transferHandler.setUsingExternalStorage(true)
		updateToStorage(transferHandler.getExternalStorage())
	}
	
	fileprivate func updateToStorage(_ storage: String) {
		if (transferHandler.hasActiveDevice()) {
			androidDirectoryItems = transferHandler.openDirectoryData(storage)
			transferHandler.updateStorage()
			spaceStatusText.stringValue = transferHandler.getAvailableSpace() + " of " + transferHandler.getTotalSpaceInString()
		} else {
			reset()
		}
		updateList()
//		copyItemsAndroid?.removeAll()
		transferHandler.clearClipboardAndroidItems()
		updateClipboard()
		updateActiveStorageButton()
	}
	
	fileprivate func reset() {
		print("Reset!")
		transferHandler.reset()
		androidDirectoryItems = []
		spaceStatusText.stringValue = ""
		currentDirectoryText.stringValue = ""
	}
	
	@IBAction func backButtonPressed(_ button: NSButton) {
		let directoryData = transferHandler.upDirectoryData()
		if ((directoryData?.count)! > 0) {
			reloadFileList(directoryData!)
		}
	}
	
	@IBAction func refreshButtonTapped(_ sender: AnyObject) {
		refresh()
//        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector:#selector(AndroidViewController.testMethod), userInfo: nil, repeats: true)
	}
	
	func refresh() {
		reloadFileList(transferHandler.openDirectoryData(transferHandler.getCurrentPath()))
		transferHandler.updateStorage()
		if (transferHandler.hasActiveDevice()) {
			spaceStatusText.stringValue = transferHandler.getAvailableSpace() + " of " + transferHandler.getTotalSpaceInString()
		}
	}
	
	func resetPosition() {
		let previousFrame = self.view.window!.frame
//		let rect = CGRect(x: previousFrame.origin.x, y: 0, width: previousFrame.width, height: previousFrame.height)
		let screenFrame = self.view.window!.screen!.frame
		let screenVisibleFrame = self.view.window!.screen!.visibleFrame
//		Swift.print("AndroidViewController, before, visible:", screenVisibleFrame, ", frame:", screenFrame, ", prev:", previousFrame)
		let extraHeight = (screenFrame.height - screenVisibleFrame.height) + (screenFrame.origin.y - screenVisibleFrame.origin.y)
		let y = (screenVisibleFrame.height / 2) - (previousFrame.height / 2) + screenVisibleFrame.origin.y + extraHeight
		let x = (screenVisibleFrame.width / 2) - (previousFrame.width / 2) + screenVisibleFrame.origin.x
		let rect = CGRect(x: x, y: y, width: previousFrame.width, height: previousFrame.height)
//		Swift.print("AndroidViewController, visible:", screenVisibleFrame, ", frame:", screenFrame, ", rect:", rect)
		self.view.window!.setFrame(rect, display: true)
	}

//    var timer: NSTimer? = nil
	
	@IBAction func clipboardButtonTapped(_ sender: AnyObject) {
		if (!clipboardOpened) {
			clipboardOpened = true
			self.performSegue(withIdentifier: ViewControllerIdentifier.ClipboardId, sender: self)
		} else {
			if (AndroidViewController.VERBOSE) {
				Swift.print("AndroidViewController, Warning, trying to open multiple times!");
			}
		}
	}
	
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		if (AndroidViewController.VERBOSE) {
			Swift.print("AndroidViewController, item:", item);
		}
		return AppDelegate.validateInterfaceMenuItem(item: item)
	}
	
	var clipboardOpened = false
	
	func onOpened() {
		clipboardOpened = true
	}
	
	func onClosed() {
		clipboardOpened = false
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		let clipboardVC = segue.destinationController as! ClipboardViewController
		clipboardVC.setClipboardDelegate(self)
//		if (AndroidViewController.VERBOSE) {
//			Swift.print("AndroidViewController, Prepare Segue!");
//		}
	}
	
	
	func setBackgroundColorTo(_ view: NSView, color: String) {
		view.wantsLayer = true
		view.layer?.backgroundColor = ColorUtils.colorWithHexString(color).cgColor
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		print("Adding Observer")
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.copyFromAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.COPY_FROM_ANDROID), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.copyFromMac), name: NSNotification.Name(rawValue: StatusTypeNotification.COPY_FROM_MAC), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.pasteToAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.PASTE_TO_ANDROID), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.pasteToMac), name: NSNotification.Name(rawValue: StatusTypeNotification.PASTE_TO_MAC), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.stop), name: NSNotification.Name(rawValue: StatusTypeNotification.STOP), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.activeChange), name: NSNotification.Name(rawValue: StatusTypeNotification.CHANGE_ACTIVE), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.checkGuide), name: NSNotification.Name(rawValue: StatusTypeNotification.FINISHED_LAUNCH), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.screenUpdated), name: NSNotification.Name.NSWindowDidChangeScreen, object: nil)

//		Menu Item Related
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.openSelectedDirectory), name: NSNotification.Name(rawValue: StatusTypeNotification.OPEN_FILE), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.backButtonPressed), name: NSNotification.Name(rawValue: StatusTypeNotification.GO_BACKWARD), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.copyFromAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_COPY_FILES), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.pasteToAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_PASTE_FILES), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.selectAllFiles), name: NSNotification.Name(rawValue: StatusTypeNotification.SELECT_ALL), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.clearClipboard), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_CLEAR_CLIPBOARD), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.getSelectedItemInfo), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_GET_INFO), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.refresh), name: NSNotification.Name(rawValue: StatusTypeNotification.REFRESH_FILES), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.resetPosition), name: NSNotification.Name(rawValue: StatusTypeNotification.RESET_POSITION), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.showHelpWindow), name: NSNotification.Name(rawValue: StatusTypeNotification.SHOW_HELP), object: nil)
	}
	
	deinit {
		print("Removing Observer")
		NotificationCenter.default.removeObserver(self)
		transferHandler.release()
	}
}
