//
//  FirstLaunchController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/07/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa

class AdbScript {
    static let directory = FileManager.default.urls(for: .applicationScriptsDirectory, in: .userDomainMask).first!
    static let url = directory.appendingPathComponent("adb")
}

class FirstLaunchController: NSViewController {
//    Theme first launch later.
    static let kFirstLaunchKey = "FirstLaunchFinished"
    
    class func isFirstLaunchFinished() -> Bool {
        //        TODO: Also check if file exists! Do not allow to go further unless setup done.
        return UserDefaults.standard.bool(forKey: kFirstLaunchKey)
    }
    
    class func firstLaunchFinished() {
        UserDefaults.standard.set(true, forKey: kFirstLaunchKey)
    }
    
    @IBOutlet weak var cta: NSButton!
    @IBOutlet var messageText: NSTextField!
    
    var wc: NSWindowController? = nil
    
    private func initUi() {
        if let window = self.view.window {
            window.updateWindowColor()
        }
        messageText.stringValue = R.string.firstLaunchMessage
        messageText.textColor = R.color.firstLaunchText
        messageText.alignment = .center
        messageText.font = NSFont(name: R.font.mainFont,
                                  size: messageText.font?.pointSize ?? NSFont.systemFontSize)
        
//        cta.setText(text: R.string.firstLaunchCta,
//                    textColor: R.color.transferTextColor,
//                    alignment: .center,
//                    bgColor: R.color.transferBg,
//                    isSelected: false,
//                    rounded: true)
        
        cta.setText(text: R.string.firstLaunchCta,
                    textColor: R.color.firstLaunchCtaText,
                    alignment: .center,
                    bgColor: R.color.firstLaunchCtaBg,
                    isSelected: false,
                    rounded: true)
        cta.focusRingType = .none
        
        view.setBackground(R.color.firstLaunchBg)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("FirstLaunchController, viewDidLoad")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        initUi()
        print("FirstLaunchController, viewDidAppear")
    }
    
    var adbFile = Bundle.main.resourceURL!.appendingPathComponent("adb.bundle/adb")
    
    func finish() {
        FirstLaunchController.firstLaunchFinished()
        wc = NSViewController.loadFromStoryboard(name: "Main")
        wc?.showWindow(self)
        self.view.window?.close()
    }
    
    @IBAction func clicked(_ sender: Any) {
        buildAdb()
    }
    
    func dialogOK(title: String, text: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    func showErrorDialog() {
        self.dialogOK(title: "Something went wrong", text: "Please select the correct directory.")
    }
    
    func buildAdb() {
        let savePanel = NSSavePanel()
        savePanel.directoryURL = AdbScript.directory
        
        savePanel.title = "Select the folder to copy the script"
        savePanel.message = "The `adb` executable will be copied into the scripts folder."
        savePanel.nameFieldStringValue = "adb"
        savePanel.showsHiddenFiles = false
        savePanel.showsTagField = false
        savePanel.canCreateDirectories = false
        savePanel.allowsOtherFileTypes = false
        savePanel.isExtensionHidden = false
        
        if savePanel.runModal().rawValue == NSFileHandlingPanelOKButton {
            if let url = savePanel.url,
                url.absoluteString == AdbScript.url.absoluteString,
                let data = NSDataAsset.init(name: NSDataAsset.Name(rawValue: "adb"))?.data {
                print("Path: \(url.path)")
                print("Adb: \(adbFile.path)")
                
                let filePath = AdbScript.url.path
                let created = FileManager.default.createFile(atPath: filePath, contents: data, attributes: nil)
                print("Dir: \(filePath), created: \(created)")
                
                if (created) {
                    let fm = FileManager.default
                    
                    var attributes = [FileAttributeKey : Any]()
                    attributes[.posixPermissions] = 0o777
                    do {
                        try fm.setAttributes(attributes, ofItemAtPath: filePath)
                        finish()
                    } catch let error {
                        print("Permissions error: ", error)
                        showErrorDialog()
                    }
                } else {
                    print("Adb file not created")
                    showErrorDialog()
                }
            } else {
                print("Couldn't copy")
                showErrorDialog()
            }
        } else {
            print("Canceled")
        }
    }
}
