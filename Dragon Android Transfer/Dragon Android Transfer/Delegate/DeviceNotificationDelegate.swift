//
//  DeviceNotificationDelegate.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 19/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

//All delegate methods must be called on Main Thread
protocol DeviceNotficationDelegate: class {
	func onConnected(_ device: AndroidDeviceMac)
	
	func onDisconnected(_ device: AndroidDeviceMac)
	
	func onUpdate()
}
