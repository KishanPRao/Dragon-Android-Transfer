//
//  TransferViewController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 04/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift

class TransferViewController: NSViewController {
	@IBOutlet weak var overlayView: OverlayView!
	@IBOutlet weak var closeButton: NSButton!
	@IBOutlet weak var moreButton: NSButton!
	
	@IBOutlet weak var transferDialog: NSView!
	@IBOutlet weak var pathTransferString: NSTextField!
	@IBOutlet weak var pathTransferSize: NSTextField!
	@IBOutlet weak var timeRemainingText: NSTextField!
	@IBOutlet weak var copyingTextField: NSTextField!
	@IBOutlet weak var srcDeviceImageView: NSImageView!
	@IBOutlet weak var destDeviceImageView: NSImageView!
	@IBOutlet weak var transferProgressView: ProgressView!
	
	//  Transfer related
	internal let transferHandler = TransferHandler.sharedInstance
	internal let bgScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
    var disposeBag = DisposeBag()
    
	internal var copyDestination = ""
	internal var currentCopyFile = ""
	internal var transferType = -1
	internal var currentFile: BaseFile? = nil
	internal var currentCopiedSize = 0 as UInt64
	internal var totalSize: UInt64 = 0
	
	let androidImage = NSImage(named: NSImage.Name(rawValue: R.drawable.android))
	let macImage = NSImage(named: NSImage.Name(rawValue: R.drawable.mac))
    let normalMore = NSImage(named: NSImage.Name(rawValue: R.drawable.more))
    let rotatedMore = NSImage(named: NSImage.Name(rawValue: R.drawable.more))!.imageRotatedByDegrees(degrees: 180)
	
	internal var alert: DarkAlert? = nil
	
	internal let mDockTile: NSDockTile = NSApplication.shared.dockTile
	internal var mDockProgress: NSProgressIndicator? = nil
	internal var mCurrentProgress = -1.0
    internal var mProgress: Progress? = nil
	
	public var frameSize = NSRect()
	
	private var expanded = false
    
    internal var timer: Timer? = nil
    private static let kDefaultUpdateDelay = 3.0
    internal let updateDelay = kDefaultUpdateDelay
    
    internal var previousCopiedSize = 0.0
    internal var averageCopyAmount = 0.0
    internal var start: DispatchTime? = nil
    
    var transferDialogOrigFrame = NSRect()
	
	func exit() {
		NSAnimationContext.runAnimationGroup({ context in
			context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			context.duration = R.integer.animEndDuration
			self.transferDialog.animator().frame.size = NSSize(width: 0, height: 0)
			self.transferDialog.animator().frame.origin = CGPoint(x: self.view.frame.width / 2.0, y: self.view.frame.height / 2.0)
		}, completionHandler: {
			self.view.removeFromSuperview()
			self.removeFromParentViewController()
		})
		overlayView.hide()
	}
	
	@objc func cancelTransferInternal() {
        alert = DarkAlert(message: "Cancel?", info: "Do you want to cancel the current transfer?",
                          buttonNames: ["Ok", "Cancel"])
		let button = alert!.runModal()
		if (button == NSApplication.ModalResponse.alertSecondButtonReturn) {
//            Ok
			transferHandler.cancelActiveTask()
			self.exit()
            onClick()
		}
	}
    
    var onClick: () -> () = {}
    
    func cancelTransfer(_ onClick: (@escaping () -> ())) {
        self.onClick = onClick
        cancelTransferInternal()
    }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initNotification()
		observeTransfer()
        
        transferDialogOrigFrame = transferDialog.frame
	}
	
	private func initUi() {
        transferDialog.frame = transferDialogOrigFrame
        expanded = false
        currentFile = nil
        copyDestination = ""
        currentCopyFile = ""
        currentCopiedSize = 0
        totalSize = 0
        transferProgressView.setProgress(0.0)
        
		self.view.frame.size = frameSize.size
		
		overlayView.frame = self.view.frame
		overlayView.setBackground(R.color.menuBgColor)
        overlayView.setOnClickListener {
            NSSound.init(named: NSSound.Name(rawValue: "Funk"))?.play()
        }
		
		self.transferDialog.setBackground(R.color.transferBg)
		self.transferDialog.cornerRadius(5.0)
//		self.transferDialog.dropShadow()
		closeButton.setImage(name: R.drawable.cancel_transfer)
		closeButton.action = #selector(cancelTransferInternal)
		closeButton.target = self

		moreButton.setBackground(R.color.transferBg)
		moreButton.image = normalMore
		moreButton.attributedTitle = TextUtils.getTruncatedAttributeString("More",
				.left,
				R.color.transferTextColor)
		moreButton.isBordered = false
		moreButton.imagePosition = .imageRight
		
		initText(pathTransferString)
		initText(pathTransferSize)
		initText(copyingTextField)
		
		copyingTextField.attributedStringValue = TextUtils.attributedBoldString(from: "Copying",
				color: R.color.transferTextColor,
				nonBoldRange: nil)
		
		srcDeviceImageView.isHidden = true
		destDeviceImageView.isHidden = true
		pathTransferString.stringValue = R.string.textViewPlaceHolder
		pathTransferSize.stringValue = R.string.textViewPlaceHolder
        
//        timeRemainingText.textColor = R.color.transferTextColor
//        timeRemainingText.alignment = .center
//        timeRemainingText.stringValue = R.string.textViewPlaceHolder
        timeRemainingText.attributedStringValue = TextUtils.attributedBoldString(
                from: R.string.textViewPlaceHolder,
                color: R.color.transferTextColor,
                nonBoldRange: nil,
                .center)
//        LogI("Init UI")
//        self.view.makeFirstResponder(self.view.window)
        
        let imageView = NSImageView()
        imageView.image = NSApplication.shared.applicationIconImage
        mDockTile.contentView = imageView
        
        mDockProgress = NSProgressIndicator(frame: NSMakeRect(0.0, 0.0, mDockTile.size.width, 10))
        if let dockProgress = mDockProgress {
            dockProgress.style = NSProgressIndicator.Style.bar
            dockProgress.isIndeterminate = false
            dockProgress.minValue = 0
            dockProgress.maxValue = 100
            imageView.addSubview(dockProgress)
            dockProgress.isBezeled = true
            dockProgress.isHidden = true
        }
	}
	
	private func updateButton(_ button: NSButton, _ image: NSImage) {
		button.setImage(image: image)
		button.imageScaling = .scaleAxesIndependently
	}
	
	private func initText(_ textField: NSTextField) {
		textField.isHidden = true
		textField.stringValue = ""
		textField.textColor = R.color.transferTextColor
	}
	
	internal func updateTransferState() {
		srcDeviceImageView.isHidden = false
		destDeviceImageView.isHidden = false
		if (transferType == TransferType.AndroidToMac) {
			srcDeviceImageView.image = androidImage
			destDeviceImageView.image = macImage
		} else {
			srcDeviceImageView.image = macImage
			destDeviceImageView.image = androidImage
		}
	}
	
	@IBAction func toggleExpansion(_ sender: Any) {
//        LogV("Toggle")
		var hide = false
		var heightOffset = 90 as CGFloat
		if (expanded) {
			heightOffset = -heightOffset
			hide = true
		}
		NSAnimationContext.runAnimationGroup({ context in
			context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			context.duration = 0.1
			self.transferDialog.animator().frame.size.height = self.transferDialog.frame.size.height + heightOffset
			self.transferDialog.animator().frame.origin.y = self.transferDialog.frame.origin.y - heightOffset
			self.copyingTextField.animator().isHidden = hide
			self.pathTransferString.animator().isHidden = hide
			self.pathTransferSize.animator().isHidden = hide
		}, completionHandler: nil)
		self.expanded = !self.expanded
		
		if (expanded) {
			moreButton.image = rotatedMore
		} else {
			moreButton.image = normalMore
		}
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
		initUi()
		overlayView.show()
		let origSize = self.transferDialog.frame.size
		let origOrigin = self.transferDialog.frame.origin
		self.transferDialog.frame.size = NSSize(width: 0, height: 0)
		self.transferDialog.frame.origin = CGPoint(x: self.view.frame.width / 2.0, y: self.view.frame.height / 2.0)
		NSAnimationContext.runAnimationGroup({ context in
			context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
			context.duration = R.integer.animStartDuration
			self.transferDialog.animator().frame.size = origSize
			self.transferDialog.animator().frame.origin = origOrigin
		}, completionHandler: nil)
	}
	
	func refresh() {
		Observable.just(transferHandler)
				.observeOn(MainScheduler.instance)
				.map {
					transferHandler -> TransferHandler in
					NSObject.sendNotification(AndroidViewController.NotificationStartLoading)
					return transferHandler
				}
				.observeOn(bgScheduler)
				.map {
					transferHandler in
//					self.LogV("Refresh TVC!")
                    transferHandler.resetStorageDetails()
					transferHandler.updateList(transferHandler.getCurrentPath(), true)
					transferHandler.updateStorage()
				}
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {}).disposed(by: disposeBag)
	}
	
	private func initNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(pasteToAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.PASTE_TO_ANDROID), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(pasteToMac), name: NSNotification.Name(rawValue: StatusTypeNotification.PASTE_TO_MAC), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(pasteToAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_PASTE_FILES), object: nil)
	}
	
	
	func successfulOperation() {
		NSSound(named: NSSound.Name(rawValue: R.audio.endCopy))?.play()
//		NSSound(named: NSUserNotificationDefaultSoundName)?.play()
		NSApp.requestUserAttention(NSApplication.RequestUserAttentionType.informationalRequest)
	}
}
