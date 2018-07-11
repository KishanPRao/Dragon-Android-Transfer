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
import RxSwift

@NSApplicationMain
class AppDelegate: VerboseObject, NSApplicationDelegate, NSUserInterfaceValidations, 
		NSUserNotificationCenterDelegate {
//    override class var VERBOSE: Bool {
//        return false
//    }
	static let MASShortcutCopy = "copyShortcut"
	static let MASShortcutPaste = "pasteShortcut"
    
    static let DarkThemeKey = "DarkTheme"
    
	@IBOutlet weak var shortcutView: MASShortcutView?
//    static let MASObservingContext = &MASObservingContext;
//	@IBOutlet weak var window: NSWindow!

//    var viewController: ViewController!
	
    @IBOutlet weak var darkThemeMenuItem: NSMenuItem!
    @IBOutlet weak var lightThemeMenuItem: NSMenuItem!
    
    static var active = false;
    static var activeDevice = false;
	static var itemSelected = false
    static var directoryItemSelected: Bool = false /*{
        didSet {
            Swift.print("Here: \(directoryItemSelected)")
        }
    }*/
	static var multipleItemsSelected = false
	static var hasItems = false
	static var hasMacClipboardItems = false
	static var canGoBackward = false
    static var hasClipboardItems = Variable<Bool>(false)
    static var isPastingOperation = Variable<Bool>(false)
    static var isFloatingWindow = false

//	var helpWindow: HelpWindow? = nil
	
	override func awakeFromNib() {
		super.awakeFromNib()
//      To bring to front
//		NSApp.activate(ignoringOtherApps: true)
		let defaults = UserDefaults.standard
		
		let defaultCopyShortcut = MASShortcut(keyCode: UInt(kVK_ANSI_C), modifierFlags: NSEvent.ModifierFlags.command.rawValue + NSEvent.ModifierFlags.shift.rawValue)
		let defaultCopyShortcutData = NSKeyedArchiver.archivedData(withRootObject: defaultCopyShortcut!)
		
		let defaultPasteShortcut = MASShortcut(keyCode: UInt(kVK_ANSI_V), modifierFlags: NSEvent.ModifierFlags.command.rawValue + NSEvent.ModifierFlags.shift.rawValue)
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
				NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.COPY_FROM_ANDROID),
                                                object: nil)
			} else {
				NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.COPY_FROM_MAC),
                                                object: nil)
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
		NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.screenUpdated), name: NSWindow.didChangeScreenNotification, object: nil)
		
        var darkTheme = true
        if (UserDefaults.standard.object(forKey: AppDelegate.DarkThemeKey) == nil) {
            UserDefaults.standard.set(darkTheme, forKey: AppDelegate.DarkThemeKey)
        } else {
            darkTheme = UserDefaults.standard.bool(forKey: AppDelegate.DarkThemeKey)
        }
        
        if (darkTheme) {
            R.setDarkTheme()
        } else {
            R.setLightTheme()
        }
	}
	
	func userNotificationCenter(center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
		return true
	}
	
	static func showNotification(title: String, message: String) {
		var notification = NSUserNotification()
		notification.title = title
		notification.informativeText = message
        notification.soundName = NSUserNotificationDefaultSoundName
//        notification.soundName = R.audio.endCopy
		NSUserNotificationCenter.default.deliver(notification)
		
		NSApp.requestUserAttention(NSApplication.RequestUserAttentionType.informationalRequest)
	}
	
	func isInvalidOperation() -> Bool {
		let invalid = AppDelegate.isPastingOperation.value
		if (invalid) {
			NSSound.init(named: NSSound.Name(rawValue: R.audio.badOperation))?.play()
			NSApp.requestUserAttention(NSApplication.RequestUserAttentionType.informationalRequest)
		}
		return invalid
	}
	
	@objc func screenUpdated() {
//		if (helpWindow != nil) {
//			helpWindow!.updateSizes()
//		}
	}
	
	func applicationDidBecomeActive(_ notification: Notification) {
		AppDelegate.active = true
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.CHANGE_ACTIVE), object: nil)
	}
	
	/*
	private func getAndroidController() -> AndroidViewController? {
		if (NSApplication.shared().mainWindow == nil) {
			Swift.print("AppDelegate, Warning, window not created yet!")
			return nil
		}
		let window = NSApplication.shared().mainWindow!
		let viewController = window.contentViewController as! ViewController
		return viewController.androidViewController
	}
	*/
	
	func applicationDidResignActive(_ notification: Notification) {
//        print("Inactive")
		AppDelegate.active = false
		NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.CHANGE_ACTIVE), object: nil)
	}
	
	static func isAppInForeground() -> Bool {
		return active
	}
	
	func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
//        if (Verbose) {
//            Swift.print("AppDelegate, item:", item);
//        }
		return AppDelegate.validateInterfaceMenuItem(item: item)
	}
    
    static func updateThemeItem(_ darkThemeItem: Bool) {
        let darkTheme = UserDefaults.standard.bool(forKey: AppDelegate.DarkThemeKey)
        let mainMenu = NSApplication.shared.mainMenu
        let windowMenu = mainMenu?.item(at: 3)?.submenu
        let tag = darkThemeItem ? MenuItemIdentifier.darkTheme : MenuItemIdentifier.lightTheme
        for menuItem in (windowMenu?.items)! {
            if let submenu = menuItem.submenu {
                for item in submenu.items {
                    if item.tag == tag {
                        if ((darkTheme && darkThemeItem) || (!darkTheme && !darkThemeItem)) {
                            item.state = .on
                        } else {
                            item.state = .off
                        }
                    }
                }
            }
        }
    }
	
	static func validateInterfaceMenuItem(item: NSValidatedUserInterfaceItem!) -> Bool {
        print("validateInterfaceMenuItem: \(item.tag)")
		if (VERBOSE) {
//            Swift.print("AppDelegate, validateInterfaceMenuItem:", item.tag);
//            Swift.print("AppDelegate, validateInterfaceMenuItem, isPasting:", AppDelegate.isPastingOperation.value)
//            Swift.print("AppDelegate: \(AppDelegate.directoryItemSelected), \(AppDelegate.multipleItemsSelected), \(MenuItemIdentifier.fileOpenFile)")
		}
		if (item.tag == MenuItemIdentifier.fileOpenFile && AppDelegate.directoryItemSelected && !AppDelegate.multipleItemsSelected) {
			return !AppDelegate.isPastingOperation.value
		}
		if (item.tag == MenuItemIdentifier.getInfo && AppDelegate.itemSelected && !AppDelegate.multipleItemsSelected) {
			return !AppDelegate.isPastingOperation.value
		}
		if (item.tag == MenuItemIdentifier.editCopy && AppDelegate.itemSelected) {
			return !AppDelegate.isPastingOperation.value
		}
		if (item.tag == MenuItemIdentifier.editPaste && AppDelegate.hasMacClipboardItems) {
			return !AppDelegate.isPastingOperation.value
		}
		if (item.tag == MenuItemIdentifier.editSelectAll && AppDelegate.hasItems) {
			return !AppDelegate.isPastingOperation.value
		}
		if (item.tag == MenuItemIdentifier.goBackward && AppDelegate.canGoBackward) {
			return !AppDelegate.isPastingOperation.value
		}
		if (item.tag == MenuItemIdentifier.clearClipboard && AppDelegate.hasClipboardItems.value) {
			return !AppDelegate.isPastingOperation.value
		}
        if (item.tag == MenuItemIdentifier.refresh || item.tag == MenuItemIdentifier.newFolder) {
            return AppDelegate.activeDevice && !AppDelegate.isPastingOperation.value
        }
		if (item.tag == MenuItemIdentifier.help) {
			return true
		}
		if (item.tag == MenuItemIdentifier.minimize) {
			return true
		}
		if (item.tag == MenuItemIdentifier.resetPosition) {
			return true
        }
        if (item.tag == MenuItemIdentifier.defaultAlwaysOn) {
            return true
        }
        if (item.tag == MenuItemIdentifier.darkTheme) {
            updateThemeItem(true)
            return true
        }
        if (item.tag == MenuItemIdentifier.lightTheme) {
            updateThemeItem(false)
            return true
        }
        if (item.tag == MenuItemIdentifier.stayOnTop) {
            let mainMenu = NSApplication.shared.mainMenu
            let windowMenu = mainMenu?.item(at: 5)?.submenu
            for item in (windowMenu?.items)! {
                if item.tag == MenuItemIdentifier.stayOnTop {
                    if (AppDelegate.isFloatingWindow) {
                        item.state = .on
                    } else {
                    	item.state = .off
                    }
                }
            }
            return true
        }
//        if (item.tag == MenuItemIdentifier.editDelete && AppDelegate.itemSelected && !AppDelegate.multipleItemsSelected) {
        if (item.tag == MenuItemIdentifier.editDelete && AppDelegate.itemSelected) {
			return !AppDelegate.isPastingOperation.value
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
    
    @IBAction func changeTheme(_ sender: Any) {
        LogV("Change theme: \(sender)")
        if let menuItem = sender as? NSMenuItem {
            if (menuItem.state == .on) {
                return
            }
            var darkTheme = false
            if (menuItem.tag == MenuItemIdentifier.darkTheme) {
                darkTheme = true
            }
            
            let alertProps = AlertProperty()
            alertProps.message = "The application will be restarted."
            alertProps.info = "Are you sure you want to change the theme?"
            alertProps.textColor = R.color.dialogTextColor
            let buttonProp = AlertButtonProperty(title: R.string.ok)
            buttonProp.isSelected = true
//            buttonProp.bgColor = R.color.dialogSelectionColor
            alertProps.addButton(button: buttonProp)
            alertProps.addButton(button: AlertButtonProperty(title: R.string.cancel))
            alertProps.style = .informational
            
            if DarkAlertUtils.showAlert(property: alertProps) {
                UserDefaults.standard.set(darkTheme, forKey: AppDelegate.DarkThemeKey)
                NSApp.relaunch()
            }
            
            LogV("Change to dark theme: \(darkTheme)")
        }
    }
    
    
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		NSUserNotificationCenter.default.delegate = self
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
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        NotificationCenter.default.post(name: Notification.Name(rawValue: StatusTypeNotification.QuitIfNeeded),
                                        object: nil)
        return NSApplication.TerminateReply.terminateLater
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
		AppDelegate.hasClipboardItems.value = false
	}
}

