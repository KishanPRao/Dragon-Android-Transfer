//
// Created by Kishan P Rao on 11/03/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class TransferHandler {
	static let sharedInstance = TransferHandler();
	fileprivate var copyItemsAndroid: Array<BaseFile>? = []
	fileprivate var copyItemsMac: Array<BaseFile> = []
//	private var clipboardItems: Array<BaseFile>? = []
	
	fileprivate let androidHandler = AndroidHandler()
	fileprivate let macHandler = MacHandler()
	
	func setDeviceNotificationDelegate(_ delegate: DeviceNotficationDelegate) {
		androidHandler.setDeviceNotificationDelegate(delegate)
	}
	
	func hasActiveDevice() -> Bool {
		return androidHandler.hasActiveDevice()
	}
	
	func getAndroidDevices() -> Array<AndroidDevice> {
		return androidHandler.getAndroidDevices()
	}
	
	func setActiveDevice(_ device: AndroidDevice?) {
		androidHandler.setActiveDevice(device)
		copyItemsMac.removeAll()
		copyItemsAndroid?.removeAll()
	}
	
	func openDirectoryData(_ path: String) -> Array<BaseFile>! {
		return androidHandler.openDirectoryData(path)
	}
	
	func getInternalStorage() -> String {
		return androidHandler.getInternalStorage()
	}
	
	func setUsingExternalStorage(_ usingExternalStorage: Bool) {
		androidHandler.setUsingExternalStorage(usingExternalStorage)
	}
	
	func updateStorage() {
		androidHandler.updateStorage()
	}
	
	func getExternalStorage() -> String {
		return androidHandler.getExternalStorage()
	}
	
	func getAvailableSpace() -> String {
		return androidHandler.getAvailableSpace()
	}
	
	func getTotalSpace() -> UInt64 {
		return androidHandler.getTotalSpace()
	}
	
	func getTotalSpaceInString() -> String {
		return androidHandler.getTotalSpaceInString()
	}
	
	func isUsingExternalStorage() -> Bool {
		return androidHandler.isUsingExternalStorage()
	}
	
	func start() {
		androidHandler.start()
	}
	
	func stop() {
		androidHandler.stop()
	}
	
	func release() {
		androidHandler.release()
	}
	
	func isDirectory(_ fileName: String) -> Bool {
		return androidHandler.isDirectory(fileName)
	}
	
	func getCurrentPath() -> String {
		return androidHandler.getCurrentPath()
	}
	
	func pull(_ sourceFiles: Array<BaseFile>, destination: String, delegate: FileProgressDelegate) {
		androidHandler.pull(sourceFiles, destination: destination, delegate: delegate)
	}
	
	func push(_ sourceFiles: Array<BaseFile>, destination: String, delegate: FileProgressDelegate) {
		androidHandler.push(sourceFiles, destination: destination, delegate: delegate)
	}
	
	func getCurrentPathForDisplay() -> String {
		return androidHandler.getCurrentPathForDisplay()
	}
	
	func isRootDirectory() -> Bool {
		return androidHandler.isRootDirectory()
	}
	
	func upDirectoryData() -> Array<BaseFile>! {
		return androidHandler.upDirectoryData()
	}
	
	func reset() {
		androidHandler.reset()
	}
	
	func getClipboardAndroidItems() -> Array<BaseFile>? {
		return copyItemsAndroid
	}
	
	func clearClipboardAndroidItems() {
		copyItemsAndroid?.removeAll()
	}
	
	func updateClipboardAndroidItems(_ items: Array<BaseFile>?) {
		copyItemsAndroid = items
	}
	
	func cancelActiveTask() {
		androidHandler.cancelActiveTask()
	}
	
	func updateAndroidFileSize(file: BaseFile) {
		androidHandler.updateSize(file: file)
	}

//	Mac Related
	func isFinderActive() -> Bool {
		return macHandler.isFinderActive()
	}
	
	func getActiveFiles() -> Array<BaseFile>! {
		return macHandler.getActiveFiles()
	}
	
	func getActivePath() -> String {
		return macHandler.getActivePath()
	}
	
	func getClipboardMacItems() -> Array<BaseFile> {
		return copyItemsMac
	}
	
	func clearClipboardMacItems() {
		copyItemsMac.removeAll()
	}
	
	func updateClipboardMacItems(_ items: Array<BaseFile>) {
		copyItemsMac = items
	}

//	Cross
	func updateSizes() {
		if (copyItemsAndroid!.count > 0) {
			androidHandler.updateSizes(copyItemsAndroid!)
		} else {
			macHandler.updateSizes(copyItemsMac)
		}
	}

//	TODO: Use this every time in UI
	func getClipboardItems() -> Array<BaseFile>? {
		if (copyItemsAndroid!.count > 0) {
			return copyItemsAndroid
		} else {
			return copyItemsMac
		}
	}
	
	func isFirstLaunch() -> Bool {
		return androidHandler.isFirstLaunch()
	}
	
	func initializeAndroid() {
		androidHandler.initialize()
	}
}
