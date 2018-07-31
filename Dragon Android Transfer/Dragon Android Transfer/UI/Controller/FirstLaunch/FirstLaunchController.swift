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
        return UserDefaults.standard.bool(forKey: kFirstLaunchKey)
    }
    
    class func firstLaunchFinished() {
        UserDefaults.standard.set(true, forKey: kFirstLaunchKey)
    }
    
    @IBOutlet weak var cta: NSButton!
    @IBOutlet var messageText: NSTextView!
    
    var wc: NSWindowController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageText.string = "This application requires copying of a file into the scripts folder to enable execution.\nPlease click the button below to continue."
        cta.title = "Click to select the folder"
        print("FirstLaunchController, viewDidLoad")
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
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
        chooseFile()
    }
    
    func dialogOK(title: String, text: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
    }
    
    func showErrorDialog() {
        self.dialogOK(title: "Something went wrong", text: "Please select the right directory.")
    }
    
    func chooseFile() {
        let openPanel = NSOpenPanel();
        openPanel.title = "Select the folder to copy the script"
        openPanel.message = "The `adb` executable will be copied into the scripts folder."
        openPanel.showsResizeIndicator = true
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.allowsMultipleSelection = false
        openPanel.directoryURL = AdbScript.directory
        
        openPanel.beginSheetModal(for: self.view.window!) { (result) in
            if (result.rawValue == NSFileHandlingPanelOKButton) {
                if let url = openPanel.url, url.absoluteString == AdbScript.directory.absoluteString,
                    let fileUrl = URL(string: url.absoluteString + "/adb") {
                    //                    print("Got url, \(self.adbFile) => \(fileUrl)")
                    do {
                        try FileManager.default.copyItem(at: self.adbFile, to: fileUrl)
                        print("Copied!")
                        self.finish()
                    } catch {
                        print(error.localizedDescription)
                    }
                } else {
                    print("Something went wrong, please select right directory!")
                    self.showErrorDialog()
                }
            }
        }
    }
}
