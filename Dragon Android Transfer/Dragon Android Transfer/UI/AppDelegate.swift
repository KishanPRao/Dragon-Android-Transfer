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
    override class var VERBOSE: Bool {
        return false
    }
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
    static var isFloatingWindow = false

//	var helpWindow: HelpWindow? = nil
	
	override func awakeFromNib() {
		super.awakeFromNib()
//      To bring to front
//		NSApp.activate(ignoringOtherApps: true)
		let defaults = UserDefaults.standard
		
		let defaultCopyShortcut = MASShortcut(keyCode: UInt(kVK_ANSI_C), modifierFlags: NSEventModifierFlags.command.rawValue + NSEventModifierFlags.shift.rawValue)
		let defaultCopyShortcutData = NSKeyedArchiver.archivedData(withRootObject: defaultCopyShortcut!)
		
		let defaultPasteShortcut = MASShortcut(keyCode: UInt(kVK_ANSI_V), modifierFlags: NSEventModifierFlags.command.rawValue + NSEventModifierFlags.shift.rawValue)
		let defaultPasteShortcutData = NSKeyedArchiver.archivedData(withRootObject: defaultPasteShortcut!)
		
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
		AppDelegate.active = true
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.CHANGE_ACTIVE), object: nil)
	}
	
	private func getAndroidController() -> AndroidViewController? {
		if (NSApplication.shared().mainWindow == nil) {
			Swift.print("AppDelegate, Warning, window not created yet!")
			return nil
		}
		let window = NSApplication.shared().mainWindow!
		let viewController = window.contentViewController as! ViewController
		return viewController.androidViewController
	}
	
	func applicationDidResignActive(_ notification: Notification) {
//        print("Inactive")
		AppDelegate.active = false
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.CHANGE_ACTIVE), object: nil)
	}
	
	static func isAppInForeground() -> Bool {
		return active
	}
	
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
		if (Verbose) {
			Swift.print("AppDelegate, item:", item);
		}
		return AppDelegate.validateInterfaceMenuItem(item: item)
	}
	
	public static func validateInterfaceMenuItem(item: NSValidatedUserInterfaceItem!) -> Bool {
//        LogV("Vbose", Verbose, "")
		if (VERBOSE) {
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
        if (item.tag == MenuItemIdentifier.newFolder) {
            return true
        }
        if (item.tag == MenuItemIdentifier.stayOnTop) {
            let mainMenu = NSApplication.shared().mainMenu
            let windowMenu = mainMenu?.item(at: 4)?.submenu
            for item in (windowMenu?.items)! {
                if item.tag == MenuItemIdentifier.stayOnTop {
                    if (AppDelegate.isFloatingWindow) {
                        item.state = NSOnState
                    } else {
                    	item.state = NSOffState
                    }
                }
            }
            return true
        }
//        if (item.tag == MenuItemIdentifier.editDelete && AppDelegate.itemSelected && !AppDelegate.multipleItemsSelected) {
        if (item.tag == MenuItemIdentifier.editDelete && AppDelegate.itemSelected) {
			return !AppDelegate.isPastingOperation
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
		if (Verbose) {
			Swift.print("AppDelegate, navigateBackward:", sender);
		}
	}
	
	@IBAction func openSelectedFile(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.OPEN_FILE), object: nil)
		if (Verbose) {
			Swift.print("AppDelegate, openSelectedFile:", sender);
		}
	}
	
	@IBAction func refreshFiles(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.REFRESH_FILES), object: nil)
		if (Verbose) {
			Swift.print("AppDelegate, refreshFiles:", sender);
		}
	}
	
	@IBAction func resetPosition(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.RESET_POSITION), object: nil)
		if (Verbose) {
			Swift.print("AppDelegate, resetPosition:", sender);
		}
	}
	
	
	@IBAction func showHelpWindow(_ sender: Any) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.SHOW_HELP), object: nil)
	}
    
    @IBAction func showNewFolderDialog(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.MENU_NEW_FOLDER), object: nil)
    }
    
    @IBAction func delete(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.MENU_DELETE), object: nil)
    }
	
    @IBAction func stayOnTop(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.STAY_ON_TOP), object: nil)
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

	static func reset() {
		AppDelegate.hasItems = false
		AppDelegate.canGoBackward = false
		AppDelegate.hasMacClipboardItems = false
		AppDelegate.itemSelected = false
		AppDelegate.directoryItemSelected = false
		AppDelegate.multipleItemsSelected = false
		AppDelegate.hasClipboardItems = false
	}
}

