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
        transferHandler.observeActiveDevice()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                device in
                print("Device", device)
                if let device = device {
                    self.pathSelector.storages = device.storages
                } else {
                    self.pathSelector.storages = []
                }
            }).disposed(by: disposeBag)
	}
	
	func updateList() {
//        LogV("Update List")
        self.resetDeviceStatus()
		fileTable.updateList(data: androidDirectoryItems)
		updateDeviceStatus()
        fileTable.scrollRowToVisible(0)
	}
	
	func reloadFileList(_ items: Array<BaseFile>) {
		androidDirectoryItems = items
//        let startTime = TimeUtils.getDispatchTime()
		updateList()
//        fileTable.makeFirstResponder(self.view.window)
		hideProgress()
//        print("Update List Time Taken: \(TimeUtils.getDifference(startTime))ms")
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
        
        if (fileTable.selectedRow < 0) {
            LogW("Bad Index")
            return
        }
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
                                    break
								}
							}
//                            self.hideProgress()
						}).disposed(by: disposeBag)
	}
}
