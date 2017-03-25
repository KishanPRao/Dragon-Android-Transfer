//
//  CopyDialog.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 29/01/17.
//  Copyright © 2017 Untitled-TBA. All rights reserved.
//

import Cocoa

protocol CopyDialogDelegate {
	func cancelTask()
}

class CopyDialog: NSView {
    private static let VERBOSE = true;
    @IBOutlet var rootView: NSView!
    
    var progressView: ProgressView? = nil
    var transferTypeView: NSTextField? = nil
    var currentTransferView: NSTextField? = nil
    var copiedSizeView: NSTextField? = nil
    var timeLeftView: NSTextField? = nil
    var totalSizeView: NSTextField? = nil
    var closeButton: NSButton? = nil
    
    let TRANSFER_TYPE_TAG = 0
    let CURR_TRANSFER_TAG = 1
    let COPIED_TAG = 2
    let TIME_TAG = 3
    let TOTAL_TAG = 4
    let CLOSE_TAG = 5
    
    var mTransferType = ""
    var mCurrentTransfer = ""
//    var mCopiedSize = ""
    var mTimeLeft = ""
    var mTotalCopySize = 0 as UInt64
	var delegate: CopyDialogDelegate?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        Swift.print("Here!")
        loadFromNib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadFromNib()
    }
	
	func setCopyDialogDelegate(delegate: CopyDialogDelegate) {
		self.delegate = delegate
	}
	
    @IBAction func cancelActiveTask(_ sender: Any) {
		if (delegate != nil) {
			delegate!.cancelTask()
		}
    }
    
    func setTransferType(_ transferType: String) {
//        mTransferType = string
        transferTypeView?.stringValue = transferType
    }
    
    func setCurrentTransfer(_ from: String, to: String) {
        let string = from + " to " + to
//        mCurrentTransfer = string
        currentTransferView?.stringValue = string
    }
    
//    func setCopyiedSize(string: String) {
//        mCopiedSize = string
//    }
    
    func setTimeLeft(_ string: String) {
        mTimeLeft = string
    }
    
    func setTotalCopySize(_ size: UInt64) {
        mTotalCopySize = size
        totalSizeView?.stringValue = SizeUtils.getBytesInFormat(size)
    }
    
    func setCopiedSize(_ copiedSize: UInt64) {
        let progress = (CGFloat(copiedSize) / CGFloat(mTotalCopySize) * 100.0)
        progressView?.setProgress(progress)
//        if (CopyDialog.VERBOSE) {
//            Swift.print("CopyDialog, Progress:", progress);
//            Swift.print("CopyDialog, Progress View:", progressView);
//        }
        let copiedSizeInString = SizeUtils.getBytesInFormat(copiedSize)
        copiedSizeView?.stringValue = copiedSizeInString
    }
    
//    func setProgress(progress: CGFloat) {
//        progressView?.setProgress(progress)
//        let copiedSizeInInt = Int((CGFloat(mTotalCopySize) * progress) / 100.0)
//        let copiedSize = SizeUtils.getBytesInFormat(copiedSizeInInt)
//        copiedSizeView?.stringValue = copiedSize
//    }
    
    fileprivate func loadFromNib() {
        NSNib(nibNamed: "CopyDialog", bundle: nil)?.instantiate(withOwner: self, topLevelObjects: nil)
        rootView.wantsLayer = true
        rootView.layer?.backgroundColor = NSColor.black.cgColor
        rootView.layer?.masksToBounds = true
        rootView.layer?.cornerRadius = 5.0
        addSubview(rootView)
        
        var i = 0
        while i < rootView.subviews.count {
            let view = rootView.subviews[i]
            if (view.tag == TRANSFER_TYPE_TAG) {
                transferTypeView = view as? NSTextField
            } else if (view.tag == CURR_TRANSFER_TAG) {
                currentTransferView = view as? NSTextField
            } else if (view.tag == COPIED_TAG) {
                copiedSizeView = view as? NSTextField
            } else if (view.tag == TIME_TAG) {
                timeLeftView = view as? NSTextField
            } else if (view.tag == TOTAL_TAG) {
                totalSizeView = view as? NSTextField
            } else if (view.tag == CLOSE_TAG) {
                closeButton = view as? NSButton
//            } else if (view.isKind(of: ProgressView)) {
            } else if (view is ProgressView) {
				progressView = view as? ProgressView
			}
            
            i = i + 1
        }
        
//        Swift.print("Views:", rootView.subviews.last)
//        Swift.print("View Source:", transferTypeView)
//        progressView = rootView.subviews.last as? ProgressView
		let image = NSImage(named: "close_button.png")
		StyleUtils.updateButton(closeButton!, withImage: image)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
}
