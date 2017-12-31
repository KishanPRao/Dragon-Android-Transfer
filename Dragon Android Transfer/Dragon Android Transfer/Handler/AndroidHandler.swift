//
//  AndroidHandler.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/16.
//  Copyright © 2016 Kishan P Rao. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/*
 Stores State of Android Devices. Sends approp info to UI.
 */
public class AndroidHandler: NSObject {
	override class var VERBOSE: Bool {
		return true
	}
	let EXTREME_VERBOSE = false
	let TIMER_VERBOSE = false
//    let DEVICE_UPDATE_DELAY = 0.01
	let DEVICE_UPDATE_DELAY = 1
	// let DEVICE_UPDATE_DELAY = 0.1
	
	let BLOCK_SIZE_IN_FLOAT = Float(1024)
	
	fileprivate var adbDirectoryPath: String = ""
	fileprivate var adbLaunchPath: String = ""
	
	fileprivate var currentPath: String = ""
	fileprivate var timer: Timer? = nil
	fileprivate var activeDevice: AndroidDevice? = nil
    
    let observableActiveDevice = Variable<AndroidDevice?>(nil)
    
	
	fileprivate var deviceNotificationDelegate: DeviceNotficationDelegate? = nil
	
	fileprivate var devicesUpdating: Bool = false
	fileprivate var active: Bool = true
    
    private var storageItems = [StorageItem]()
	
	fileprivate var externalStorage: String = ""
	fileprivate var internalStorage: String = "/sdcard"
	fileprivate var totalSpaceInString: String = ""
	
	fileprivate var usingExternalStorage = false
	
	fileprivate lazy var adbHandler: AndroidAdbHandler = {
		return AndroidAdbHandler(directory: self.adbDirectoryPath)
	}()
	
	override init() {
		currentPath = ""
		adbLaunchPath = "/bin/bash"
	}
	
	func initialize(_ data: Data) {
		adbDirectoryPath = self.extractAdbAsset(data)
		LogV("Initialize")
	}
	
	func isFirstLaunch() -> Bool {
		let resourcePath = Bundle.main.resourcePath!
		let fileManager = FileManager.default
		return !(fileManager.fileExists(atPath: resourcePath + "/adb"))
	}
	
	func extractAdbAsset(_ data: Data) -> String {
		let resourcePath = Bundle.main.resourcePath!
		if (!isFirstLaunch()) {
			return resourcePath
		}
		let fileManager = FileManager.default
		let fileExists = fileManager.fileExists(atPath: resourcePath + "/adb")
		print("AndroidHandler, file Exists:", fileExists)
//		let data = NSDataAsset.init(name: "adb")?.data
		let filePath = resourcePath + "/adb"
		
		fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
		bashShell("cd \"" + resourcePath + "\"; ls; chmod a+x adb;")
		print("Path:", resourcePath)
		if (Verbose) {
			do {
				print("Contents:", try FileManager.default.contentsOfDirectory(atPath: resourcePath))
			} catch {
				print(error)
			}
		}
		return resourcePath
	}
	
	func setDeviceNotificationDelegate(_ delegate: DeviceNotficationDelegate) {
		deviceNotificationDelegate = delegate
	}
	
	fileprivate var observableAndroidDevices: Variable<[AndroidDevice]> = Variable([])
	
	func observeAndroidDevices() -> Observable<[AndroidDevice]> {
		return observableAndroidDevices.asObservable()
	}
	
	func start() {
		self.adbDevicesTimer()
		if (timer != nil) {
			timer?.invalidate()
			timer = nil
		}
		
		timer = Timer.scheduledTimer(timeInterval: TimeInterval(DEVICE_UPDATE_DELAY), target: self, selector: #selector(AndroidHandler.adbDevicesTimer), userInfo: nil, repeats: true)
		RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
//        active = true;
	}
	
	func stop() {
//        print("Stop")
//        objc_sync_enter(self)
//        active = false
//        objc_sync_exit(self)
		if (timer != nil) {
			timer?.invalidate()
			timer = nil
		}
	}
	
	func terminate() {
		cancelActiveTask()
		stop()
	}
	
	@objc func adbDevicesTimer() {
		let qualityOfServiceClass = DispatchQoS.QoSClass.background
		let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
		backgroundQueue.async(execute: {
			self.adbDevices()
		})
	}
	
    /*
	fileprivate func getExternalStorageDirectories() -> Array<String> {
		return activeDevice!.externalStorages
	}*/
	
	func hasActiveDevice() -> Bool {
		return (activeDevice != nil)
	}
	
	func setActiveDevice(_ device: AndroidDevice?) {
		activeDevice = device;
		LogV("Active Device:", activeDevice)
		if (activeDevice != nil) {
			adbHandler.device = activeDevice
			let externalDirectories = activeDevice!.storages
			print("External Directories:", externalDirectories)
			if (externalDirectories.count > 1) {
				externalStorage = externalDirectories[1].location
			} else {
				externalStorage = ""
			}
		} else {
			externalStorage = ""
		}
        observableActiveDevice.value = activeDevice
	}
	
	func setUsingExternalStorage(_ usingExternalStorage: Bool) {
		self.usingExternalStorage = usingExternalStorage
	}
	
	func isUsingExternalStorage() -> Bool {
		return usingExternalStorage;
	}
	
	func reset() {
		currentPath = ""
	}
	
	private func exists(_ filePath: String, isFile: Bool) -> Bool {
		return adbHandler.fileExists(filePath, withFileType: isFile)
	}
	
	func fileExists(_ name: String) -> Bool {
		return exists(currentPath + HandlerConstants.SEPARATOR + name, isFile: true)
	}
	
	func folderExists(_ name: String) -> Bool {
		return exists(currentPath + HandlerConstants.SEPARATOR + name, isFile: false)
	}
	
	func createNewFolder(_ folderName: String) {
		adbHandler.createNewFolder(currentPath + HandlerConstants.SEPARATOR + folderName)
//		TODO: Need check? Success?
	}
	
	func delete(_ files: Array<BaseFile>) {
		for file in files {
			// let command = "rm -rf " + escapeDoubleQuotes + file.getFullPath() + escapeDoubleQuotes
			// LogV("Delete", file, command)
			// let _ = adbShell(command)
			print("Delete, \(file.getFullPath())")
			// TODO: TEST!!!
			adbHandler.deleteFile(file.getFullPath())
		}
	}
	
	/* Available, Total */
	var spaceStatus = Variable<[String]>([])
	
	func getSpaceStatus() -> Observable<[String]> {
		return spaceStatus.asObservable()
	}
	
	func updateStorage() {
		var spaceStatus = [String]()
		spaceStatus.append(adbHandler.getAvailableSpace(currentPath))
		spaceStatus.append(adbHandler.getTotalSpace(currentPath))
		self.spaceStatus.value = spaceStatus
	}
	
	func getExternalStorage() -> String {
		return externalStorage
	}
	
	func getInternalStorage() -> String {
		return internalStorage
	}
	
	fileprivate func getSize(_ filePath: String) -> UInt64 {
		return adbHandler.getFileSize(filePath)
	}
	
	func adbDevices() {
		if (TIMER_VERBOSE) {
			print("Try Enter:", TimeUtils.getCurrentTime())
		}
		objc_sync_enter(self)
		let newDevices = adbHandler.getDevices()
		let same = containSameElements(newDevices, array2: self.observableAndroidDevices.value)
		if (TIMER_VERBOSE) {
			LogV("Same: \(same)")
		}
		if (!same) {
			Swift.print("Androidhandler, Main:", ThreadUtils.isMainThread())
			self.observableAndroidDevices.value = newDevices
		}
		
		objc_sync_exit(self)
		if (TIMER_VERBOSE) {
			print("Release Lock:", TimeUtils.getCurrentTime())
		}
	}
	
	func containSameElements(_ array1: Array<AndroidDevice>, array2: Array<AndroidDevice>) -> Bool {
//        print("Ele:", array1, " Ele2:", array2)
		guard array1.count == array2.count else {
			return false // No need to sorting if they already have different counts
		}
		var copyArray1 = Array(array1)
		copyArray1.sort { (device1, device2) -> Bool in
			device1.name < device2.name
		}
		var copyArray2 = Array(array2)
		copyArray2.sort { (device1, device2) -> Bool in
			device1.name < device2.name
		}
		var i = 0
		while i < copyArray1.count {
			if copyArray1[i].name != copyArray2[i].name {
				return false
			}
			i = i + 1
		}
		return true
	}

//	func isFileTypeString(str: String) -> Bool {
//		return str.contains(HandlerConstants.DIRECTORY) || str.contains(HandlerConstants.FILE);
//	}

	let observableFileList = Variable<[BaseFile]>([])
	
	func updateList(_ path: String) {
		currentPath = path
		adbHandler.device = activeDevice
		observableFileList.value =  adbHandler.getDirectoryListing(path)
	}
	
	func updateSizes(_ files: Array<BaseFile>) {
		var i = 0;
		while i < files.count {
			updateSize(file: files[i])
			i = i + 1
		}
		if (Verbose) {
			print("AndroidHandler, Sizes:", files);
		}
	}
	
	func updateSize(file: BaseFile) {
		let filePath = file.path + HandlerConstants.SEPARATOR + file.fileName
		var size: UInt64
		if (file.type == BaseFileType.Directory) {
			size = getSize(filePath)
		} else {
			size = getSize(filePath)
		}
		
		file.size = size
		if (Verbose) {
			print("AndroidHandler, Sizes:", file);
		}
	}
	
	func isRootDirectory() -> Bool {
		var path = currentPath
		let containsSep = path.contains(HandlerConstants.SEPARATOR)
		var isRoot = true
		if (containsSep) {
			let lastSep = (path.range(of: HandlerConstants.SEPARATOR, options: NSString.CompareOptions.backwards)?.lowerBound)!
			path = path.substring(to: lastSep)
			if (usingExternalStorage) {
				if (!(path.characters.count < externalStorage.characters.count)) {
					isRoot = false
				}
			} else {
				if (!(path.characters.count < internalStorage.characters.count)) {
					isRoot = false
				}
			}
		}
		if (Verbose) {
			print("AndroidHandler, isRootDirectory path:", currentPath);
			print("AndroidHandler, isRootDirectory:", isRoot);
		}
		return isRoot
	}
	
	func navigateUpList()  {
		let containsSep = currentPath.contains(HandlerConstants.SEPARATOR)
		print("Contains:", containsSep)
		if (containsSep) {
			let lastSep = (currentPath.range(of: HandlerConstants.SEPARATOR, options: NSString.CompareOptions.backwards)?.lowerBound)!
			currentPath = currentPath.substring(to: lastSep)
//			if (Verbose) { print("Upper:", currentPath) }
			if (usingExternalStorage) {
				if (currentPath.characters.count < externalStorage.characters.count) {
					currentPath = externalStorage
				}
			} else {
				if (currentPath.characters.count < internalStorage.characters.count) {
					currentPath = internalStorage
				}
			}
			
			if (Verbose) {
				print("Upper Path:", currentPath)
			}
			updateList(currentPath)
		}
	}
	
	// TODO: Keep if used later!
	// func isDirectory(_ fileName: String) -> Bool {
	// 	let directory = currentPath;
	// 	let commands = "cd " + escapeDoubleQuotes + directory + escapeDoubleQuotes + "; [ -d " + escapeDoubleQuotes + directory + HandlerConstants.SEPARATOR + fileName + escapeDoubleQuotes + " ] && echo \"" + HandlerConstants.DIRECTORY + "\";";
	// 	let output = adbShell(commands);
	// 	let isDir = output.contains(HandlerConstants.DIRECTORY)
	// 	if (Verbose) {
	// 		print("Dir?", directory + HandlerConstants.SEPARATOR + fileName, isDir, output, commands)
	// 	}
	// 	return isDir;
	// }
	
	func getCurrentPath() -> String {
		return currentPath
	}
	
	func getCurrentPathFile() -> BaseFile {
		let path = getCurrentPath().stringByDeletingLastPathComponent + HandlerConstants.SEPARATOR
		let name = getCurrentPath().lastPathComponent
		return BaseFile.init(fileName: name, path: path, type: BaseFileType.Directory, size: 0)
	}
	
	func getCurrentPathForDisplay() -> String {
		var inString = internalStorage;
		var outString = "Internal Storage";
		if (usingExternalStorage) {
			inString = externalStorage
			outString = "External Storage";
		}
		return currentPath.replacingOccurrences(of: inString, with: outString)
	}
	
	// TODO: Move this out next, Adb Initializer. All Observables. Active task logic.
	fileprivate func bashShell(_ commands: String) {
		let task = Process()
		task.launchPath = "/bin/bash"
		task.arguments = ["-l", "-c", commands]
		
		let pipe = Pipe()
		task.standardOutput = pipe
		
		task.launch()
		
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
		if (Verbose) {
			print("Args:", commands, ":")
		}
		if (Verbose) {
			print("Op:", output!)
		}
		
		task.waitUntilExit()
	}
	
	/* Transfer Specific */
	static let EmptyFile = BaseFile(fileName: "", path: "", type: 0, size: 0)
	
	var hasActiveTask = Variable<FileProgressStatus>(FileProgressStatus.kStatusInProgress)
	var sizeActiveTask = Variable<UInt64>(0)
	var transferTypeActive = Variable<Int>(TransferType.AndroidToMac)
	var fileActiveTask = Variable<BaseFile>(EmptyFile)
	var progressActiveTask = Variable<Double>(0.0)
	
	fileprivate var startedTask: Bool = false
	
	private var filesIterator: IndexingIterator<[BaseFile]>?
	private var previousSizeTask = 0 as UInt64
	private var totalItems = 0 as Int
	private var currentFile: BaseFile?
	
	typealias TransferBlockType = (Int, AdbExecutionResultWrapper) -> Void
	lazy var transferBlock: TransferBlockType = { progress, result in
//				print("Pull: \(progress), \(result)")
		if (result == AdbExecutionResultWrapper.Result_Ok) {
			print("Completed!")
			let previousFile = self.currentFile
			let currentFile = self.filesIterator!.next()
			if (currentFile == nil) {
				print("Done Exec!")
				self.hasActiveTask.value = FileProgressStatus.kStatusOk
			} else {
				self.previousSizeTask += previousFile!.size
//				print("Prev Size: \(self.previousSizeTask), total: \(self.sizeActiveTask.value)")
			}
			self.currentFile = currentFile
		} else if (result == AdbExecutionResultWrapper.Result_InProgress) {
			let totalSize = Double(self.sizeActiveTask.value)
			let previousProgress = (Double(self.previousSizeTask) / totalSize) * 100.0
			let currentProgress = (Double(progress) / Double(self.totalItems))
//			print("Prev: \(previousProgress), curr: \(currentProgress)")
			self.progressActiveTask.value = previousProgress + currentProgress 
		} else if (result == AdbExecutionResultWrapper.Result_Canceled) {
			print("Canceled")
			self.hasActiveTask.value = FileProgressStatus.kStatusCanceled
		}
	};

	func push(_ sourceFiles: Array<BaseFile>, destination: String) {
		print("Pushing: \(sourceFiles) to \(destination)")
		cancelTask = false
		previousSizeTask = 0
		hasActiveTask.value = FileProgressStatus.kStatusInProgress
		if (activeDevice != nil) {
			startedTask = false
			totalItems = sourceFiles.count
			var size = 0 as UInt64
			filesIterator = sourceFiles.makeIterator()
			var sourceFileName = ""
			while let file = filesIterator!.next() {
				sourceFileName = file.path + HandlerConstants.SEPARATOR + file.fileName
//				TODO: Worst case!
//				if ((file.size == 0 || file.size == UInt64.max) && file.type == BaseFileType.Directory) {
//					file.size = getSize(sourceFileName)
//				}
				size = size + file.size
			}
			sizeActiveTask.value = size
			transferTypeActive.value = TransferType.MacToAndroid
			filesIterator = sourceFiles.makeIterator()
			currentFile = self.filesIterator!.next()
			self.fileActiveTask.value = currentFile!
			
			print("------Start Time:", TimeUtils.getCurrentTime())
			startedTask = true
			
			while let file = currentFile {
				if (cancelTask) {
					print("Task Canceled")
					break
				}
				self.fileActiveTask.value = file
				sourceFileName = file.path + HandlerConstants.SEPARATOR + file.fileName
				adbHandler.push(sourceFileName, toDestination: destination, transferBlock)
				print("After Single Push!")
			}
			print("After Push!")
		} else {
			print("Warning, no active")
		}
	}

	func pull(_ sourceFiles: Array<BaseFile>, destination: String) {
		print("Pulling: \(sourceFiles) to \(destination)")
		cancelTask = false
		previousSizeTask = 0
		hasActiveTask.value = FileProgressStatus.kStatusInProgress
		if (activeDevice != nil) {
			startedTask = false
			totalItems = sourceFiles.count
			filesIterator = sourceFiles.makeIterator()
			var size = 0 as UInt64
			var sourceFileName = ""
			while let file = filesIterator!.next() {
				sourceFileName = file.path + HandlerConstants.SEPARATOR + file.fileName
				if ((file.size == 0 || file.size == UInt64.max) && file.type == BaseFileType.Directory) {
					file.size = getSize(sourceFileName)
				}
				size = size + file.size
			}
			sizeActiveTask.value = size
			transferTypeActive.value = TransferType.AndroidToMac
			filesIterator = sourceFiles.makeIterator()
			currentFile = self.filesIterator!.next()
			self.fileActiveTask.value = currentFile!
			
			print("------Start Time:", TimeUtils.getCurrentTime())
			
			startedTask = true
//			adbHandler.pull("/sdcard/Android/app.apk", toDestination: "/Users/kishanprao/Test/") {  progress, result in
			while let file = currentFile {
				if (cancelTask) {
					print("Task Canceled")
					break
				}
				self.fileActiveTask.value = file
				sourceFileName = file.path + HandlerConstants.SEPARATOR + file.fileName
				adbHandler.pull(sourceFileName, toDestination: destination, transferBlock)
				print("After Single Pull!")
			}
			print("After Pull!")
		} else {
			print("Warning, No active device")
		}
	}
	
//	TODO: Probably can use status
	var cancelTask = false
	
	func cancelActiveTask() {
		if (startedTask) {
			cancelTask = true
			print("Cancel Active Task")
			adbHandler.cancelActiveTask()
		} else {
			if (Verbose) {
				print("AndroidHandler, Warning, Task not Started!");
			}
		}
		cancelTask = true
	}
}
