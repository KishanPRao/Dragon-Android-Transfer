//
//  AVCNotification.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension AndroidViewController {
    
    
    func initNotification() {
//        print("Adding Observer")
        NotificationCenter.default.addObserver(self, selector: #selector(copyFromAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.COPY_FROM_ANDROID), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.copyFromMac), name: NSNotification.Name(rawValue: StatusTypeNotification.COPY_FROM_MAC), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.pasteToAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.PASTE_TO_ANDROID), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.pasteToMac), name: NSNotification.Name(rawValue: StatusTypeNotification.PASTE_TO_MAC), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.copyFromAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_COPY_FILES), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.pasteToAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_PASTE_FILES), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.copyFromAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_COPY_FILES), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.stop), name: NSNotification.Name(rawValue: StatusTypeNotification.STOP), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.activeChange), name: NSNotification.Name(rawValue: StatusTypeNotification.CHANGE_ACTIVE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.checkGuide), name: NSNotification.Name(rawValue: StatusTypeNotification.FINISHED_LAUNCH), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.screenUpdated), name: NSWindow.didChangeScreenNotification, object: nil)
        
        //		Menu Item Related
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.openSelectedDirectory), name: NSNotification.Name(rawValue: StatusTypeNotification.OPEN_FILE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.backButtonPressed), name: NSNotification.Name(rawValue: StatusTypeNotification.GO_BACKWARD), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.selectAllFiles), name: NSNotification.Name(rawValue: StatusTypeNotification.SELECT_ALL), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.clearClipboard), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_CLEAR_CLIPBOARD), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.getSelectedItemInfo), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_GET_INFO), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.refresh), name: NSNotification.Name(rawValue: StatusTypeNotification.REFRESH_FILES), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.resetPosition), name: NSNotification.Name(rawValue: StatusTypeNotification.RESET_POSITION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.showHelpWindow), name: NSNotification.Name(rawValue: StatusTypeNotification.SHOW_HELP), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.showNewFolderDialog), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_NEW_FOLDER), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.deleteFileDialog), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_DELETE), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.stayOnTop), name: NSNotification.Name(rawValue: StatusTypeNotification.STAY_ON_TOP), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AndroidViewController.showProgress), name: NSNotification.Name(rawValue: AndroidViewController.NotificationStartLoading), object: nil)
        let selector = #selector(AndroidViewController.snackbarNotification(_:))
        NSObject.observeNotification(self, AndroidViewController.NotificationSnackbar, selector: selector)
    }
    
    @objc func snackbarNotification(_ notification: Notification) {
        let message = notification.userInfo?["message"] as! String
        LogV("snackbarNotification:", message)
        showSnackbar(message)
    }
}
