//
//  AndroidViewController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/16.
//  Copyright © 2016 Kishan P Rao. All rights reserved.
//

import Cocoa

//import AppKit

import MASShortcut
import RxSwift
import RxCocoa

class AndroidViewController: NSViewController, /*NSTableViewDelegate,*/
		NSComboBoxDataSource, NSComboBoxDelegate, NSControlTextEditingDelegate,
//		FileProgressDelegate,
		ClipboardDelegate, CopyDialogDelegate,
		DragNotificationDelegate, DragUiDelegate,
		NSUserInterfaceValidations {
	
	internal let bgScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
	internal let tableDelegate = DeviceTableDelegate()
	internal var _androidDirectoryItems: Array<BaseFile> = []
	internal var androidDirectoryItems: Array<BaseFile> {
		get {
			return self._androidDirectoryItems
		}
		set {
			self._androidDirectoryItems = newValue
			tableDelegate.setAndroidDirectoryItems(items: self._androidDirectoryItems)
		}
	}
	@IBOutlet weak var fileTable: DraggableTableView!
	@IBOutlet weak var backButton: NSButtonCell!
	//@IBOutlet weak var overlayView: OverlayView!
    internal var overlayView: OverlayView!
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
	
	internal var clipboardIcon: NSImage?
	internal var clipboardIconPlain: NSImage?
	
	internal var copyDialog = nil as CopyDialog?
	
	internal var copyDestination = ""
	internal var currentCopyFile = ""
	internal var transferType = -1
	internal var currentFile: BaseFile? = nil
	internal var currentCopiedSize = 0 as UInt64
	
	internal let transferHandler = TransferHandler.sharedInstance
	internal var showGuide: Bool = false
	
	internal var helpWindow: HelpWindow? = nil
	
	internal var needsUpdatePopupDimens = false
	
	internal let mDockTile: NSDockTile = NSApplication.shared().dockTile
	internal var mDockProgress: NSProgressIndicator? = nil
	
    internal var mCircularProgress: IndeterminateProgressView? = nil
    
    internal var mCurrentProgress = -1.0
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		print("View Loaded")
		// transferHandler.setDeviceNotificationDelegate(self)
		
		showGuide = transferHandler.isFirstLaunch()
		let data = NSDataAsset.init(name: "adb")?.data
		transferHandler.initializeAndroid(data!)
		
		self.initUi()

//		Testing:
//		showCopyDialog()
//		getScreenResolution()
		transferHandler.start()
		
		observeDevices()
		observeListing()
		observeTransfer()
    }
	
	func updateDeviceStatus() {
		if (!transferHandler.hasActiveDevice()) {
			AppDelegate.reset()
			
			messageText.isHidden = false
			messageText.stringValue = "No Active Device.\nPlease connect a device with USB Debugging enabled."
			return
		}
		
		if (androidDirectoryItems.count == 0) {
			AppDelegate.hasItems = false
			messageText.stringValue = "Empty Directory"
			messageText.isHidden = false
		} else {
			AppDelegate.hasItems = true
			messageText.isHidden = true
		}
		AppDelegate.itemSelected = false
		AppDelegate.directoryItemSelected = false
		AppDelegate.multipleItemsSelected = false
//		AppDelegate.hasMacClipboardItems = transferHandler.getClipboardMacItems().count > 0
		AppDelegate.canGoBackward = !transferHandler.isRootDirectory()
//		if (NSObject.VERBOSE) {
//			Swift.print("AndroidViewController, Can go backward:", AppDelegate.canGoBackward);
//		}
	}
    
    internal func reset() {
        print("Reset!")
        transferHandler.reset()
        androidDirectoryItems = []
        spaceStatusText.stringValue = ""
        currentDirectoryText.stringValue = ""
    }
	
	internal var previousIndex = -1
	
	func onPopupSelected(_ sender: AnyObject) {
		let index = self.devicesPopUp.indexOfSelectedItem
		print("Popup Selected:", index)
		if (previousIndex != index) {
			var activeDevice = nil as AndroidDevice?
			if (index > -1) {
				activeDevice = androidDevices[index] as? AndroidDevice
			}
			updateActiveDevice(activeDevice)
		}
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
//        start()
		if (fileTable.acceptsFirstResponder) {
			self.view.window?.makeFirstResponder(fileTable)
//			if (NSObject.VERBOSE) {
//				Swift.print("AndroidViewController, First Responder!");
//			}
		}
		NotificationCenter.default.addObserver(self, selector: #selector(windowMoved), name: NSNotification.Name.NSWindowDidMove, object: self.view.window!)
        updateWindowSize()
		checkGuide()
	}
	
	override func viewWillLayout() {
		super.viewWillLayout()
		Swift.print("AndroidViewController, viewWillLayout")
		
        updateWindowSize()
		checkGuide()
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
		
        updateWindowSize()
		checkGuide()
	}
	
	func shouldShowGuide() -> Bool {
		return showGuide
	}
	
	func checkGuide() {
		if (showGuide) {
//			TODO: Guide.
			if (NSObject.VERBOSE) {
				Swift.print("AndroidViewController, Opening Intro Guide")
			}
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
	}
	
	func onDisconnected(_ device: AndroidDevice) {
	}
	
	internal func updateActiveStorageButton() {
		if (transferHandler.hasActiveDevice()) {
			let usingExternal = transferHandler.isUsingExternalStorage()
			externalStorageButton.setSelected(usingExternal)
			internalStorageButton.setSelected(!usingExternal)
		} else {
			externalStorageButton.setSelected(false)
			internalStorageButton.setSelected(false)
		}
	}
	
	func doubleClickList(_ sender: AnyObject) {
		print("Double Clicked:", fileTable.clickedRow)
		if (fileTable.clickedRow < 0) {
			LogW("Bad Row")
			return
		}
		let selectedItem = self.androidDirectoryItems[fileTable.clickedRow]
		openFile(selectedItem)
	}
    
    func start() {
        //		transferHandler.start()
    }
    
    func stop() {
        //		transferHandler.stop()
    }
	
	func activeChange() {
//        print("Active Changed:", AppDelegate.isAppInForeground())
		if (AppDelegate.isAppInForeground()) {
			start()
		} else {
			stop()
		}
	}
	
	func successfulOperation() {
		NSSound(named: "endCopy")?.play()
		NSApp.requestUserAttention(NSRequestUserAttentionType.informationalRequest)
    }
	
	internal func updateClipboard() {
		let clipboardItems = transferHandler.getClipboardItems() 
		if (clipboardItems.count > 0) {
			StyleUtils.updateButtonWithCell(clipboardButton, withImage: clipboardIconPlain)
			clipboardItemsCount.stringValue = String(clipboardItems.count)
		} else {
			StyleUtils.updateButtonWithCell(clipboardButton, withImage: clipboardIcon)
			clipboardItemsCount.stringValue = ""
		}
//		AppDelegate.hasMacClipboardItems = transferHandler.getClipboardMacItems().count > 0
		AppDelegate.hasClipboardItems = clipboardItems.count > 0
	}
	
	func selectAllFiles() {
		fileTable.selectAll(nil)
	}
	
	func clearClipboard() {
		if (NSObject.VERBOSE) {
			Swift.print("AndroidViewController, clearClipboard");
		}
		transferHandler.clearClipboardAndroidItems()
		transferHandler.clearClipboardMacItems()
	}
	
	@IBAction func useInternalStorage(_ sender: AnyObject) {
		// self.showProgress()
		transferHandler.setUsingExternalStorage(false)
		updateToStorage(transferHandler.getInternalStorage())
		// self.hideProgress()
	}
	
	@IBAction func useExternalStorage(_ sender: AnyObject) {
		// self.showProgress()
		transferHandler.setUsingExternalStorage(true)
		updateToStorage(transferHandler.getExternalStorage())
		// self.hideProgress()
    }
	
	@IBAction func backButtonPressed(_ button: NSButton) {
        navigateUpDirectory()
	}
	
	@IBAction func refreshButtonTapped(_ sender: AnyObject) {
		refresh()
	}

//    var timer: NSTimer? = nil
	
	func windowMoved() {
		LogV("Win Moved", view.window?.frame)
		if let window = vc?.view.window {
			var frame = window.frame
			frame.origin = view.window!.frame.origin
//			window.setFrame(frame, display: false)
//			vc?.update(frame)
			window.setFrameOrigin(frame.origin)
		}
	}
	
	@IBAction func clipboardButtonTapped(_ sender: AnyObject) {
		/*
         if (!clipboardOpened) {
			clipboardOpened = true
			self.performSegue(withIdentifier: ViewControllerIdentifier.ClipboardId, sender: self)
		} else {
			if (NSObject.VERBOSE) {
				Swift.print("AndroidViewController, Warning, trying to open multiple times!");
			}
		}
         */
        
        let window = self.view.window!
        var frameSize = window.frame
//        frameSize.size = NSSize(width: window.frame.width * 0.75, height: frameSize.height - window.titlebarHeight)
        frameSize.size = NSSize(width: window.frame.width, height: frameSize.height - window.titlebarHeight)
        //frameSize.size = NSSize(width: 50, height: 50)
        /*
        let frameworkBundle = Bundle.main
        let storyBoard = NSStoryboard(name: "MenuViewController", bundle: frameworkBundle)
        
        let vc = storyBoard.instantiateInitialController() as! MenuViewController
         vc.frameSize.size = NSSize(width: 50, height: 50)
         presentViewControllerAsModalWindow(vc)
 */
		
//		vc.view.window?.setFrame(NSRect(x: 9, y: 9, width: 1000, height: 1000), display: true)
        //vc.view.backgroundFilters = .clearColor()
//        vc.modal = .OverCurrentContext
        
//        self.presentViewController(vc, animated: true, completion: nil)
        
        
        //let animator = PushAnimatorTrial()
//        let animator = MyCustomSwiftAnimator()
//        presentViewController(vc, animator: animator)
        
//        presentViewControllerAsSheet(vc)
        
        /*
        let myViewController = MenuViewController(nibName: "MenuViewController", bundle: nil)!
 */
		
		/*
		let storyBoard = NSStoryboard(name: "MenuViewController", bundle: Bundle.main)
		vc = storyBoard.instantiateInitialController() as! MenuViewController
//		vc.frameSize.size = NSSize(width: 50, height: 50)
        vc!.frameSize = frameSize
		displayContent(vc!)
//		presentViewControllerAsModalWindow(vc!)
		*/
		
		let vc = MenuViewController(nibName: "MenuViewController", bundle: nil)!
		vc.frameSize = frameSize
		view.addSubview(vc.view)
		
//		LogV("AVC Win", window)
//		vc = MenuViewController()
//        vc!.frameSize = frameSize
//        //presentViewControllerAsModalWindow(vc)
//        presentViewControllerAsSheet(vc!)
        //self.presentViewController(vc, animated: true, completion: nil)

//		insertChildViewController(vc, at: 0)
	
//	addChildViewController(vc)
//		presentViewControllerAsModalWindow(vc)
        /*
 		presentViewController(vc, asPopoverRelativeTo: view.frame,
                              of: self.view, preferredEdge: NSRectEdge.minY,
                              behavior: NSPopoverBehavior.transient)
 */
	}
	func displayContent(_ vc: NSViewController) {
		presentViewControllerAsModalWindow(vc)
//		view.addSubview(vc.view)
	}
	
	var vc : MenuViewController? = nil
	
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		if (NSObject.VERBOSE) {
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
	
	let floatingLevel = Int(CGWindowLevelForKey(CGWindowLevelKey.floatingWindow))
	let normalLevel = Int(CGWindowLevelForKey(CGWindowLevelKey.normalWindow))
	
	func stayOnTop() {
		if (self.view.window?.level == normalLevel) {
			self.view.window?.level = floatingLevel
			AppDelegate.isFloatingWindow = true
		} else {
			self.view.window?.level = normalLevel
			AppDelegate.isFloatingWindow = false
		}
//        self.view.window?.level = Int(CGWindowLevelForKey(.CGWindowLevelKey.floatingWindow))
	}
	
	override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
		let clipboardVC = segue.destinationController as! ClipboardViewController
		clipboardVC.setClipboardDelegate(self)
//		if (NSObject.VERBOSE) {
//			Swift.print("AndroidViewController, Prepare Segue!");
//		}
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
        self.initNotification()
    }
    
    internal var dirtyWindow: Bool = true
	
	func showHelpWindow() {
		if (helpWindow == nil) {
			helpWindow = HelpWindow(windowNibName: "HelpWindow")
		}
		if (self.view.window == nil) {
			if (NSObject.VERBOSE) {
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
			if (NSObject.VERBOSE) {
				Swift.print("AndroidViewController, Resp!");
			}
		}
//		}
    }
    
    internal func showCopyDialog() {
        let width = DimenUtils.getDimensionInInt(dimension: Dimens.copy_dialog_width)
        let height = DimenUtils.getDimensionInInt(dimension: Dimens.copy_dialog_height)
        let x = Int(getWindowWidth() / 2) - width / 2
        let y = Int(getWindowHeight() / 2) - height / 2
        copyDialog = CopyDialog(frame: CGRect(x: x, y: y, width: width, height: height))
        copyDialog!.setCopyDialogDelegate(delegate: self)
        copyDialog!.updateSize(x: x, y: y, width: width, height: height)
        self.view.addSubview(copyDialog!)
    }
	
	deinit {
		print("Removing Observer")
		NotificationCenter.default.removeObserver(self)
		tableDelegate.cleanup()
		transferHandler.terminate()
	}
}
