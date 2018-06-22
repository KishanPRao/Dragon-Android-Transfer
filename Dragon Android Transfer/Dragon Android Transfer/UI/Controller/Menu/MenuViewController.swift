//
//  MenuViewController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

import RxSwift

class MenuViewController: NSViewController,
NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var overlayView: ClickableView!
    @IBOutlet weak var navigationParent: NSView!
    @IBOutlet weak var back: NSButton!
    @IBOutlet weak var popup: NSPopUpButtonCell!
    @IBOutlet weak var table: NonDeselectTableView!
    @IBOutlet weak var tableOuter: NSScrollView!
    
    @IBOutlet weak var refresh: NSButton!
    @IBOutlet weak var testPopup: NSPopUpButton!
    internal let transferHandler = TransferHandler.sharedInstance
    internal let bgScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    var disposeBag = DisposeBag()
    
    public var frameSize = NSRect()
    internal var storages = [StorageItem]()
    
    var androidDevices = [AndroidDeviceMac]()
    
    @IBOutlet weak var statusView: MenuStatusView!
    
    internal var selectedStorageIndex = -1
    
    let rowHeight = 45.0 as CGFloat
    
    var isOpen = true
    
    @IBAction func closeMenu(_ sender: Any) {
        //        print("Close Menu")
        if (!isOpen) {
            return
        }
        isOpen = false
        animate(open: false) {
            //            print("Close end")
            self.refreshStorageSelection()
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        //        print("Menu, view!")
        initSizes()
        
        isOpen = true
        animate(open: true) {
            //            print("Opened")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUi()
        observe()
    }
    
    private func initUi() {
        //self.view.wantsLayer = true
        //self.view.layer?.backgroundColor = R.color.menuBgColor.cgColor
        //self.view.layerContentsRedrawPolicy = NSViewLayerContentsRedrawPolicy.onSetNeedsDisplay
        
        self.testPopup.toolTip = R.string.helpDevicesPopup
        
        //        self.back.toolTip = R.string.helpCloseMenu
        
        initUiContent()
        /*overlayView.setOnClickListener() {
         self.closeMenu(nil)
         }*/
        //        popup.font = NSFont(name: R.font.mainFont, size: popup.font?.pointSize ?? 10.0)
        
        overlayView.setOnClickListener() {
            //            print("Done")
            self.closeMenu(self)
        }
    }
    
    var activeDevice: AndroidDeviceMac? = nil
    
    internal func reset() {
        self.popup.isEnabled = false
        self.statusView.resetNoDevice()
        updateStorageItems([])
    }
    
    internal func reload() {
        if let device = activeDevice {
            self.updateStorageItems(device.storages)
            openInTable(selectedStorageIndex, external: false)
        }
    }
    
    @objc func onPopupSelected(_ sender: Any) {
        let index = self.popup.indexOfSelectedItem
        LogI("Popup Selected", index)
        guard let device = androidDevices[safe: index] else {
            return
        }
        //        updateStorageItems([])
        let activeDevice = transferHandler.getActiveDevice()
        if let activeDevice = activeDevice,
            activeDevice.id == device.id {
            //            LogW("Same Device")
            return
        } else {
            self.activeDevice = device
            if let device = activeDevice {
                Observable.just(transferHandler)
                    .observeOn(bgScheduler)
                    .map { transferHandler -> Bool in
                        return transferHandler.setActiveDevice(device)
                    }
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { result in
                        //                self.LogV("Result: \(result)")
                        if (result) {
                            self.updateStorageItems(device.storages)
                        } else {
                            //                    self.LogI("No Change")
                        }
                        self.popup.isEnabled = true
                    }).disposed(by: disposeBag)
            } else {
                LogW("No Active Device")
            }
        }
    }
    
    internal func updateStorageItems(_ storages: [StorageItem]) {
        self.storages = storages
        self.table.reloadData()
        self.updateStorageSelection(transferHandler.getCurrentPath())
    }
    
    internal func refreshStorageSelection() {
        //        self.updateStorageSelection(transferHandler.getCurrentPath())
        self.table.updateItemSelected(index: selectedStorageIndex)
    }
    
    internal func updateStorageSelection(_ path: String) {
        var index = -1
        var storageItem: StorageItem? = nil
        for i in 0..<self.storages.count {
            let storageLocation = self.storages[i].path.absolutePath
            if path.starts(with: storageLocation) {
                //                self.LogV("Path: \(path), \(i)")
                index = i
                storageItem = self.storages[i]
                break
            }
        }
        //        let oldIndex = selectedStorageIndex
        selectedStorageIndex = index
        //        LogV("Reloading: \(index), \(selectedStorageIndex)")
        if index != -1, let storageItem = storageItem {
            //            self.table.notifyItemChanged(index: index)
            //            let indexSet = IndexSet(integer: index)
            //            self.table.selectRowIndexes(indexSet, byExtendingSelection: true)
            refreshStorageSelection()
            self.statusView.updateStorageItem(storageItem)
        } else {
            //            self.statusView.resetSize()
            //            self.statusView.resetTitle()
        }
        //        self.table.notifyItemChanged(index: oldIndex)
    }
    
    func doubleClick(_ sender: AnyObject) {
        //openInTable()
    }
    
    private func openInTable(_ index: Int, external: Bool) {
        if (index < 0) {
            LogW("Bad index, menu")
            stopAnimation()
            return
        }
        let oldIndex = selectedStorageIndex
        //        print("Double Clicked Menu:", index, storages[index])
        NotificationCenter.default.post(name: Notification.Name(rawValue: AndroidViewController.NotificationStartLoading), object: nil)
        Observable.just(transferHandler)
            .observeOn(MainScheduler.instance)
            .map { transferHandler -> TransferHandler in
                if (oldIndex != index) {
                    self.statusView.resetTitle()
                }
                self.statusView.resetSize()
                return transferHandler
            }
            .observeOn(bgScheduler)
            .subscribe(onNext: { transferHandler in
                transferHandler.resetStorageDetails()
                transferHandler.updateList(self.storages[index].path.absolutePath)
                transferHandler.updateStorage()
            }).disposed(by: disposeBag)
        if (external) {
            closeMenu(self)
        }
    }
    
    @objc func tableAction(_ sender: AnyObject) {
        //        print("tableAction Menu:", index)
        openInTable(table.clickedRow, external: true)
    }
    
    private func initUiContent() {
        //print("Dark:", R.color.menuBgColor, R.color.dark)
        self.popup.removeAllItems()
        self.popup.action = #selector(onPopupSelected(_:))
        self.popup.target = self
        self.popup.pullsDown = false
        overlayView.setBackground(R.color.menuBgColor)
        navigationParent.setBackground(R.color.menuNavColor)
        navigationParent.dropShadow()
        //testPopup.layer?.backgroundColor = R.color.black.cgColor
        //popup.backgroundColor = R.color.black
        table.backgroundColor = R.color.menuTableColor
        table.delegate = self
        table.dataSource = self
        table.selectionHighlightStyle = .none
        table.target = self
        //		table.doubleAction = #selector(tableAction(_:))
        table.action = #selector(tableAction(_:))
        back.setImage(name: R.drawable.menu_back)
        refresh.setImage(name: R.drawable.refresh)
//        refresh.frame.size = (refresh.image?.size)!
        if let image = refresh.image {
//            let x = refresh.frame.width / 2
//            let y = refresh.frame.height / 2
            refresh.frame.size.width = image.size.width
            refresh.frame.size.height = image.size.height
//            refresh.layer?.position = CGPoint(x: x, y: y)
        }
    }
    
    private func initSizes() {
        let newSize = NSSize(width: frameSize.width, height: frameSize.height)
        self.view.frame.size = newSize
        self.overlayView.frame.size = newSize
        self.overlayView.frame.origin = self.view.frame.origin
        
        let navigationSize = NSSize(width: frameSize.width * 0.5, height: frameSize.height)
        self.navigationParent.frame.origin = self.view.frame.origin
        self.navigationParent.frame.size = navigationSize
        self.tableOuter.frame.origin = CGPoint(x: 0, y: popup.accessibilityFrame().origin.y - popup.cellSize.height - 10)
        self.tableOuter.frame.size = NSSize(width: frameSize.width * 0.5, height: frameSize.height - popup.cellSize.height)
        self.table.intercellSpacing = NSSize(width: 0, height: 15)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        //		table.makeFirstResponder(self.view.window)
    }
    
    public func animate(open: Bool, handler: @escaping () -> () = {}) {
        //window.setFrame(frameSize, display: true)
        //self.view.frame.size = NSSize(width: frameSize.width, height: frameSize.height)
        let navigationSize = NSSize(width: frameSize.width * 0.5, height: frameSize.height)
        self.navigationParent.frame.origin = self.view.frame.origin
        self.navigationParent.frame.size = navigationSize
        let animView = self.navigationParent!
        let fadeView = self.overlayView!
        var dx = animView.frame.size.width
        var alpha = CGFloat(1.0)
        if (open) {
            animView.frame = animView.frame.offsetBy(dx: -dx, dy: 0)
            fadeView.alphaValue = 0
        } else {
            dx = -dx
            alpha = 1 - alpha
        }
        
        //        print("Dx", dx, animView.frame)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = R.number.animStartDuration
            animView.animator().frame = animView.frame.offsetBy(dx: dx, dy: 0)
            fadeView.animator().alphaValue = alpha
        }, completionHandler: handler)
    }
    
    internal func startAnimation() {
        self.refresh.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.refresh.layer?.position = CGPoint(x: self.refresh.frame.origin.x + self.refresh.frame.width / 2,
                                               y: self.refresh.frame.origin.y + self.refresh.frame.height / 2)
        CATransaction.begin()
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = NSNumber(value: 360 * .pi / 180.0)
        rotationAnimation.duration = 0.5;
        rotationAnimation.isCumulative = true;
        rotationAnimation.repeatCount = .infinity;
        CATransaction.setCompletionBlock {
//            print("Anim End!")
            self.refresh.layer?.anchorPoint = CGPoint(x: 0.0, y: 0.0)
            self.refresh.layer?.position = CGPoint(x: self.refresh.frame.origin.x,
                                                   y: self.refresh.frame.origin.y)
        }
        self.refresh.layer?.add(rotationAnimation, forKey: "rotationAnimation")
        CATransaction.commit()
        self.refresh.isEnabled = false
    }
    
    internal func stopAnimation() {
        self.refresh.layer?.removeAllAnimations()
        self.refresh.isEnabled = true
    }
    
    @IBAction func refreshMenu(_ sender: Any) {
        startAnimation()
        reload()
    }
}
