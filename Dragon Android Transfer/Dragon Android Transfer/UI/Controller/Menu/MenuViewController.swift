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
	@IBOutlet weak var table: NSTableView!
	@IBOutlet weak var tableOuter: NSScrollView!
	
	@IBOutlet weak var testPopup: NSPopUpButton!
	internal let transferHandler = TransferHandler.sharedInstance
	internal let bgScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    var disposeBag = DisposeBag()
	
	public var frameSize = NSRect()
	internal var storages = [StorageItem]()
	
	var androidDevices = [AndroidDevice]()
    
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
    
    var activeDevice: AndroidDevice? = nil
    
    internal func reset() {
        self.popup.isEnabled = false
        self.statusView.resetNoDevice()
        updateStorageItems([])
    }
	
	func onPopupSelected(_ sender: Any) {
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
            reset()
        }
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
            }).addDisposableTo(disposeBag)
	}
	
	internal func updateStorageItems(_ storages: [StorageItem]) {
		self.storages = storages
		self.table.reloadData()
        self.updateStorageSelection(transferHandler.getCurrentPath())
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
        let oldIndex = selectedStorageIndex
        selectedStorageIndex = index
//        LogV("Reloading: \(index), \(selectedStorageIndex)")
        if index != -1 {
            self.table.notifyItemChanged(index: index)
//            self.table.selectRowIndexes(indexSet, byExtendingSelection: true)
            self.statusView.updateStorageItem(storageItem!)
        } else {
//            self.statusView.resetSize()
//            self.statusView.resetTitle()
        }
        self.table.notifyItemChanged(index: oldIndex)
    }
    
	func doubleClick(_ sender: AnyObject) {
		//openInTable()
	}
	
	private func openInTable() {
		let index = table.clickedRow
		if (index < 0) {
			//LogW("Bad index, menu")
			return
		}
//        print("Double Clicked Menu:", index, storages[index])
		NotificationCenter.default.post(name: Notification.Name(rawValue: AndroidViewController.NotificationStartLoading), object: nil)
		Observable.just(transferHandler)
            	.observeOn(MainScheduler.instance)
            	.map { transferHandler -> TransferHandler in
                    self.statusView.resetTitle()
                    self.statusView.resetSize()
                    return transferHandler
            	}
				.observeOn(bgScheduler)
            	.subscribe(onNext: { transferHandler in
                    transferHandler.resetStorageDetails()
					transferHandler.updateList(self.storages[index].path.absolutePath)
                    transferHandler.updateStorage()
				}).addDisposableTo(disposeBag)
		closeMenu(self)
	}
	
	func tableAction(_ sender: AnyObject) {
//        print("tableAction Menu:", index)
		openInTable()
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
		back.setImage(name: "menu_back.png")
	}
	
	private func initSizes() {
		let newSize = NSSize(width: frameSize.width, height: frameSize.height)
		self.view.frame.size = newSize
		self.overlayView.frame.size = newSize
		self.overlayView.frame.origin = self.view.frame.origin
		
		let navigationSize = NSSize(width: frameSize.width * 0.5, height: frameSize.height)
		self.navigationParent.frame.origin = self.view.frame.origin
		self.navigationParent.frame.size = navigationSize
		self.tableOuter.frame.origin = CGPoint(x: 0, y: popup.accessibilityFrame().origin.y - popup.cellSize.height)
		self.tableOuter.frame.size = NSSize(width: frameSize.width * 0.5, height: frameSize.height - popup.cellSize.height)
		self.table.intercellSpacing = NSSize(width: 0, height: 10)
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
			context.duration = R.integer.animStartDuration
			animView.animator().frame = animView.frame.offsetBy(dx: dx, dy: 0)
			fadeView.animator().alphaValue = alpha
		}, completionHandler: handler)
	}
}
