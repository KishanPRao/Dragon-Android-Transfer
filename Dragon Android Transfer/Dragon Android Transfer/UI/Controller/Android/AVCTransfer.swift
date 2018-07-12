//
//  AVCTransfer.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift

@objc extension AndroidViewController {
    
    @objc func copyFromAndroid(_ notification: Notification) {
        print("Copy From Android")
        print("Selected", fileTable.selectedRowIndexes)
        let indexSet = fileTable.selectedRowIndexes
        var currentIndex = indexSet.first
        transferHandler.clearClipboardMacItems()
        transferHandler.clearClipboardAndroidItems()
        var copyItemsAndroid: Array<BaseFile> = []
        //        Swift.print("Index:", currentIndex)
        //        Swift.print("Index:", indexSet)
        //        Swift.print("Index:", indexSet.first)
        
        while (currentIndex != nil && currentIndex != NSNotFound) {
            let currentItem = androidDirectoryItems[currentIndex!];
            copyItemsAndroid.append(currentItem)
            print("Current Index:", currentIndex!, " Item:", currentItem.fileName)
            currentIndex = indexSet.integerGreaterThan(currentIndex!)
        }
        print("Copy:", copyItemsAndroid)
        transferHandler.updateClipboardAndroidItems(copyItemsAndroid)
    }
    
    @objc func copyFromMac(_ notification: Notification) {
        print("Copy From Mac", TimeUtils.getCurrentTime())
        var copyItemsMac: Array<BaseFile> = []
        if (transferHandler.isFinderActive()) {
            transferHandler.clearClipboardMacItems()
            transferHandler.clearClipboardAndroidItems()
            copyItemsMac = transferHandler.getActiveFiles()
            print("Copy:", copyItemsMac, TimeUtils.getCurrentTime())
            transferHandler.updateClipboardMacItems(copyItemsMac)
        } else {
            print("Warning, inactive Finder")
        }
    }
    
    func observeTransfer() {
        transferHandler.activeTaskStatus()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { status in
                self.LogV("Status: \(status)")
                if (status == FileProgressStatus.kStatusInProgress) {
                    self.fileTable.enableDrag = false
                } else {
                    self.fileTable.enableDrag = true
                }
            }).disposed(by: disposeBag)
    }
}
