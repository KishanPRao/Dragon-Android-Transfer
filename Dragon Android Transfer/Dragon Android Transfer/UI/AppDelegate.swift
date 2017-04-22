//
//  AppDelegate.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/16.
//  Copyright © 2016 Kishan P Rao. All rights reserved.
//

import Cocoa
import MASShortcut
import AppKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserInterfaceValidations {
	private static let VERBOSE = true;
	static let MASShortcutCopy = "copyShortcut"
	static let MASShortcutPaste = "pasteShortcut"
	@IBOutlet weak var shortcutView: MASShortcutView?
//    static let MASObservingContext = &MASObservingContext;
//	@IBOutlet weak var window: NSWindow!

//    var viewController: ViewController!
	
	static var active = false;
	static var itemSelected = false
	static var directoryItemSelected = false
	static var multipleItemsSelected = false
	static var hasItems = false
	static var hasMacClipboardItems = false
	static var canGoBackward = false
	static var hasClipboardItems = false
	static var isPastingOperation = false

//	var helpWindow: HelpWindow? = nil
	
	override func awakeFromNib() {
		super.awakeFromNib()
//      To bring to front
//		NSApp.activate(ignoringOtherApps: true)
		let defaults = UserDefaults.standard
		
		let defaultCopyShortcut = MASShortcut(keyCode: UInt(kVK_ANSI_C), modifierFlags: NSEventModifierFlags.command.rawValue + NSEventModifierFlags.shift.rawValue)
		let defaultCopyShortcutData = NSKeyedArchiver.archivedData(withRootObject: defaultCopyShortcut)
		
		let defaultPasteShortcut = MASShortcut(keyCode: UInt(kVK_ANSI_V), modifierFlags: NSEventModifierFlags.command.rawValue + NSEventModifierFlags.shift.rawValue)
		let defaultPasteShortcutData = NSKeyedArchiver.archivedData(withRootObject: defaultPasteShortcut)
		
		defaults.register(defaults: [
				AppDelegate.MASShortcutCopy: defaultCopyShortcutData,
				AppDelegate.MASShortcutPaste: defaultPasteShortcutData
		])
		
		MASShortcutBinder.shared().bindShortcut(withDefaultsKey: AppDelegate.MASShortcutCopy) {
			print("Copy, Foreground:", AppDelegate.isAppInForeground())
			
			if (self.isInvalidOperation()) {
				return
			}
			
			if (AppDelegate.isAppInForeground()) {
				NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.COPY_FROM_ANDROID), object: nil)
			} else {
				NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.COPY_FROM_MAC), object: nil)
			}
		}
		
		MASShortcutBinder.shared().bindShortcut(withDefaultsKey: AppDelegate.MASShortcutPaste) {
			print("Paste, Foreground:", AppDelegate.isAppInForeground())
			
			if (self.isInvalidOperation()) {
				return
			}
			if (AppDelegate.isAppInForeground()) {
				NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.PASTE_TO_ANDROID), object: nil)
			} else {
				NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.PASTE_TO_MAC), object: nil)
			}
			
		}
		NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.screenUpdated), name: NSNotification.Name.NSWindowDidChangeScreen, object: nil)
	}
	
	func isInvalidOperation() -> Bool {
		let invalid = AppDelegate.isPastingOperation
		if (invalid) {
			NSSound.init(named: "Funk")!.play()
			NSApp.requestUserAttention(NSRequestUserAttentionType.informationalRequest)
		}
		return invalid
	}
	
	func screenUpdated() {
//		if (helpWindow != nil) {
//			helpWindow!.updateSizes()
//		}
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
//        print("Active")
		AppDelegate.active = true
//        viewController = self.window.rootViewController
//        let window = NSApplication.sharedApplication().mainWindow
//        print("Window:", window)
//        if (window != nil) {
//        print("Window:", window!.contentViewController)
//
//        viewController = window!.contentViewController as! ViewController;
//        }
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.CHANGE_ACTIVE), object: nil)
//		let androidViewController = getAndroidController()
//		if (androidViewController != nil && androidViewController!.shouldShowGuide()) {
//			showHelpWindow([])
//		}
	}
	
	private func getAndroidController() -> AndroidViewController? {
		if (NSApplication.shared().mainWindow == nil) {
			Swift.print("AppDelegate, Warning, window not created yet!")
			return nil
		}
		let window = NSApplication.shared().mainWindow!
		let viewController = window.contentViewController as! ViewController
		return viewController.androidViewController
//        Swift.print("Subs:", viewController.view.subviews[0])
//		return viewController.view.subviews[0] as! AndroidViewController
	}
	
	func applicationDidResignActive(_ notification: Notification) {
//        print("Inactive")
		AppDelegate.active = false
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.CHANGE_ACTIVE), object: nil)
	}
	
	static func isAppInForeground() -> Bool {
		return active
//        let state = NSApplication.sharedApplication().occlusionState
//        if (state == NSApplicationOcclusionState.Visible) {
//            return true;
//        } else {
//            return false;
//        }

//        if state == .Background {
//            return false;
//        }
//        else if state == .Active {
//            return true;
//        }
	}

//    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
//        if (context != MASObservingContext) {
//            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
//            return;
//        }
//    }
	
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		if (AppDelegate.VERBOSE) {
			Swift.print("AppDelegate, item:", item);
		}
		return AppDelegate.validateInterfaceMenuItem(item: item)
	}
	
	public static func validateInterfaceMenuItem(item: NSValidatedUserInterfaceItem!) -> Bool {
		if (AppDelegate.VERBOSE) {
			Swift.print("AppDelegate, validateInterfaceMenuItem:", item.tag);
			Swift.print("AppDelegate, validateInterfaceMenuItem, isPasting:", AppDelegate.isPastingOperation);
		}
		if (item.tag == MenuItemIdentifier.fileOpenFile && AppDelegate.directoryItemSelected && !AppDelegate.multipleItemsSelected) {
			return !AppDelegate.isPastingOperation
		}
		if (item.tag == MenuItemIdentifier.getInfo && AppDelegate.itemSelected && !AppDelegate.multipleItemsSelected) {
			return !AppDelegate.isPastingOperation
		}
		if (item.tag == MenuItemIdentifier.editCopy && AppDelegate.itemSelected) {
			return !AppDelegate.isPastingOperation
		}
		if (item.tag == MenuItemIdentifier.editPaste && AppDelegate.hasMacClipboardItems) {
			return !AppDelegate.isPastingOperation
		}
		if (item.tag == MenuItemIdentifier.editSelectAll && AppDelegate.hasItems) {
			return !AppDelegate.isPastingOperation
		}
		if (item.tag == MenuItemIdentifier.goBackward && AppDelegate.canGoBackward) {
			return !AppDelegate.isPastingOperation
		}
		if (item.tag == MenuItemIdentifier.clearClipboard && AppDelegate.hasClipboardItems) {
			return !AppDelegate.isPastingOperation
		}
		if (item.tag == MenuItemIdentifier.help) {
			return true
		}
		if (item.tag == MenuItemIdentifier.minimize) {
			return true
		}
		if (item.tag == MenuItemIdentifier.refresh) {
			return true
		}
		if (item.tag == MenuItemIdentifier.resetPosition) {
			return true
		}
		return false
	}
	
	@IBAction func getInfo(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.MENU_GET_INFO), object: nil)
	}
	
	@IBAction func clearClipboard(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.MENU_CLEAR_CLIPBOARD), object: nil)
	}
	
	@IBAction func pasteFiles(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.MENU_PASTE_FILES), object: nil)
	}
	
	@IBAction func copyFiles(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.MENU_COPY_FILES), object: nil)
	}
	
    @IBAction func selectAll(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.SELECT_ALL), object: nil)
    }
	
	@IBAction func navigateBackward(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.GO_BACKWARD), object: nil)
		if (AppDelegate.VERBOSE) {
			Swift.print("AppDelegate, navigateBackward:", sender);
		}
	}
	
	@IBAction func openSelectedFile(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.OPEN_FILE), object: nil)
		if (AppDelegate.VERBOSE) {
			Swift.print("AppDelegate, openSelectedFile:", sender);
		}
	}
	
	@IBAction func refreshFiles(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.REFRESH_FILES), object: nil)
		if (AppDelegate.VERBOSE) {
			Swift.print("AppDelegate, refreshFiles:", sender);
		}
	}
	
	@IBAction func resetPosition(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.RESET_POSITION), object: nil)
		if (AppDelegate.VERBOSE) {
			Swift.print("AppDelegate, resetPosition:", sender);
		}
	}
	
	
	@IBAction func showHelpWindow(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.SHOW_HELP), object: nil)
//		if (helpWindow == nil) {
//			helpWindow = HelpWindow(windowNibName: "HelpWindow")
//		}
//		let window = NSApplication.shared().mainWindow!
//		let androidViewController = getAndroidController()
//		if (androidViewController != nil) {
//			helpWindow!.setIsIntro(intro: androidViewController!.shouldShowGuide())
//			window.beginSheet(helpWindow!.window!) { response in
//				if (AppDelegate.VERBOSE) {
//					Swift.print("AppDelegate, Resp!");
//				}
//			}
//		}
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
//		Insert code here to initialize your application
//        let window = NSApplication.sharedApplication().mainWindow
//        window?.backgroundColor = NSColor.blackColor()
//        window?.appearance = NSAppearance.init(named: NSAppearanceNameVibrantDark)


//        self.window.appearance = NSAppearance.init(named: NSAppearanceNameVibrantDark)
//		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.FINISHED_LAUNCH), object: nil)
	}
	
	public func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
	
	func applicationWillTerminate(_ aNotification: Notification) {
// 		Insert code here to tear down your application
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.STOP), object: nil)
		NotificationCenter.default.removeObserver(self)
	}
}

