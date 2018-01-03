//
//  ImageButton.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

/*
extension NSButton {
	/*
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}*/
	
	public func setImage(image: NSImage) {
//        if let cell = self.cell as? NSButtonCell {
//            image.size = cell.cellSize
//            cell.image = image
////            cell.imageScaling = NSImageScaling.scaleAxesIndependently
////            cell.imageScaling = NSImageScaling.scaleProportionallyUpOrDown
//            cell.imageScaling = NSImageScaling.scaleProportionallyDown
//        }
		self.image = image
		self.imageScaling = .scaleProportionallyUpOrDown
		self.imagePosition = .imageOnly
//        self.imagePosition = .imageOverlaps
		self.isBordered = false
	}
	
	public func setImage(name: String) {
		self.setImage(image: NSImage(named: name)!)
	}
}*/
