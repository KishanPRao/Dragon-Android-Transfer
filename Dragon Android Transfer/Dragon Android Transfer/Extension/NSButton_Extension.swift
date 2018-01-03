//
//  NSButton_Extension.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension NSButton {
    
    public func setImage(image: NSImage) {
        self.image = image
        self.imageScaling = .scaleProportionallyUpOrDown
        self.imagePosition = .imageOnly
        self.isBordered = false
    }
    
    public func setImage(name: String) {
        self.setImage(image: NSImage(named: name)!)
    }
}
