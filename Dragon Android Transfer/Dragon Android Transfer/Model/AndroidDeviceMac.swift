//
//  AndroidDeviceMac.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 18/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation
import Cocoa

@objcMembers public class AndroidDeviceMac: NSObject {
	var id : String = ""
	var name : String = ""
	var storages = [StorageItem]()
	
	init(id: String, name: String, storages: [StorageItem] = []) {
		self.id = id
		self.name = name
		self.storages = storages
	}
	
    override public var description: String { return "AndroidDeviceMac" + ": \(id, name)" }
}
