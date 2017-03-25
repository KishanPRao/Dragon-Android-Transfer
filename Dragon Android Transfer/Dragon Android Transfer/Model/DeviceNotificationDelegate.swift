//
//  DeviceNotificationDelegate.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 19/01/17.
//  Copyright © 2017 Untitled-TBA. All rights reserved.
//

import Foundation

//All delegate methods must be called on Main Thread
protocol DeviceNotficationDelegate: class {
	func onConnected(_ device: AndroidDevice)
	
	func onDisconnected(_ device: AndroidDevice)
	
	func onUpdate()
}
