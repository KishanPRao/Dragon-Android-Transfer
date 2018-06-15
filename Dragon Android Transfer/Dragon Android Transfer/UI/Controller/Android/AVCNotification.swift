//
//  AVCNotification.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension AndroidViewController {
    
    func addNotification(_ selector: Selector, name notificationName: Notification.Name) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notificationName, object: nil)
    }
    
    func addNotification(_ selector: Selector, name notificationRawValue: String) {
        addNotification(selector, name: NSNotification.Name(rawValue: notificationRawValue))
    }
    
    func initNotification() {
//        print("Adding Observer")
        addNotification(#selector(copyFromAndroid), name: StatusTypeNotification.COPY_FROM_ANDROID)
        addNotification(#selector(AndroidViewController.copyFromMac), name: StatusTypeNotification.COPY_FROM_MAC)
//        addNotification(#selector(AndroidViewController.pasteToAndroid), name: StatusTypeNotification.PASTE_TO_ANDROID)
//        addNotification(#selector(AndroidViewController.pasteToMac), name: StatusTypeNotification.PASTE_TO_MAC)
//        addNotification(#selector(AndroidViewController.copyFromAndroid), name: StatusTypeNotification.MENU_COPY_FILES)
//        addNotification(#selector(AndroidViewController.pasteToAndroid), name: StatusTypeNotification.MENU_PASTE_FILES)
        addNotification(#selector(AndroidViewController.copyFromAndroid), name: StatusTypeNotification.MENU_COPY_FILES)
        addNotification(#selector(AndroidViewController.stop), name: StatusTypeNotification.STOP)
        addNotification(#selector(AndroidViewController.activeChange), name: StatusTypeNotification.CHANGE_ACTIVE)
        addNotification(#selector(AndroidViewController.checkGuide), name: StatusTypeNotification.FINISHED_LAUNCH)
        
        addNotification(#selector(AndroidViewController.quitIfNeeded), name: StatusTypeNotification.QuitIfNeeded)
        
//        Window related
        addNotification(#selector(AndroidViewController.screenUpdated), name: NSWindow.didChangeScreenNotification)
        addNotification(#selector(AndroidViewController.windowIsClosing), name: NSWindow.willCloseNotification)
        
        //		Menu Item Related
        addNotification(#selector(AndroidViewController.openSelectedDirectory), name: StatusTypeNotification.OPEN_FILE)
        addNotification(#selector(AndroidViewController.backButtonPressed), name: StatusTypeNotification.GO_BACKWARD)
        addNotification(#selector(AndroidViewController.selectAllFiles), name: StatusTypeNotification.SELECT_ALL)
        addNotification(#selector(AndroidViewController.clearClipboard), name: StatusTypeNotification.MENU_CLEAR_CLIPBOARD)
        addNotification(#selector(AndroidViewController.getSelectedItemInfo), name: StatusTypeNotification.MENU_GET_INFO)
        addNotification(#selector(AndroidViewController.refresh), name: StatusTypeNotification.REFRESH_FILES)
        addNotification(#selector(AndroidViewController.resetPosition), name: StatusTypeNotification.RESET_POSITION)
        addNotification(#selector(AndroidViewController.showHelpWindow), name: StatusTypeNotification.SHOW_HELP)
        addNotification(#selector(AndroidViewController.showNewFolderDialog), name: StatusTypeNotification.MENU_NEW_FOLDER)
        addNotification(#selector(AndroidViewController.deleteFileDialog), name: StatusTypeNotification.MENU_DELETE)
        addNotification(#selector(AndroidViewController.stayOnTop), name: StatusTypeNotification.STAY_ON_TOP)
        addNotification(#selector(AndroidViewController.showProgress), name: AndroidViewController.NotificationStartLoading)
        let selector = #selector(AndroidViewController.snackbarNotification(_:))
        NSObject.observeNotification(self, AndroidViewController.NotificationSnackbar, selector: selector)
    }
    
    @objc func snackbarNotification(_ notification: Notification) {
        let message = notification.userInfo?["message"] as! String
        LogV("snackbarNotification:", message)
        showSnackbar(message)
    }
}
