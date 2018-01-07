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
    
    
    func getSelectedItemInfo() {
        if (NSObject.VERBOSE) {
            Swift.print("AndroidViewController, getSelectedItemInfo");
        }
        let selectedFile = self.androidDirectoryItems[fileTable.selectedRow]
        print("Selected", fileTable.selectedRow)
        print("Selected", self.androidDirectoryItems[fileTable.selectedRow])
        
        transferHandler.updateAndroidFileSize(file: selectedFile, closure: {
            let alert = NSAlert()
            alert.messageText = "Name: " + selectedFile.fileName
            var infoText: String = ""
            var image: NSImage
            if (selectedFile.type == BaseFileType.Directory) {
                image = NSImage(named: "folder")!
            } else {
                image = NSImage(named: "file")!
            }
            if (NSObject.VERBOSE) {
                Swift.print("AndroidViewController, image size:", image.size);
            }
            alert.icon = image
            infoText = "Path: " + selectedFile.path + "\n"
            var type = "File"
            if (selectedFile.type == BaseFileType.Directory) {
                type = "Directory"
            }
            infoText = infoText + "Type: " + type + "\n"
            infoText = infoText + "Size: " + SizeUtils.getBytesInFormat(selectedFile.size) + "\n"
            alert.informativeText = infoText
            alert.runModal()
            //		alert.addButton(withTitle: "Ok")
            //		let response = alert.runModal()
            //		if (NSObject.VERBOSE) {
            //			Swift.print("AndroidViewController, alert resp:", response);
            //		}
        })
    }
    
    func showNewFolderDialog() {
        if (NSObject.VERBOSE) {
            Swift.print("AndroidViewController, showNewFolderDialog")
        }
        if let folderName = AlertUtils.input("Create New Folder", info: "Enter the name of the new folder:", defaultValue: "Untitled Folder") {
            Swift.print("AndroidViewController, folder:", folderName)
            if (transferHandler.folderExists(folderName)) {
                AlertUtils.showAlert("Folder '\(folderName)' already exists!", info: "", confirm: false)
            } else {
                transferHandler.createAndroidFolder(folderName)
                refresh()
            }
        } else {
            Swift.print("AndroidViewController, no folder")
        }
    }
    
    func deleteFileDialog() {
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
        let deleteStringInDialog = (deleteItems.count > 1) ? "selected items" : deleteItems[0].fileName
        //        let selectedItem = self.androidDirectoryItems[fileTable.selectedRow]
        //        let selectedFileName = selectedItem.fileName
        if AlertUtils.showAlert("Do you really want to delete '\(deleteStringInDialog)'?", info: "", confirm: true) {
            LogI("Delete", deleteItems)
            transferHandler.deleteAndroid(deleteItems)
            refresh()
            successfulOperation()
        } else {
            LogV("Do not Delete!")
        }
    }
    
    internal func updateActiveDevice(_ activeDevice: AndroidDevice?) {
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
                    transferHandler.setUsingExternalStorage(false)
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
                self.updateDeviceStatus()
                self.hideProgress()
            }.subscribe(onNext: {
                // print("Result : ", devices)
                print("Complete!")
                if (NSObject.VERBOSE) {
                    Swift.print("AndroidViewController, update fin:" + TimeUtils.getCurrentTime());
                }
            })
    }
}
