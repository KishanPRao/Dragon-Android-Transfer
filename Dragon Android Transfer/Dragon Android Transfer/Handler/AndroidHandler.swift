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
public class AndroidHandler: VerboseObject {
	/*override class var VERBOSE: Bool {
		return true
	}*/
	let EXTREME_VERBOSE = false
	let TIMER_VERBOSE = false
//    let DEVICE_UPDATE_DELAY = 0.01
	let DEVICE_UPDATE_DELAY = 1
	// let DEVICE_UPDATE_DELAY = 0.1
	
	let BLOCK_SIZE_IN_FLOAT = Float(1024)
	
	fileprivate var adbDirectoryPath: String = ""
	fileprivate var adbLaunchPath: String = ""
	
	fileprivate var currentPath: String = ""
//    fileprivate var timer: Timer? = nil
    var timer: DispatchSourceTimer? = nil

	fileprivate var activeDevice: AndroidDeviceMac? = nil
    
    let observableActiveDevice = Variable<AndroidDeviceMac?>(nil)
    
	
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
    
    let observableCurrentPath = Variable<String>("")
	
	override init() {
		currentPath = ""
		adbLaunchPath = "/bin/bash"
	}
	
	func initialize(_ data: Data) {
        //        TODO: Bg Thread!
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
	
	fileprivate var observableAndroidDevices: Variable<[AndroidDeviceMac]> = Variable([])
	
	func observeAndroidDevices() -> Observable<[AndroidDeviceMac]> {
		return observableAndroidDevices.asObservable()
	}
	
	func getActiveDevice() -> AndroidDeviceMac? {
		return observableActiveDevice.value
	}
	
	func start() {
//        self.adbDevicesTimer()
		if (timer != nil) {
			timer?.cancel()
			timer = nil
		}
        
        let queue = DispatchQueue.global(qos: .background)
        timer = DispatchSource.makeTimerSource(queue: queue)
        guard let timer = timer else {return}
        
        timer.scheduleRepeating(deadline: .now(), interval: .seconds(DEVICE_UPDATE_DELAY), leeway: .seconds(1))
        timer.setEventHandler(handler: {
            self.adbDevices()
        })
        timer.resume()
		
//        timer = Timer.scheduledTimer(timeInterval: TimeInterval(DEVICE_UPDATE_DELAY), target: self, selector: #selector(AndroidHandler.adbDevicesTimer), userInfo: nil, repeats: true)
//        RunLoop.main.add(timer!, forMode: RunLoopMode.commonModes)
//        active = true;
	}
	
	func stop() {
//        print("Stop")
//        objc_sync_enter(self)
//        active = false
//        objc_sync_exit(self)
		if (timer != nil) {
			timer?.cancel()
			timer = nil
		}
	}
	
	func terminate() {
		cancelActiveTask()
		stop()
	}
	
	@objc func adbDevicesTimer() {
//        let qualityOfServiceClass = DispatchQoS.QoSClass.background
//        let backgroundQueue = DispatchQueue.global(qos: qualityOfServiceClass)
//        backgroundQueue.async(execute: {
			self.adbDevices()
//        })
	}
	
    /*
	fileprivate func getExternalStorageDirectories() -> Array<String> {
		return activeDevice!.externalStorages
	}*/
	
	func hasActiveDevice() -> Bool {
		return (activeDevice != nil)
	}
	
	func setActiveDevice(_ device: AndroidDeviceMac?) -> Bool {
		if let activeDevice = activeDevice, 
		   let device = device, 
		   activeDevice.id == device.id {
			LogW("Same Device")
			return false
		}
        if let device = device, !adbHandler.isAuthorized(device) {
            LogW("Device not authorized: \(device)")
            return false
        }
		activeDevice = device;
		LogV("Active Device: \(activeDevice)")
        ThreadUtils.runInMainThread({
        	NSObject.sendNotification(AndroidViewController.NotificationStartLoading)
        })
		if (device != nil) {
			adbHandler.device = device
			let externalDirectories = activeDevice!.storages
			print("External Directories:", externalDirectories)
			if (externalDirectories.count > 1) {
				externalStorage = externalDirectories[1].path.absolutePath
			} else {
				externalStorage = ""
			}
            if (device!.storages.count > 0) {
            	updateList(device!.storages[0].path.absolutePath, true)
                updateStorage()
            }
		} else {
			externalStorage = ""
            updateList("", true)
            self.spaceStatus.value = []
		}
        observableActiveDevice.value = activeDevice
		return true
	}
	
	func setUsingExternalStorage(_ usingExternalStorage: Bool) {
        self.usingExternalStorage = usingExternalStorage    //Not sure how used yet!
	}
	
	func isUsingExternalStorage() -> Bool {
		return usingExternalStorage;
	}
	
	func reset() {
		currentPath = ""
        observableCurrentPath.value = currentPath
        self.spaceStatus.value = []
	}
    
    func resetStorageDetails() {
        self.spaceStatus.value = []
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
//            adbHandler.deleteFile(file.getFullPath().escapeStringInSingleQuotes())
            adbHandler.deleteFile(file.getFullPath())
		}
	}
	
	/* Available, Total */
	var spaceStatus = Variable<[String]>([])
	
	func getSpaceStatus() -> Observable<[String]> {
		return spaceStatus.asObservable()
	}
	
	func updateStorage() {
        self.spaceStatus.value = []
		var spaceStatus = [String]()
		spaceStatus.append(adbHandler.getAvailableSpace(currentPath))
		spaceStatus.append(adbHandler.getTotalSpace(currentPath))
//        LogD("Space Status: \(spaceStatus)")
		self.spaceStatus.value = spaceStatus
	}
	
	func getExternalStorage() -> String {
		return externalStorage
	}
	
	func getInternalStorage() -> String {
		return internalStorage
	}
	
	fileprivate func getSize(_ filePath: String) -> Number {
		return adbHandler.getFileSize(filePath)
	}
	
	func adbDevices() {
		if (TIMER_VERBOSE) {
			print("Try Enter:", TimeUtils.getCurrentTime())
		}
//        objc_sync_enter(self)
		var newDevices = adbHandler.getDevices()
		let same = containSameElements(newDevices, array2: self.observableAndroidDevices.value)
		if (TIMER_VERBOSE) {
			LogV("Same: \(same)")
		}
//        LogI("IsMain: \(ThreadUtils.isMainThread())")
		if (!same) {
            ThreadUtils.runInMainThread({
                NSObject.sendNotification(AndroidViewController.NotificationSnackbar, ["message": "Updating Devices"])
            })
//			LogV("Main:", ThreadUtils.isMainThread())
			var index = -1
//			LogI("New Devices: \(newDevices)")
			for i in 0..<newDevices.count {
				let device = newDevices[i]
				if let activeDevice = activeDevice, 
				   activeDevice.id == device.id {
					index = i
//					LogI("Moving to \(i), active: \(activeDevice), device: \(device)")
				}
			}
            var newActiveDevice: AndroidDeviceMac? = nil
            var needsUpdate = false
			if (index == -1) {
				if (newDevices.count == 0) {
//                    setActiveDevice(nil)
                    newActiveDevice = nil
				} else {
//					LogV("New Active Device: \(newDevices[0])")
//                    setActiveDevice(newDevices[0])
                    newActiveDevice = newDevices[0]
				}
                needsUpdate = true
			} else {
//				LogV("Rearranging: \(index) active: \(activeDevice)")
				newDevices = rearrange(array: newDevices, fromIndex: index, toIndex: 0)
//				LogV("New Devices: \(newDevices)")
                needsUpdate = false
			}
			LogI("New Devices: \(newDevices)")
			self.observableAndroidDevices.value = newDevices
            if needsUpdate {
                setActiveDevice(newActiveDevice)
            }
            
//            for device in newDevices {
//                if activeDevice != device {
//                    LogV("New Active Device")
//                    activeDevice = device
//                    setActiveDevice(activeDevice)
//                    //TODO: Smarter checks, previous device check.
//                    break
//                }
//            }
        }
		
//        objc_sync_exit(self)
		if (TIMER_VERBOSE) {
			print("Release Lock:", TimeUtils.getCurrentTime())
		}
	}
	
	func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
		var arr = array
		let element = arr.remove(at: fromIndex)
		arr.insert(element, at: toIndex)
		return arr
	}
	
	func containSameElements(_ array1: Array<AndroidDeviceMac>, array2: Array<AndroidDeviceMac>) -> Bool {
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
	
	func updateList(_ path: String, _ force: Bool = false) {
		let currentPath = observableCurrentPath.value
		if (!force && path == currentPath) {
//			LogV("Diff path: \(path), \(currentPath)")
			observableFileList.value = observableFileList.value
			return
		}
		self.currentPath = path
        observableCurrentPath.value = self.currentPath
		adbHandler.device = activeDevice
//        observableFileList.value =  adbHandler.getDirectoryListing(path.escapeStringInSingleQuotes())
        observableFileList.value =  adbHandler.getDirectoryListing(path)
//		LogV("List: \(observableFileList.value)")
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
		var size: Number
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
				if (!(path.count < externalStorage.count)) {
					isRoot = false
				}
			} else {
				if (!(path.count < internalStorage.count)) {
					isRoot = false
				}
			}
		}
//        if (Verbose) {
//            LogV("AndroidHandler, isRootDirectory path:", currentPath);
//            LogV("AndroidHandler, isRootDirectory:", isRoot);
//        }
		return isRoot
	}
	
	func navigateUpList()  {
		let containsSep = currentPath.contains(HandlerConstants.SEPARATOR)
//        print("Contains:", containsSep)
		if (containsSep) {
			let lastSep = (currentPath.range(of: HandlerConstants.SEPARATOR, options: NSString.CompareOptions.backwards)?.lowerBound)!
			currentPath = currentPath.substring(to: lastSep)
//            observableCurrentPath.value = currentPath
//			if (Verbose) { print("Upper:", currentPath) }
			if (usingExternalStorage) {
				if (currentPath.count < externalStorage.count) {
					currentPath = externalStorage
//                    observableCurrentPath.value = currentPath
				}
			} else {
				if (currentPath.count < internalStorage.count) {
					currentPath = internalStorage
//                    observableCurrentPath.value = currentPath
				}
			}
			
//            if (Verbose) {
//                print("Upper Path:", currentPath)
//            }
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
//        let path = getCurrentPath().stringByDeletingLastPathComponent + HandlerConstants.SEPARATOR
        let path = getCurrentPath().stringByDeletingLastPathComponent
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
	
	var hasActiveTask = Variable<FileProgressStatus>(FileProgressStatus.kStatusOk)
	var sizeActiveTask = Variable<Number>(0)
	var transferTypeActive = Variable<Int>(TransferType.AndroidToMac)
	var fileActiveTask = Variable<BaseFile>(EmptyFile)
	var progressActiveTask = Variable<Double>(0.0)
	
	fileprivate var startedTask: Bool = false
	
	private var filesIterator: IndexingIterator<[BaseFile]>?
	private var previousSizeTask = 0 as Number
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
                self.startedTask = false
			} else {
				self.previousSizeTask += previousFile!.size
//				print("Prev Size: \(self.previousSizeTask), total: \(self.sizeActiveTask.value)")
			}
			self.currentFile = currentFile
		} else if (result == AdbExecutionResultWrapper.Result_InProgress) {
			if progress < 0 {
				return
			}
            let totalSize = Double(self.sizeActiveTask.value)       //TODO: Fix some other way?
			let currentItemSize = Double(self.currentFile!.size)
			let currentItemTotalProgress = Double(currentItemSize / totalSize) * 100.0
			let currentProgress = (Double(progress) * Double(currentItemTotalProgress) / 100.0)
			
			let previousProgress = (Double(self.previousSizeTask) / totalSize) * 100.0
//            print("Prev: \(previousProgress), curr: \(currentProgress)")
			self.progressActiveTask.value = previousProgress + currentProgress
		} else if (result == AdbExecutionResultWrapper.Result_Canceled) {
            print("AndroidHandler: Canceled")
			self.hasActiveTask.value = FileProgressStatus.kStatusCanceled
            self.startedTask = false
		}
	};

//    Push to Android
	func push(_ sourceFiles: Array<BaseFile>, destination: String) {
		print("Pushing: \(sourceFiles) to \(destination)")
		cancelTask = false
		previousSizeTask = 0
		hasActiveTask.value = FileProgressStatus.kStatusInProgress
		if (activeDevice != nil) {
			startedTask = false
			totalItems = sourceFiles.count
			var size = 0 as Number
			filesIterator = sourceFiles.makeIterator()
			var sourceFileName = ""
			while let file = filesIterator!.next() {
				sourceFileName = file.path + HandlerConstants.SEPARATOR + file.fileName
//				TODO: Worst case!
//				if ((file.size == 0 || file.size == Number.max) && file.type == BaseFileType.Directory) {
//					file.size = getSize(sourceFileName)
//				}
				size = size + file.size
			}
//            sizeActiveTask.value = size   //Temporarily, may have hazardous effects!
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
//                adbHandler.push(sourceFileName.escapeString(), toDestination: destination, transferBlock)
                adbHandler.push(sourceFileName, toDestination: destination, transferBlock)
				print("After Single Push!")
			}
			print("After Push!")
		} else {
			print("Warning, no active")
		}
	}

//    Pull from Android
	func pull(_ sourceFiles: Array<BaseFile>, destination: String) {
		print("Pulling: \(sourceFiles) to \(destination)")
		cancelTask = false
		previousSizeTask = 0
		hasActiveTask.value = FileProgressStatus.kStatusInProgress
		if (activeDevice != nil) {
			startedTask = false
			totalItems = sourceFiles.count
			filesIterator = sourceFiles.makeIterator()
			var size = 0 as Number
			var sourceFileName = ""
			while let file = filesIterator!.next() {
				sourceFileName = file.path + HandlerConstants.SEPARATOR + file.fileName
				if ((file.size == 0 || file.size == Number.max) && file.type == BaseFileType.Directory) {
					file.size = getSize(sourceFileName)
				}
                if size != Number.max {
					size = size + file.size
                }
			}
			sizeActiveTask.value = size
			transferTypeActive.value = TransferType.AndroidToMac
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
