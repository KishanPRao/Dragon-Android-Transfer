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
	
    internal func updatePopup(_ devices: [AndroidDevice]) {
        self.androidDevices = devices
//        self.LogV("Devices", devices)
        self.popup.removeAllItems()
        if (devices.count == 0) {
            return
        }
        var deviceNames = [] as Array<String>
        var i = 0
        let activeDevice = self.transferHandler.getActiveDevice()
        while i < devices.count {
            let device = devices[i]
            deviceNames.append(device.name)
            i = i + 1
        }
        self.popup.addItems(withTitles: deviceNames)
//        LogV("Adding Popup: \(deviceNames)")
        for i in 0..<devices.count {
            let device = devices[i]
            if let activeDevice = activeDevice {
                if (device.id == activeDevice.id) {
//                    self.LogI("Active: \(i)")
                    self.popup.selectItem(at: i)
                    break
                }
            }
        }
    }
    
	internal func observe() {
		transferHandler.observeAndroidDevices()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					devices in
                    self.updatePopup(devices)
				}).addDisposableTo(disposeBag)
		
		transferHandler.observeActiveDevice()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					device in
					//print("Device", device)
					if let device = device {
						//print("Device Storage", device.storages)
						self.updateStorageItems(device.storages)
					}
				}).addDisposableTo(disposeBag)
		transferHandler.observeCurrentPath()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					path in
                    self.updateStorageSelection(path)
				}).addDisposableTo(disposeBag)
        
        transferHandler.getSpaceStatus()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { spaceStatus in
//                self.LogI("Space Status: \(spaceStatus)")
                if (spaceStatus.count < 2) {
                    self.statusView.resetSize()
                    return
                }
                let available = spaceStatus[0]
                let total = spaceStatus[1]
                self.statusView.updateStorageSize(availableSpace: available, totalSpace: total)
            }).addDisposableTo(disposeBag)
	}
}
