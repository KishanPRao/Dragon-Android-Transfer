//
//  WlessItem.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 17/12/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa

class WlessItem: NSCollectionViewItem {
    override var isSelected: Bool {
        didSet {
            view.layer?.borderWidth = isSelected ? 5.0 : 0.0
        }
    }
    
    var itemTitle = "<Unknown>"
    var image: NSImage? {
        didSet {
            guard isViewLoaded else { return }
            imageView?.image = image
            textField?.stringValue = itemTitle
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        let bgColor = NSColor.darkGray
        view.layer?.backgroundColor = bgColor.cgColor
        view.layer?.borderColor = NSColor.lightGray.cgColor
        view.layer?.cornerRadius = 5.0
        view.layer?.borderWidth = 0.0
    }
}
