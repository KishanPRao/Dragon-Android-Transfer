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
    var devices: [String] = []
    
    override func viewDidAppear() {
        super.viewDidAppear()
        initUi()
    }
    fileprivate func configureCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
//        let w = itemsView.visibleRect.width / 2.2
        let w: CGFloat = 150
        let h: CGFloat = 150
        flowLayout.itemSize = NSSize(width: w, height: h)
        let inset: CGFloat = 10
        flowLayout.sectionInset = NSEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        itemsView.collectionViewLayout = flowLayout
//        itemsView.enclosingScrollView?.hasVerticalScroller = true
//        view.wantsLayer = true
//        itemsView.layer?.backgroundColor = NSColor.black.cgColor
        if #available(OSX 10.13, *) {
            if let contentSize = self.itemsView.collectionViewLayout?.collectionViewContentSize {
                self.itemsView.setFrameSize(contentSize)
            }
        }
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
        configureCollectionView()
        
        devices.append("Moto G5 Plus")
        devices.append("Samsung S7")
        devices.append("One Plus 6T")
        itemsView.reloadData()
    }
}
