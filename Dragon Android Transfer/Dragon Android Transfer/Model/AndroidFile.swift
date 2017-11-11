//
//  BaseFile.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/16.
//  Copyright © 2016 Kishan P Rao. All rights reserved.
//

import Foundation

public enum BaseFileType {
	static let File = 0
	static let Directory = 1
}

class BaseFile {
//	internal let TAG = "BaseFile"
	var fileName: String = ""
	var path: String = ""
	var type: Int
    var size: UInt64
    
//    UI Specific:
    var index: Int = -1
	
    init(fileName: String, path: String, type: Int, size: UInt64) {
		self.fileName = fileName
		self.path = path
		self.type = type
        self.size = size
	}
    
    func getFullPath() -> String {
        return path + HandlerConstants.SEPARATOR + fileName
    }
	
//	override var description: String { return "BaseFile: \(fileName, path, type, size)" }
}
