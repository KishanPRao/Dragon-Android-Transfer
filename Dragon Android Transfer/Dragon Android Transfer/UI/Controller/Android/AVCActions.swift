//
//  AVCActions.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift

extension AndroidViewController {
	
	
	@objc func getSelectedItemInfo() {
		if (NSObject.VERBOSE) {
			Swift.print("AndroidViewController, getSelectedItemInfo");
		}
		let selectedFile = self.androidDirectoryItems[fileTable.selectedRow]
		print("Selected", fileTable.selectedRow)
		print("Selected", self.androidDirectoryItems[fileTable.selectedRow])
        
        showProgress()
        
        Observable.just(transferHandler)
        	.observeOn(bgScheduler)
            .map { transferHandler in
                transferHandler.updateAndroidFileSize(file: selectedFile)
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: {
                self.hideProgress()
                //            let alert = NSAlert()
                //            alert.messageText = "Name: " + selectedFile.fileName
                var infoText: String = ""
                var image: NSImage
                if (selectedFile.type == BaseFileType.Directory) {
                    image = NSImage(named: NSImage.Name(rawValue: R.drawable.folder))!
                } else {
                    image = NSImage(named: NSImage.Name(rawValue: R.drawable.file))!
                }
                if (NSObject.VERBOSE) {
                    Swift.print("AndroidViewController, image size:", image.size);
                }
                //            alert.icon = image
                infoText = "Path: " + selectedFile.path + "\n"
                var type = "File"
                if (selectedFile.type == BaseFileType.Directory) {
                    type = "Directory"
                }
                infoText = infoText + "Type: " + type + "\n"
                infoText = infoText + "Size: " + SizeUtils.getBytesInFormat(selectedFile.size) + "\n"
                
                let alertProps = AlertProperty()
                alertProps.message = "Name: " + selectedFile.fileName
                alertProps.info = infoText
                alertProps.textColor = R.color.dialogTextColor
                let buttonProp = AlertButtonProperty(title: R.string.ok)
                buttonProp.isSelected = true
//                buttonProp.bgColor = R.color.dialogSelectionColor
                alertProps.addButton(button: buttonProp)
                let alert = DarkAlert(property: alertProps)
                alert.icon = image
                alert.alertStyle = .informational
                alert.runModal()
            }).disposed(by: disposeBag)
	}
	
	@objc func showNewFolderDialog() {
		if (NSObject.VERBOSE) {
			Swift.print("AndroidViewController, showNewFolderDialog")
		}
        let inputAlertProps = InputAlertProperty()
        inputAlertProps.message = "Create New Folder"
        inputAlertProps.info = "Enter the name of the new folder:"
        inputAlertProps.textColor = R.color.dialogTextColor
        let buttonProp = AlertButtonProperty(title: R.string.ok)
        buttonProp.isSelected = true
//        buttonProp.bgColor = R.color.dialogSelectionColor
        inputAlertProps.addButton(button: buttonProp)
        inputAlertProps.addButton(button: AlertButtonProperty(title: R.string.cancel))
        inputAlertProps.defaultValue = "Untitled Folder"
        
		if let folderName = DarkAlertUtils.input(property: inputAlertProps) {
            print("AndroidViewController, folder:", folderName)
			if (transferHandler.folderExists(folderName)) {
                let alertProps = AlertProperty()
                alertProps.message = "Folder '\(folderName)' already exists!"
                alertProps.textColor = R.color.dialogTextColor
                let buttonProp = AlertButtonProperty(title: R.string.ok)
                buttonProp.isSelected = true
//                buttonProp.bgColor = R.color.dialogSelectionColor
                alertProps.addButton(button: buttonProp)
                alertProps.style = .critical
                
                DarkAlertUtils.showAlert(property: alertProps)
			} else {
				transferHandler.createAndroidFolder(folderName)
				refresh()
			}
		} else {
			print("AndroidViewController, no folder")
		}
	}
	
	@objc func deleteFileDialog() {
		if (Verbose) {
			Swift.print("AndroidViewController, deleteFileDialog")
		}
		let indexSet = fileTable.selectedRowIndexes
		var currentIndex = indexSet.first
		transferHandler.clearClipboardMacItems()
		transferHandler.clearClipboardAndroidItems()
		var deleteItems: Array<BaseFile> = []
		
		while (currentIndex != nil && currentIndex != NSNotFound) {
			let currentItem = androidDirectoryItems[currentIndex!];
			deleteItems.append(currentItem)
			currentIndex = indexSet.integerGreaterThan(currentIndex!)
		}
		let deleteStringInDialog = (deleteItems.count > 1) ? "the Selected Items" : "`" + deleteItems[0].fileName + "`"
		//        let selectedItem = self.androidDirectoryItems[fileTable.selectedRow]
		//        let selectedFileName = selectedItem.fileName
        //        TODO: Update Delete Dialog!
        
        let alertProps = AlertProperty()
        alertProps.message = "Are you sure you want to delete \(deleteStringInDialog)?"
//        alertProps.info = "This item will be deleted immediately. You cannot undo this action."
        alertProps.textColor = R.color.dialogTextColor
        let buttonProp = AlertButtonProperty(title: R.string.ok)
        buttonProp.isSelected = true
//        buttonProp.bgColor = R.color.dialogSelectionDangerColor
        alertProps.addButton(button: buttonProp)
        alertProps.addButton(button: AlertButtonProperty(title: R.string.cancel))
        alertProps.style = .critical
        
        if DarkAlertUtils.showAlert(property: alertProps) {
			LogI("Delete", deleteItems)
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
						transferHandler.deleteAndroid(deleteItems)
                        self.refreshInternal()
					}
					.observeOn(MainScheduler.instance)
					.subscribe(onNext: {
						self.successfulOperation()
					}).disposed(by: disposeBag)
		} else {
			LogV("Do not Delete!")
		}
	}
	
	internal func updateActiveDevice(_ activeDevice: AndroidDeviceMac?) {
		if (NSObject.VERBOSE) {
			Swift.print("AndroidViewController, update:" + TimeUtils.getCurrentTime());
		}
		
		Observable.just(transferHandler)
				.observeOn(bgScheduler)
				.map {
					transferHandler -> TransferHandler in
					print("Bg", transferHandler)
					transferHandler.setActiveDevice(activeDevice)
					if (activeDevice != nil) {
//                    transferHandler.updateList(transferHandler.getInternalStorage(), true)
                        transferHandler.resetStorageDetails()
                        transferHandler.setUsingExternalStorage(false)  //Not sure how used yet!
//                        transferHandler.setUsingExternalStorage(true)
						transferHandler.updateStorage()
					} else {
						self.reset()
					}
					return transferHandler
				}
				.observeOn(MainScheduler.instance)
				.map {
					transferHandler in
					print("UI Stuff")
					//					self.updateClipboard()
                    self.resetDeviceStatus()
					self.updateDeviceStatus()
					self.hideProgress()
				}.subscribe(onNext: {
					// print("Result : ", devices)
					print("Complete!")
					if (NSObject.VERBOSE) {
						Swift.print("AndroidViewController, update fin:" + TimeUtils.getCurrentTime());
					}
				}).disposed(by: disposeBag)
	}
}
