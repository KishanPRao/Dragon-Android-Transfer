//
//  WirelessController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 16/12/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class WirelessController: NSViewController {
    @IBOutlet weak var messageText: NSTextView!
    @IBOutlet weak var itemsView: NSCollectionView!
    @IBOutlet weak var progressView: NSProgressIndicator!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        initUi()
    }
    
    internal func initUi() {
        if let window = self.view.window {
            window.title = "Wireless"
            window.updateWindowColor()
        }
        messageText.updateMainFont(14.0)
        messageText.textColor = R.color.textColor
        
        var text = "Connect to the network your Android device has connected to."
        text = "\(text)\nOnce connected, select the Android device"
        messageText.string = text
        progressView.startAnimation(nil)
        
    }
}
