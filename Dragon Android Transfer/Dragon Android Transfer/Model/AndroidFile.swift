//
//  BaseFile.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 25/12/16.
//  Copyright © 2016 Untitled-TBA. All rights reserved.
//

import Foundation

public enum BaseFileType {
	static let File = 0
	static let Directory = 1
}

class BaseFile: BaseObject {
	fileprivate let TAG = "BaseFile"
	var fileName: String = ""
	var path: String = ""
	var type: Int
    var size: UInt64
	
    init(fileName: String, path: String, type: Int, size: UInt64) {
		self.fileName = fileName
		self.path = path
		self.type = type
        self.size = size
	}
	
	var description: String { return TAG+": \(fileName, path, type, size)" }
}
