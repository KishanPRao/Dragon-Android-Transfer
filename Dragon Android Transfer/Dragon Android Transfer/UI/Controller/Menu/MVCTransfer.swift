//
//  MVCTransfer.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift

extension MenuViewController {
	
	internal func observe() {
		transferHandler.observeAndroidDevices()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					devices in
					print("Devices", devices)
					self.popup.removeAllItems()
					if (devices.count == 0) {
						return
					}
					var devicesNames = [] as Array<String>
					var i = 0
					while i < devices.count {
						devicesNames.append(devices[i].name)
						i = i + 1
					}
					self.popup.addItems(withTitles: devicesNames)
				})
		
		transferHandler.observeActiveDevice()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					device in
					//print("Device", device)
					if let device = device {
						//print("Device Storage", device.storages)
						self.storages = device.storages
						self.table.reloadData()
					}
				})
		transferHandler.observeCurrentPath()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					path in
					
				})
	}
}
