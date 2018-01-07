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
					self.androidDevices = devices
					self.LogV("Devices", devices)
					self.popup.removeAllItems()
					if (devices.count == 0) {
						return
					}
					var devicesNames = [] as Array<String>
					var i = 0
					let activeDevice = self.transferHandler.getActiveDevice()
					while i < devices.count {
						let device = devices[i]
						devicesNames.append(device.name)
						i = i + 1
					}
					self.popup.addItems(withTitles: devicesNames)
					for i in 0..<devices.count {
						let device = devices[i]
						if let activeDevice = activeDevice {
							if (device.id == activeDevice.id) {
								self.LogI("Active: \(i)")
								self.popup.selectItem(at: i)
								break
							}
						}
					}
				})
		
		transferHandler.observeActiveDevice()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					device in
					//print("Device", device)
					if let device = device {
						//print("Device Storage", device.storages)
						self.updateStorageItems(device.storages)
					}
				})
		transferHandler.observeCurrentPath()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					path in
                    self.updateStorageSelection(path)
				})
	}
}
