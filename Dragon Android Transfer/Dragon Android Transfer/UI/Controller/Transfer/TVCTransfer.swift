//
//  TVCTransfer.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 05/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift

extension TransferViewController {
	
	func pasteToAndroid(_ path: String) {
		let files = transferHandler.getClipboardMacItems()
		if (files.count == 0) {
			if (NSObject.VERBOSE) {
				Swift.print("Paste to android, Warning, NO ITEMS");
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
		AppDelegate.isPastingOperation.value = true
		
		Observable.just(transferHandler)
				.observeOn(bgScheduler)
				.subscribe(onNext: { transferHandler in
					transferHandler.push(files, destination: path)
				})
	}
	
	func pasteToMac(_ path: String) {
		print("Paste to Mac")
		let files = transferHandler.getClipboardAndroidItems()
		if (files.count == 0) {
			if (NSObject.VERBOSE) {
				Swift.print("Paste to mac, Warning, NO ITEMS");
			}
			return
		}
		copyDestination = path
		AppDelegate.isPastingOperation.value = true
		Observable.just(transferHandler)
				.observeOn(bgScheduler)
				.subscribe(onNext: { transferHandler in
					transferHandler.pull(files, destination: path)
				})
	}
	
	func cancelTask() {
		if (NSObject.VERBOSE) {
			Swift.print("Cancel Active Task");
		}
		transferHandler.cancelActiveTask()
	}
	
	internal func observeTransfer() {
		transferHandler.hasActiveTask().skip(1)
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { status in
					if (status == FileProgressStatus.kStatusInProgress) {
//                    self.fileTable.layer?.borderWidth = 0
						AppDelegate.isPastingOperation.value = true
//                    self.showCopyDialog()
						self.mDockProgress?.isHidden = false
					} else {
						//                        TODO:
						self.finished(status)
					}
					self.mCurrentProgress = -1
				})
		
		transferHandler.sizeActiveTask().skip(1)
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { totalSize in
					self.totalSize = totalSize
//                if (self.copyDialog != nil) {
//                    self.copyDialog?.setTotalCopySize(totalSize)
//                }
				})
		transferHandler.transferTypeActive().skip(1)
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { value in
//                if (self.copyDialog != nil) {
					var transferTypeString = ""
					if (value == TransferType.AndroidToMac) {
						transferTypeString = "Copy From Android To Mac"
					} else if (value == TransferType.MacToAndroid) {
						transferTypeString = "Copy From Mac To Android"
					}
					self.transferType = value
					print("Transfer Type:", transferTypeString)
					self.updateTransferState()
//                    self.copyDialog?.setTransferType(transferTypeString)
//                }
				})
		transferHandler.fileActiveTask().skip(1)
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { value in
					let fileName = value.fileName
					if (/*self.copyDialog != nil && */ self.currentCopyFile != fileName) {
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
//                    self.copyDialog?.setCurrentTransfer(self.currentCopyFile, to: self.copyDestination)
						//        pathTransferSize.stringValue = copiedSizeInString + " of " + SizeUtils.getBytesInFormat(totalSize)
						let range = NSMakeRange(self.currentCopyFile.count, 4)
						let pathTransferStringValue = self.currentCopyFile + " to " + self.copyDestination
						let attributedString: NSAttributedString
						attributedString = TextUtils.attributedString(
								from: pathTransferStringValue,
								color: R.color.transferTextColor,
								nonBoldRange: range)
						attributedString.boundingRect(with: NSSize(width: 300, height: 50), options: (
								//NSStringDrawingOptions.usesLineFragmentOrigin
								NSStringDrawingOptions.usesFontLeading
						))
						self.pathTransferString.attributedStringValue = attributedString
						
					}
				})
		transferHandler.progressActiveTask().skip(1)
				.observeOn(MainScheduler.instance)
				.subscribe(onNext: { progress in
					self.progressActive(progress)
				})
	}
	
	
	internal func progressActive(_ progress: Double) {
		//        print("Progress Active: \(progress)")
		if (mCurrentProgress == progress) {
			return
		}
		mCurrentProgress = progress
		//            print("Current File: \(currentFile)")
		//                print("Update Prog")
		let copiedSize = UInt64(CGFloat(totalSize) * (CGFloat(progress) / 100.0)) as UInt64
//        copyDialog?.updateCopyStatus(currentFileCopiedSize, withProgress: CGFloat(progress))
		transferProgressView.setProgress(CGFloat(progress))
		
		let copiedSizeInString = SizeUtils.getBytesInFormat(copiedSize)
//        pathTransferSize.stringValue = copiedSizeInString + " of " + SizeUtils.getBytesInFormat(totalSize)
		let range = NSMakeRange(copiedSizeInString.count, 4)
		pathTransferSize.attributedStringValue = TextUtils.attributedString(
				from: copiedSizeInString + " of " + SizeUtils.getBytesInFormat(totalSize),
				color: R.color.transferTextColor,
				nonBoldRange: range)
		
		mDockProgress?.doubleValue = Double(progress)
		mDockTile.display()
	}
	
	
	internal func finished(_ status: FileProgressStatus) {
		AppDelegate.isPastingOperation.value = false
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
		
		mDockProgress?.isHidden = true
		mDockTile.display()
		if (transferType == TransferType.MacToAndroid) {
			refresh()
		}
		if let alert = alert {
			alert.end()
		}
		exit()
	}
}
