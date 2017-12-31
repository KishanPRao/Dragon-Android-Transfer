//
//  ImageButton.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class ImageButton: NSButton {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setImage(image: NSImage) {
        if let cell = self.cell as? NSButtonCell {
            image.size = cell.cellSize
            cell.image = image
            cell.imageScaling = NSImageScaling.scaleAxesIndependently
        }
        self.imagePosition = .imageOnly
        self.isBordered = false
    }
    
    public func setImage(name: String) {
        self.setImage(image: NSImage(named: name)!)
    }
}
