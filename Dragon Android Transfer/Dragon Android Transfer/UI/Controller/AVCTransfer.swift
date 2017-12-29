//
//  AVCTransfer.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift

extension AndroidViewController {
    
    func copyFromAndroid(_ notification: Notification) {
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
    
    func copyFromMac(_ notification: Notification) {
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
    
    func pasteToAndroid(_ notification: Notification) {
        pasteToAndroidInternal(path: transferHandler.getCurrentPath())
    }
    
    func pasteToAndroidInternal(path: String) {
        print("Paste to Android")
        let files = transferHandler.getClipboardMacItems()
        if (files.count == 0) {
            if (NSObject.VERBOSE) {
                Swift.print("AndroidViewController, paste to android, Warning, NO ITEMS");
            }
            return
        } else {
            var i = 0
            var updateSizes = false
            while (i < files.count) {
                if (files[i].size == 0 || files[i].size == UInt64.max) {
                    updateSizes = true
                }
                i = i + 1
            }
            if (updateSizes) {
                transferHandler.updateSizes()
            }
        }
        copyDestination = path
        AppDelegate.isPastingOperation = true
        //		transferHandler.push(files, destination: path, delegate: self)
        
        Observable.just(transferHandler)
            .observeOn(bgScheduler)
            .subscribe(onNext: { transferHandler in
                transferHandler.push(files, destination: path)
            })
    }
    
    func pasteToMac(_ notification: Notification) {
        pasteToMacInternal(path: transferHandler.getActivePath())
    }
    
    func pasteToMacInternal(path: String) {
        print("Paste to Mac")
        let files = transferHandler.getClipboardAndroidItems()
        if (files.count == 0) {
            if (NSObject.VERBOSE) {
                Swift.print("AndroidViewController, paste to mac, Warning, NO ITEMS");
            }
            return
        }
        copyDestination = path
        AppDelegate.isPastingOperation = true
        Observable.just(transferHandler)
            .observeOn(bgScheduler)
            .subscribe(onNext: { transferHandler in
                transferHandler.pull(files, destination: path)
            })
    }
    
    func cancelTask() {
        if (NSObject.VERBOSE) {
            Swift.print("AndroidViewController, Cancel Active Task");
        }
        transferHandler.cancelActiveTask()
    }
    
    internal func observeTransfer() {
        transferHandler.hasActiveTask().skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { status in
                if (status == FileProgressStatus.kStatusInProgress) {
                    self.fileTable.layer?.borderWidth = 0
                    AppDelegate.isPastingOperation = true
                    self.overlayView.isHidden = false;
                    self.currentCopyFile = ""
                    self.showCopyDialog()
                    self.mDockProgress?.isHidden = false
                } else {
                    //						TODO:
                    self.finished(status)
                }
                self.mCurrentProgress = -1
            })
        //		TODO: Initially, do not call!
        transferHandler.sizeActiveTask().skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { totalSize in
                if (self.copyDialog != nil) {
                    self.copyDialog?.setTotalCopySize(totalSize)
                }
            })
        transferHandler.transferTypeActive().skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { value in
                if (self.copyDialog != nil) {
                    var transferTypeString = ""
                    if (value == TransferType.AndroidToMac) {
                        transferTypeString = "Copy From Android To Mac"
                    } else if (value == TransferType.MacToAndroid) {
                        transferTypeString = "Copy From Mac To Android"
                    }
                    self.transferType = value
                    print("Transfer Type:", transferTypeString)
                    self.copyDialog?.setTransferType(transferTypeString)
                }
            })
        transferHandler.fileActiveTask().skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { value in
                let fileName = value.fileName
                if (self.copyDialog != nil && self.currentCopyFile != fileName) {
                    //            currentCopyFile = fileName
                    var files: Array<BaseFile>?
                    if (self.transferType == TransferType.AndroidToMac) {
                        files = self.transferHandler.getClipboardAndroidItems()
                    } else if (self.transferType == TransferType.MacToAndroid) {
                        files = self.transferHandler.getClipboardMacItems()
                    }
                    var i = 0
                    print("Files:", files as Any!)
                    print("File Name:", fileName)
                    self.currentCopiedSize = 0
                    while (i < files!.count) {
                        if (fileName.contains(files![i].fileName)) {
                            self.currentFile = files![i]
                            self.currentCopyFile = self.currentFile!.fileName
                            break
                        }
                        self.currentCopiedSize = self.currentCopiedSize + files![i].size
                        i = i + 1
                    }
                    print("Update Current File:", self.currentCopyFile)
                    self.copyDialog?.setCurrentTransfer(self.currentCopyFile, to: self.copyDestination)
                }
            })
        transferHandler.progressActiveTask().skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { progress in
                self.progressActive(progress)
            })
        
        transferHandler.getSpaceStatus().skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { spaceStatus in
                if (spaceStatus.count < 2) {
                    return
                }
                self.spaceStatusText.stringValue = spaceStatus[0] + " of " + spaceStatus[1]
            })
    }
    
    internal func progressActive(_ progress: Double) {
        //		print("Progress Active: \(progress)")
        if (mCurrentProgress == progress) {
            return
        }
        mCurrentProgress = progress
        if (copyDialog != nil) {
            //			print("Current File: \(currentFile)")
            if (currentFile != nil) {
                //				print("Update Prog")
                let currentFileCopiedSize = UInt64(CGFloat(copyDialog!.mTotalCopySize) * (CGFloat(progress) / 100.0)) as UInt64
                copyDialog?.updateCopyStatus(currentFileCopiedSize, withProgress: CGFloat(progress))
            }
        }
        mDockProgress?.doubleValue = Double(progress)
        mDockTile.display()
    }
    
    internal func finished(_ status: FileProgressStatus) {
        AppDelegate.isPastingOperation = false
        print("Done!")
        
        print("End Time:", TimeUtils.getCurrentTime())
        
        if (status == FileProgressStatus.kStatusOk) {
            print("Successful copy")
            successfulOperation()
        } else {
            print("Canceled")
            //TODO: Sound if canceled.
        }
        //TODO: Copy of Marvel's Agents of Shield problem, not disappearing. & bad progress!
        overlayView.isHidden = true;
        if (copyDialog != nil) {
            //            copyDialog!.rootView.removeFromSuperview()
            copyDialog!.removeFromSuperview()
            copyDialog = nil
            currentFile = nil
        }
        mDockProgress?.isHidden = true
        mDockTile.display()
        refresh()
    }
}
