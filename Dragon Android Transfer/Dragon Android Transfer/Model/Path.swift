//
//  Path.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 07/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

public class Path: NSObject {
    func getPathName() -> String {
        var pathName = ""
        if (absolutePath == "/sdcard") {
            pathName = "Internal Storage"
        } else {
            pathName = name
        }
        return pathName
    }
    
    public var name: String
    public var absolutePath: String
    
    init(_ _name: String, _ path: String) {
        name = _name
        absolutePath = path
    }
    
    override public var description: String {
        return "Path: \(name), \(absolutePath)"
    }
}
