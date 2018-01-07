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
//    public var name: String = ""
//    public var location: String = ""
    public var path = Path("", "")
    
    init(_ path: Path) {
        self.path = path
    }
    
    public var isInternal : Bool {
        get {
            return path.absolutePath.contains("/sdcard")
        }
    }
    
    public override var description: String {
        return "StorageItem: \(path.name, path.absolutePath)"
    }
}
