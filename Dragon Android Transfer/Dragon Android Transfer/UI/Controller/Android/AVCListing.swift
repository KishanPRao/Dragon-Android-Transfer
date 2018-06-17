//
//  AVCListing.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift

extension AndroidViewController {
	
	internal func observeListing() {
		transferHandler.observeFileList()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					list in
					self.reloadFileList(list)
				}).disposed(by: disposeBag)
		
		transferHandler.observeClipboardAndroidItems()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					list in
					self.updateClipboard()
				}).disposed(by: disposeBag)
		transferHandler.observeClipboardMacItems()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					list in
					self.updateClipboard()
					AppDelegate.hasMacClipboardItems = list.count > 0
				}).disposed(by: disposeBag)
		transferHandler.observeCurrentPath()
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {
					path in
					self.pathSelector.updateCurrentPath(path)
				}).disposed(by: disposeBag)
	}
	
	/*
	internal func observeDevices() {
		transferHandler.observeAndroidDevices()
			.subscribeOn(bgScheduler)
			.observeOn(MainScheduler.instance)
			.map {
				devices -> ([AndroidDeviceMac]) in
				Swift.print("Main 1 :", ThreadUtils.isMainThread())
				Swift.print("Observable Devices", devices)
				self.showProgress()
				if (!self.externalStorageButton.isHidden) {
					self.externalStorageButton.isHidden = true
				}
				return devices
			}
			.observeOn(bgScheduler)
			.map {
				devices -> ([AndroidDeviceMac]) in
				Swift.print("Main 2:", ThreadUtils.isMainThread())
				Swift.print("Observable Devices", devices)
				var devicesNames = [] as Array<String>
				var i = 0
				self.androidDevices.removeAllObjects()
				self.androidDevices.addObjects(from: devices)
				while i < devices.count {
					devicesNames.append(devices[i].name)
					i = i + 1
				}
				self.devicesPopUp.removeAllItems()
				self.devicesPopUp.addItems(withTitles: devicesNames)
				return devices
				
			}
			.observeOn(MainScheduler.instance)
			.map {
				devices -> ([AndroidDeviceMac]) in
				Swift.print("Main 3:", ThreadUtils.isMainThread())
				Swift.print("Observable Devices", devices)
				let selectedIndex = self.devicesPopUp.indexOfSelectedItem
				print("Update Selected:", selectedIndex)
				self.updatePopupDimens()
				var activeDevice = nil as AndroidDeviceMac?
				if (selectedIndex > -1 && selectedIndex < devices.count) {
					//TODO: Crash if rapid dc & conn.
					activeDevice = devices[selectedIndex]
				}
				self.updateActiveDevice(activeDevice)
				return devices
			}.subscribe(onNext: {
				devices in
				print("Result : ", devices)
			})
	}*/
	
	func updateList() {
//        LogV("Update List")
        self.resetDeviceStatus()
		fileTable.updateList(data: androidDirectoryItems)
		updateDeviceStatus()
        fileTable.scrollRowToVisible(0)
	}
	
	func reloadFileList(_ items: Array<BaseFile>) {
		androidDirectoryItems = items
		updateList()
//        fileTable.makeFirstResponder(self.view.window)
		hideProgress()
	}
	
	@objc func refresh() {
		Observable.just(transferHandler)
				.observeOn(MainScheduler.instance)
				.map {
					transferHandler -> TransferHandler in
					self.showProgress()
					return transferHandler
				}
				.observeOn(bgScheduler)
				.map {
					transferHandler in
                    self.refreshInternal()
//                    transferHandler.updateList(transferHandler.getCurrentPath(), true)
//                    transferHandler.updateStorage()
				}
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {}).disposed(by: disposeBag)
	}
    
    internal func refreshInternal() {
        transferHandler.updateList(transferHandler.getCurrentPath(), true)
        transferHandler.updateStorage()
    }
	
	internal func openFile(_ selectedItem: BaseFile) {
		if (selectedItem.type != BaseFileType.Directory) {
			// LogW("Trying to open a file")
			return
		}
		Observable.just(transferHandler)
				.observeOn(MainScheduler.instance)
				.map {
					transferHandler -> TransferHandler in
					self.showProgress()
					return transferHandler
				}
				.observeOn(bgScheduler)
				.map {
					transferHandler /*-> [BaseFile]?*/ in
					// TODO: Confirm this works properly!
					// let isDirectory = transferHandler.isDirectory(selectedItem.fileName)
					/*let isDirectory = true
					 if (isDirectory) {*/
					let path = self.transferHandler.getCurrentPath() + HandlerConstants.SEPARATOR + selectedItem.fileName
//                    self.LogV("Opening Dir")
					self.transferHandler.updateList(path)
//                    self.LogV("Opened Dir")
				}
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: {}).disposed(by: disposeBag)
	}
	
	@objc func openSelectedDirectory() {
//        LogI("AndroidViewController, openSelectedDirectory");
		
		let selectedItem = self.androidDirectoryItems[fileTable.selectedRow]
		//		print("Selected", fileTable.selectedRow)
		//		print("Selected", self.androidDirectoryItems[fileTable.selectedRow])
		
		openFile(selectedItem)
	}
	
	internal func navigateUpDirectory() {
		let previousDirectory = transferHandler.getCurrentPath()
		Observable.just(transferHandler)
				.observeOn(MainScheduler.instance)
				.map {
					transferHandler -> TransferHandler in
					self.showProgress()
					return transferHandler
				}
				.observeOn(bgScheduler)
				.map {
					transferHandler in
					transferHandler.navigateUpList()
				}
				.observeOn(MainScheduler.instance)
				.subscribe(
						onNext: {
							for (i, item) in self.androidDirectoryItems.enumerated() {
//                                self.LogV("Item", item, "Prev", previousDirectory)
								if (item.getFullPath() == previousDirectory) {
									self.fileTable.updateItemSelected(index: i)
									self.fileTable.scrollRowToVisible(i)
									AppDelegate.itemSelected = true
									AppDelegate.directoryItemSelected = true
								}
							}
							self.hideProgress()
						}).disposed(by: disposeBag)
	}
}
