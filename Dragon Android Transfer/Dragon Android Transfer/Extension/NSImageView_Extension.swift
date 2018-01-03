//
//  NSImageView_Extension.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 03/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

extension NSImageView {
    
    public func setImage(image: NSImage) {
        self.image = image
        self.imageScaling = .scaleProportionallyUpOrDown
    }
    
    public func setImage(name: String) {
        self.setImage(image: NSImage(named: name)!)
    }
}
