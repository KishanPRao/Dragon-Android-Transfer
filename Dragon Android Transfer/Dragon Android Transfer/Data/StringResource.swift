//
// Created by Kishan P Rao on 12/03/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

public struct StringResource {
	public static let ESCAPE_DOUBLE_QUOTES = "\""
	public static let SINGLE_QUOTES = "'"
	
	public static let GNU_TYPE = "GNU"
	public static let BSD_TYPE = "BSD"
	public static let SOLARIS_TYPE = "SOLARIS"

//	static let helpString =
//			"Guide:\n" +
//					"\n" +
//					"Mac to Android:\n" +
//					"To copy file(s) from your Mac, select the file(s) in Finder, focus on Finder,\n" +
//					"Press [Command + Shift + C].\n" +
//					"The item(s) will be added to the clipboard.\n" +
//					"\n" +
//					"To paste to your device, focus on the application,\n" +
//					"Press [Command + Shift + V] or click [Edit -> Paste].\n" +
//					"\n" +
//					"Android to Mac:\n" +
//					"To copy file(s) from your device, select the file(s) in the application, focus on the application,\n" +
//					"Press [Command + Shift + C] or click [Edit -> Copy].\n" +
//					"The item(s) will be added to the clipboard.\n" +
//					"\n" +
//					"To paste to your Mac, focus on Finder,\n" +
//					"Press [Command + Shift + V].\n" +
//					"\n" +
//					"\n" +
//					"Disappointments:\n" +
//					"\n" +
//					"Files cannot be copied across android devices. And files cannot be copied across the same android device. Only between Mac & an Android device.\n" +
//					"\n" +
//					"\n" +
//					"Expectations:\n" +
//					"\n" +
//					"1. Drag and drop to copy/paste files.\n" +
//					"2. More file operations (delete, create new folder, etc).\n" +
//					"3. More control on display (like sorting).\n" +
//					"And many more!" +
//					"\n" +
//					"\n" +
//					"Feedback:\n" +
//					"\n" +
//					"Do share your feedback to this mail:\n" +
//					"support.draconian@gmail.com"
    
    let textViewPlaceHolder = "Updating.."
    let timeRemainingPlaceHolder = "Calculating time remaining..."
    
    //    Help:
    let helpBack = "Go Back"
    let helpMenu = "Open Menu"
    
    let helpDevicesPopup = "Change active device"
    let helpCloseMenu = "Close Menu"
    
    let ok = "OK"
    let cancel = "Cancel"
    
    //    TODO: Move other links out.
    let hostUrl = "https://kishanprao.herokuapp.com"
    
//    let noActiveDevice = "No Active Device.\nPlease connect a device with USB Debugging enabled."
    let noActiveDevice = "No Active Device.\nFor instructions, go to `Help -> Dragon Android Transfer Help`"
    
//    First Launch
//    let firstLaunchMessage = "This application requires copying of a file into the scripts folder to enable execution.\nPlease click the button below to continue."
    let firstLaunchMessage =
        "The application needs a specific file to run on your system.\n" +
    "Please click on the button below and follow the steps to copy the file."
    let firstLaunchCta = "Continue"
}
