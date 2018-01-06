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
	internal var copyDestination = ""
	internal var currentCopyFile = ""
	internal var transferType = -1
	internal var currentFile: BaseFile? = nil
	internal var currentCopiedSize = 0 as UInt64
	internal var totalSize: UInt64 = 0
	
	internal var alert: DarkAlert? = nil
	
	internal let mDockTile: NSDockTile = NSApplication.shared().dockTile
	internal var mDockProgress: NSProgressIndicator? = nil
	internal var mCurrentProgress = -1.0
	
	
	public var frameSize = NSRect()
	
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
		overlayView.hide({
//            self.view.removeFromSuperview()
//            self.removeFromParentViewController()
		})
//		self.view.removeFromSuperview()
//		self.removeFromParentViewController()
	}
	
	func close() {
		alert = DarkAlert(message: "Cancel?", info: "Do you want to cancel the current transfer?")
		let button = alert!.runModal()
		if (button == NSAlertFirstButtonReturn) {
//            Ok
			transferHandler.cancelActiveTask()
			self.exit()
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		initNotification()
		observeTransfer()
	}
	
	let normalMore = NSImage(named: R.drawable.more)
//	let rotatedMore = NSImage(named: R.drawable.more)!.imageRotated(by: 180)
	let rotatedMore = NSImage(named: R.drawable.more)!.imageRotatedByDegrees(degrees: 180)
	
	private func initUi() {
		self.view.frame.size = frameSize.size
		
		overlayView.frame = self.view.frame
		overlayView.setBackground(R.color.menuBgColor)
		//        overlayView.setOnClickListener {
		//            self.close()
		//        }
		
		
		self.transferDialog.setBackground(R.color.transferBg)
		self.transferDialog.cornerRadius(5.0)
		//        self.transferDialog.dropShadow()
		closeButton.setImage(name: R.drawable.cancel_transfer)
		closeButton.action = #selector(close)
		closeButton.target = self

//		moreButton.stringValue = ""
//		moreButton.setColorBackground(R.color.black)
//		updateButton(moreButton, NSImage.swatchWithColor(color: R.color.menuNavColor, size: moreButton.frame.size).roundCorners())
//		moreButton.attributedTitle = TextUtils.getTruncatedAttributeString("More")
//		moreButton.setText(text: "More", textColor: R.color.transferTextColor,
//				alignment: .left, bgColor: R.color.menuNavColor, 
//				rounded: true)
		moreButton.setBackground(R.color.transferBg)
		moreButton.image = normalMore
		moreButton.attributedTitle = TextUtils.getTruncatedAttributeString("More",
				.left,
				R.color.transferTextColor)
		moreButton.isBordered = false
//		moreButton.imageScaling = .scaleNone
		moreButton.imagePosition = .imageRight
//		moreButton.isBordered = false
		
		initText(pathTransferString)
		initText(pathTransferSize)
		initText(copyingTextField)
		timeRemainingText.stringValue = ""
		timeRemainingText.textColor = R.color.white
		timeRemainingText.isHidden = false
		
		copyingTextField.attributedStringValue = TextUtils.attributedString(from: "Copying",
				color: R.color.transferTextColor,
				nonBoldRange: nil)
		
		srcDeviceImageView.isHidden = true
		destDeviceImageView.isHidden = true
//        toggleExpansion(self)
		pathTransferString.stringValue = "Updating.."
		pathTransferSize.stringValue = "Updating.."
//        progressActive(0)
//        LogI("Init UI")
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
	
	let androidImage = NSImage(named: R.drawable.android)
	let macImage = NSImage(named: R.drawable.mac)
	
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
	
	var expanded = false
	
	//    TODO: Expanded in Xib.
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
					transferHandler.updateList(transferHandler.getCurrentPath())
					transferHandler.updateStorage()
				}
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {})
	}
	
	private func initNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(pasteToAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.PASTE_TO_ANDROID), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(pasteToMac), name: NSNotification.Name(rawValue: StatusTypeNotification.PASTE_TO_MAC), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(pasteToAndroid), name: NSNotification.Name(rawValue: StatusTypeNotification.MENU_PASTE_FILES), object: nil)
	}
	
	
	func successfulOperation() {
		NSSound(named: "endCopy")?.play()
		NSApp.requestUserAttention(NSRequestUserAttentionType.informationalRequest)
	}
}
