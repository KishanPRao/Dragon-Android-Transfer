//
//  AndroidDevice.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 18/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation
import Cocoa

public class AndroidDevice: NSObject {
	var id : String = ""
	var name : String = ""
	var externalStorages = [String]()
	
	init(id: String, name: String, externalStorages: [String] = []) {
		self.id = id
		self.name = name
		self.externalStorages = externalStorages
	}
	
    override public var description: String { return "AndroidDevice" + ": \(id, name)" }
}
