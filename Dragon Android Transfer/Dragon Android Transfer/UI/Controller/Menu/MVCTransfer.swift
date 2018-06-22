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
	
    internal func updatePopup(_ devices: [AndroidDeviceMac]) {
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
        for item in self.popup.itemArray {
            let fontSize: CGFloat = R.number.menuPopupSize
            item.attributedTitle = NSAttributedString(string: item.title, attributes: [
                NSAttributedStringKey.font: NSFont(name: R.font.mainFont, size: fontSize)!,
//                NSForegroundColorAttributeName: NSColor(calibratedRed: 0.2, green: 0.270588235, blue: 0.031372549, alpha: 1),
//                NSBaselineOffsetAttributeName: 2
                ])
        }
//        for item in self.popup.itemArray {
//            item.attributedTitle = NSMutableAttributedString(string: item.title, attributes: [
//                NSFontAttributeName: NSFont(name: R.font.mainFont, size: fontSize),
//                ])
//        }
    }
    
	internal func observe() {
		transferHandler.observeAndroidDevices()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					devices in
                    self.updatePopup(devices)
				}).disposed(by: disposeBag)
		
		transferHandler.observeActiveDevice()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					device in
					//print("Device", device)
					if let device = device {
                        self.refresh.isEnabled = true
						//print("Device Storage", device.storages)
						self.updateStorageItems(device.storages)
                        self.activeDevice = device
                    } else {
                        self.stopAnimation()
                        self.refresh.isEnabled = false
                        self.activeDevice = nil
                        self.statusView.resetNoDevice()
                        self.updateStorageItems([])
                    }
				}).disposed(by: disposeBag)
		transferHandler.observeCurrentPath()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					path in
                    if self.transferHandler.hasActiveDevice() {
                    	self.updateStorageSelection(path)
                    } else {
//                        self.statusView.resetNoDevice()
                    }
				}).disposed(by: disposeBag)
        
        transferHandler.getSpaceStatus()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { spaceStatus in
//                self.LogI("Space Status: \(spaceStatus)")
                if (spaceStatus.count < 2) {
//                    self.statusView.resetSize()
//                    self.statusView.resetNoDevice()
                    return
                }
                let available = spaceStatus[0]
                let total = spaceStatus[1]
                self.statusView.updateStorageSize(availableSpace: available, totalSpace: total)
                self.stopAnimation()
            }).disposed(by: disposeBag)
	}
}
