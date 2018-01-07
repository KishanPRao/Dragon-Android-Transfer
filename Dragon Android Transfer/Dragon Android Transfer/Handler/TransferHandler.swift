//
// Created by Kishan P Rao on 11/03/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TransferHandler {
	static let sharedInstance = TransferHandler();
	fileprivate var copyItemsAndroid: Variable<[BaseFile]> = Variable([])
	fileprivate var copyItemsMac: Variable<[BaseFile]> = Variable([])
//	private var clipboardItems: Array<BaseFile>? = []
	
	private let androidHandler = AndroidHandler()
	private let macHandler = MacHandler()
	
	func setDeviceNotificationDelegate(_ delegate: DeviceNotficationDelegate) {
		androidHandler.setDeviceNotificationDelegate(delegate)
	}
	
	func hasActiveDevice() -> Bool {
		return androidHandler.hasActiveDevice()
    }
	
    func observeAndroidDevices() -> Observable<[AndroidDevice]> {
        return androidHandler.observeAndroidDevices()
    }
    
    func observeActiveDevice() -> Observable<AndroidDevice?> {
        return androidHandler.observableActiveDevice.asObservable()
    }
	
	func setActiveDevice(_ device: AndroidDevice?) -> Bool {
		let result = self.androidHandler.setActiveDevice(device)
		self.clearClipboardAndroidItems()
		self.clearClipboardMacItems()
		return result
	}
	
	func getActiveDevice() -> AndroidDevice? {
		return self.androidHandler.getActiveDevice()
	}
	
	func observeFileList() -> Observable<[BaseFile]> {
		return androidHandler.observableFileList.asObservable()
	}
	
	func updateList(_ path: String, _ force: Bool = false) {
		androidHandler.updateList(path, force)
	}
	
	func navigateUpList() {
		androidHandler.navigateUpList()
	}
	
	func getInternalStorage() -> String {
		return androidHandler.getInternalStorage()
	}
	
	func setUsingExternalStorage(_ usingExternalStorage: Bool) {
		androidHandler.setUsingExternalStorage(usingExternalStorage)
	}
	
	func updateStorage() {
		self.androidHandler.updateStorage()
	}
	
	func getSpaceStatus() -> Observable<[String]> {
		return androidHandler.getSpaceStatus()
	}
	
	func getExternalStorage() -> String {
		return androidHandler.getExternalStorage()
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
	
	func terminate() {
		androidHandler.terminate()
	}
	
	/*func isDirectory(_ fileName: String) -> Bool {
		return androidHandler.isDirectory(fileName)
	}*/
	
	func getCurrentPath() -> String {
		return androidHandler.getCurrentPath()
    }
    
    func getCurrentPathFile() -> BaseFile {
        return androidHandler.getCurrentPathFile()
    }
	
	func pull(_ sourceFiles: Array<BaseFile>, destination: String) {
		androidHandler.pull(sourceFiles, destination: destination)
	}
	func hasActiveTask() -> Observable<FileProgressStatus> {
		return androidHandler.hasActiveTask.asObservable()
	}
	
	func sizeActiveTask() -> Observable<UInt64> {
		return androidHandler.sizeActiveTask.asObservable()
	}
	
	func transferTypeActive() -> Observable<Int> {
		return androidHandler.transferTypeActive.asObservable()
	}
	
	func fileActiveTask() -> Observable<BaseFile> {
		return androidHandler.fileActiveTask.asObservable()
	}
	
	func progressActiveTask() -> Observable<Double> {
		return androidHandler.progressActiveTask.asObservable()
	}
	
	func push(_ sourceFiles: Array<BaseFile>, destination: String) {
		androidHandler.push(sourceFiles, destination: destination)
    }
    
    func getCurrentPathForDisplay() -> String {
        return androidHandler.getCurrentPathForDisplay()
    }
	
	func isRootDirectory() -> Bool {
		return androidHandler.isRootDirectory()
	}
	
	func reset() {
		androidHandler.reset()
	}
    
    func observeCurrentPath() -> Observable<String> {
        return androidHandler.observableCurrentPath.asObservable()
    }
    
    func observeClipboardAndroidItems() -> Observable<[BaseFile]> {
        return copyItemsAndroid.asObservable()
    }
	
	func getClipboardAndroidItems() -> [BaseFile] {
		return copyItemsAndroid.value
	}
	
	let EmptyList = [BaseFile]()
	
	func clearClipboardAndroidItems() {
		copyItemsAndroid.value = EmptyList
	}
	
	func updateClipboardAndroidItems(_ items: Array<BaseFile>) {
		copyItemsAndroid.value = items
	}
	
	func cancelActiveTask() {
		androidHandler.cancelActiveTask()
	}
	
	func updateAndroidFileSize(file: BaseFile, closure: @escaping () -> ()) {
		self.androidHandler.updateSize(file: file)
		closure()
	}
	
	func createAndroidFolder(_ folderName: String) {
		androidHandler.createNewFolder(folderName);
	}
	
	func folderExists(_ folderName: String) -> Bool {
		return androidHandler.folderExists(folderName);
	}
    
    func deleteAndroid(_ files: Array<BaseFile>) {
        androidHandler.delete(files)
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
	
	func observeClipboardMacItems() -> Observable<[BaseFile]> {
		return copyItemsMac.asObservable()
	}
	
	func getClipboardMacItems() -> [BaseFile] {
		return copyItemsMac.value
	}
	
	func clearClipboardMacItems() {
		copyItemsMac.value = EmptyList
	}
	
	func updateClipboardMacItems(_ items: Array<BaseFile>) {
		copyItemsMac.value = items
	}

//	Cross
	func updateSizes() {
		if (getClipboardAndroidItems().count > 0) {
			androidHandler.updateSizes(getClipboardAndroidItems())
		} else {
			macHandler.updateSizes(getClipboardMacItems())
		}
	}

//	TODO: Use this every time in UI
	func getClipboardItems() -> Array<BaseFile> {
		if (getClipboardAndroidItems().count > 0) {
			return getClipboardAndroidItems()
		} else {
			return getClipboardMacItems()
		}
	}
	
	func isFirstLaunch() -> Bool {
		return androidHandler.isFirstLaunch()
	}
	
    func initializeAndroid(_ data: Data) {
//		TODO: Loading indeterminate progress?
		androidHandler.initialize(data)
	}
}
