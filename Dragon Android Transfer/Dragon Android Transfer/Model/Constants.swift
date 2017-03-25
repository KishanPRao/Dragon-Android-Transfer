//
//  Constants.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 01/02/17.
//  Copyright © 2017 Untitled-TBA. All rights reserved.
//

import Foundation

public enum TransferType {
    static let AndroidToMac = 0
    static let MacToAndroid = 1
}

public enum StatusTypeNotification {
	static let COPY_FROM_ANDROID = "COPY_FROM_ANDROID"
	static let COPY_FROM_MAC = "COPY_FROM_MAC"
	static let PASTE_TO_ANDROID = "PASTE_TO_ANDROID"
	static let PASTE_TO_MAC = "PASTE_TO_MAC"
	static let STOP = "STOP"
	static let CHANGE_ACTIVE = "CHANGE_ACTIVE"
	
//	Menu Item Related
	static let OPEN_FILE = "OPEN_FILE"
	static let GO_BACKWARD = "GO_BACKWARD"
	static let MENU_COPY_FILES = "MENU_COPY_FILES"
	static let MENU_PASTE_FILES = "MENU_PASTE_FILES"
	static let MENU_CLEAR_CLIPBOARD = "MENU_CLEAR_CLIPBOARD"
	static let MENU_GET_INFO = "MENU_GET_INFO"
}

public enum ViewControllerIdentifier {
	static let ClipboardId = "Clipboard"
}

public enum MenuItemIdentifier {
	static let fileOpenFile = 0
	static let editCopy = 1
	static let editPaste = 2
	static let editSelectAll = 3
	static let goBackward = 4
	static let clearClipboard = 5
	static let getInfo = 6
	static let help = 7
}