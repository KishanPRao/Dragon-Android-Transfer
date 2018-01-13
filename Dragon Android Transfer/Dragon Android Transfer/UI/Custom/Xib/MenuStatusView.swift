//
//  MenuStatusView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 07/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class MenuStatusView: NSView {
    @IBOutlet weak var rootView: NSView!
    @IBOutlet weak var image: NSImageView!
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var progressView: ProgressView!
    @IBOutlet weak var sizeStatus: NSTextField!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        commonInit()
    }
    
    func updateStorageItem(_ storageItem: StorageItem) {
        self.animate(show: true)
        title.stringValue = storageItem.path.name
    }
    
    func updateStorageSize(availableSpace: String, totalSpace: String) {
        self.animate(show: true)
        let middleString = " free of "
        let stringValue = availableSpace + middleString + totalSpace
        let range = NSMakeRange(availableSpace.count, middleString.count)
        sizeStatus.attributedStringValue = TextUtils.attributedBoldString(from: stringValue,
                                                                      color: R.color.textColor,
                                                                      nonBoldRange: range)
        
        let availableSpaceInNumber = SizeUtils.getSpaceInNumber(availableSpace)
        let totalSpaceInNumber = SizeUtils.getSpaceInNumber(totalSpace)
        let progress = (100.0 - ((availableSpaceInNumber / totalSpaceInNumber) * 100.0))
        progressView.setProgress(CGFloat(progress))
//        LogV("Available: \(availableSpaceInNumber)")
//        LogV("Total: \(totalSpaceInNumber)")
//        LogV("Progress: \(progress)")
    }
    
    func resetNoDevice() {
        self.animate(show: false)
    }
    
    func resetTitle() {
        title.stringValue = R.string.textViewPlaceHolder
        self.animate(show: true)
    }
    
    func resetSize() {
        progressView.setProgress(0.0)
        sizeStatus.stringValue = R.string.textViewPlaceHolder
        self.animate(show: true)
    }
    
    private func commonInit() {
        loadNib()
        self.addSubview(rootView)
        image.setImage(name: R.drawable.info)
        title.textColor = R.color.textColor
        sizeStatus.textColor = R.color.textColor
        title.updateMainFont()
        sizeStatus.updateMainFont()
        resetTitle()
        resetSize()
//        self.alphaValue = 0
    }
}
