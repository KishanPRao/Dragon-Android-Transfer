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
		NSControlTextEditingDelegate,
//		FileProgressDelegate,
		ClipboardDelegate, CopyDialogDelegate,
		DragNotificationDelegate, DragUiDelegate,
		NSUserInterfaceValidations {
	public static let NotificationStartLoading = "NotificationStartLoading"
    public static let NotificationSnackbar = "NotificationSnackbar"
    
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
	

    @IBOutlet weak var menuButton: NSButton!
    @IBOutlet weak var backButton: NSButton!
	
	@IBOutlet weak var toolbarView: NSView!
	
	@IBOutlet weak var messageText: NSTextField!
	
	internal var copyDialog = nil as CopyDialog?
	
    @IBOutlet weak var pathSelector: PathSelector!
    @IBOutlet weak var pathSelectorRootView: NSView!
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
    //internal var mCircularProgress: IndeterminateProgressView? = nil
    internal var mCurrentProgress = -1.0
	
    @IBOutlet weak var loadingProgress: IndeterminateProgress!
    
    @IBOutlet weak var overlayView: OverlayView!
    
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
		
		observeListing()
		observeTransfer()
    }
	
	func updateDeviceStatus() {
		if (!transferHandler.hasActiveDevice()) {
			AppDelegate.reset()
			
			messageText.isHidden = false
//            let fontName = "AlegreyaSans"
//            //let fontName = "AlegreyaSans"
//            var font = NSFont(name: fontName, size: 5.0)
//            font = NSFont(name: "AlegreyaSans.ttf", size: 5.0)
//            messageText.font = font
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
		let canGoBackward = !transferHandler.isRootDirectory()
        AppDelegate.canGoBackward = canGoBackward
        backButton.isEnabled = canGoBackward
	}
    
    internal func reset() {
        print("Reset!")
        transferHandler.reset()
        androidDirectoryItems = []
    }
	
	internal var previousIndex = -1
	
    /*
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
	}*/
	
	override func viewWillAppear() {
		super.viewWillAppear()
//        start()
		if (fileTable.acceptsFirstResponder) {
			self.view.window?.makeFirstResponder(fileTable)
		}
		NotificationCenter.default.addObserver(self, selector: #selector(windowMoved), name: NSNotification.Name.NSWindowDidMove, object: self.view.window!)
        
        /*updateWindowSize()
		checkGuide()
 		*/
	}
	
	override func viewWillLayout() {
		super.viewWillLayout()
		//Swift.print("AndroidViewController, viewWillLayout")
		
        /*updateWindowSize()
         checkGuide()
         */
	}
	
	override func viewDidLayout() {
		super.viewDidLayout()
		
        /*updateWindowSize()
         checkGuide()
         */
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
	
	var snackbar: Snackbar? = nil
    
    internal func showSnackbar(_ message: String) {
        if (snackbar == nil) {
            snackbar = Snackbar(frame: NSRect(x: 0, y: 0, width: self.view.frame.width, height: 50))
            self.view.addSubview(snackbar!)
            self.view.layoutSubtreeIfNeeded()
        }
//        LogV("showSnackbar: \(message)")
        snackbar?.updateMessage(message)
        snackbar?.showSnackbar()
    }
	
	@IBAction func backButtonPressed(_ button: NSButton) {
        navigateUpDirectory()
//        startTransfer()
	}

//    var timer: NSTimer? = nil
	
	func windowMoved() {
		//LogV("Win Moved", view.window?.frame)
		/*if let window = vc?.view.window {
			var frame = window.frame
			frame.origin = view.window!.frame.origin
//			window.setFrame(frame, display: false)
//			vc?.update(frame)
			window.setFrameOrigin(frame.origin)
		}*/
	}
    
    var transferVc: TransferViewController? = nil
    
    func startTransfer() {
        let window = self.view.window!
        var frameSize = window.frame
        frameSize.size = NSSize(width: window.frame.width, height: frameSize.height - window.titlebarHeight)
        
        let storyBoard = NSStoryboard(name: "TransferViewController", bundle: Bundle.main)
        transferVc = storyBoard.instantiateInitialController() as! TransferViewController
        if let transferVc = transferVc {
//            transferVc.frameSize = frameSize
            addChildViewController(transferVc)
            view.addSubview(transferVc.view)
        }
    }
    
    var vc: MenuViewController? = nil
    
    @IBAction func menuTapped(_ sender: Any) {
        if (vc != nil && vc!.isOpen) {
            vc?.closeMenu(self)
            return
        }
        let window = self.view.window!
        var frameSize = window.frame
        frameSize.size = NSSize(width: window.frame.width, height: frameSize.height - window.titlebarHeight)
        
        let storyBoard = NSStoryboard(name: "MenuViewController", bundle: Bundle.main)
        vc = storyBoard.instantiateInitialController() as! MenuViewController
        if let vc = vc {
        	vc.frameSize = frameSize
        	addChildViewController(vc)
        	view.addSubview(vc.view)
        }
    }
	
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
