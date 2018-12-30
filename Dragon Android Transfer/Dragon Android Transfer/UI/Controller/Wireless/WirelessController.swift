//
//  WirelessController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 16/12/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift

class WirelessController: NSViewController {
    @IBOutlet weak var messageText: NSTextView!
    @IBOutlet weak var itemsView: NSCollectionView!
    @IBOutlet weak var progressView: NSProgressIndicator!
    @IBOutlet weak var connectBtn: NSButton!
    var devices: [AndroidDeviceMac] = []
    let session = Session.shared
    var disposeBag = DisposeBag()
    
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
        updateCollViewRect()
    }
    
    private func updateCollViewRect() {
        //        Ref: https://stackoverflow.com/questions/46433652/nscollectionview-does-not-scroll-items-past-initial-visible-rect
        if #available(OSX 10.13, *) {
            if let contentSize = self.itemsView.collectionViewLayout?.collectionViewContentSize {
                self.itemsView.setFrameSize(contentSize)
            }
        }
    }
    
//    func addItem(_ name: String) {
//        devices.append(name)
//        itemsView.reloadData()
//    }
    
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
        
        session.begin()
        devices.removeAll()
        
        session.discovery.observeAndroidDevices()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                devices in
                self.updateDevices(devices)
            }).disposed(by: disposeBag)
//        addItem("One Plus 6T")
//        addItem("Moto G5 Plus")
//        addItem("Samsung S7")
    }
    
    func updateDevices(_ devices: [AndroidDeviceMac]) {
//        self.devices.removeAll()
        self.devices = devices
        itemsView.reloadData()
    }
    
    @IBAction func connect(_ sender: Any) {
        guard let indexPath = itemsView.selectionIndexes.first else {
            return
        }
        guard let item = itemsView.item(at: indexPath) else {
            return
        }
        let wItem = (item as! WlessItem)
        LogI("Connect to  \(wItem)")
    }
}
