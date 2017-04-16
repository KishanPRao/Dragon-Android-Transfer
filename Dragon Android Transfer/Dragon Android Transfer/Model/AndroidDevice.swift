//
//  AndroidDevice.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 18/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class AndroidDevice: BaseObject {
	let TAG = "AndroidDevice"
	var id : String = ""
	var name : String = ""
	
	init(id: String, name: String) {
		self.id = id
		self.name = name
	}
	
	var description: String { return TAG+": \(id, name)" }
}
