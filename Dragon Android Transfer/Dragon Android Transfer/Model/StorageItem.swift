//
//  StorageItem.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation
import Cocoa

//@objc
public class StorageItem: NSObject {
    public var name: String = ""
    public var location: String = ""
    
    init(name: String, location: String) {
        self.name = name
        self.location = location
    }
    
    public var isInternal : Bool {
        get {
            return location.contains("/sdcard")
        }
    }
}
