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
	
	fileprivate var currentPath: String = ""
	fileprivate var adbDirectoryPath: String = ""
	fileprivate var adbLaunchPath: String = ""
	fileprivate var timer: Timer? = nil
	fileprivate var androidDevices: Array<AndroidDevice> = []
//    private var androidDevices : SynchronizedObject<Array<AndroidDevice>>
	fileprivate var activeDevice: AndroidDevice? = nil
	
	fileprivate var deviceNotificationDelegate: DeviceNotficationDelegate? = nil
	
	fileprivate var devicesUpdating: Bool = false
	fileprivate var active: Bool = true
	
	fileprivate var externalStorage: String = ""
	fileprivate var internalStorage: String = "/sdcard"
	fileprivate var totalSpace: UInt64 = 0
	fileprivate var totalSpaceInString: String = ""
	
	fileprivate var usingExternalStorage = false
	
	// fileprivate static var sJavaType = ""
	fileprivate let espaceDoubleQuotes = StringResource.ESCAPE_DOUBLE_QUOTES
	fileprivate static let JAVA_TYPE_COMMAND = AndroidShellScripts.JAVA_TYPE_COMMAND
    
    fileprivate lazy var adbHandler: AndroidAdbHandler = {
        return AndroidAdbHandler(directory: self.adbDirectoryPath)
	}()
	
	private var data: Data? = nil
	
	override init() {
		currentPath = ""
		adbLaunchPath = "/bin/bash"

//        test { (result) in
//            print("Op:", result)
//        }
	}
	
	func initialize(_ data: Data) {
		self.data = data
		adbDirectoryPath = self.extractAdbAsset()
        LogV("Initialize")
        
        // adbHandler = AndroidAdbHandler(adbDirectoryPath)
        // if let adbHandler = adbHandler {
        	// adbHandler.deviceId = "ZY223DGND4"
        	// adbHandler.adbDirectoryPath = adbDirectoryPath
            // adbHandler.getDirectoryListing("/sdcard/")
        // }
	}
	
	func isFirstLaunch() -> Bool {
		let resourcePath = Bundle.main.resourcePath!
		let fileManager = FileManager.default
		return !(fileManager.fileExists(atPath: resourcePath + "/adb"))
	}
	
	func extractAdbAsset() -> String {
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
	
	func getAndroidDevices() -> Array<AndroidDevice> {
		return androidDevices
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
	
	fileprivate func getExternalStorageDirectories() -> Array<String> {
		return activeDevice!.externalStorages
	}
	
	fileprivate func splitLines(_ string: String) -> [String] {
		return string.characters.split {
			$0 == "\n" || $0 == "\r\n"
		}.map(String.init)
	}
	
	func hasActiveDevice() -> Bool {
		return (activeDevice != nil)
	}
	
	func setActiveDevice(_ device: AndroidDevice?) {
		activeDevice = device;
		LogV("Active Device:", activeDevice)
		if (activeDevice != nil) {
			adbHandler.device = activeDevice
			let externalDirectories = getExternalStorageDirectories()
			print("External Directories:", externalDirectories)
			if (externalDirectories.count > 0) {
				externalStorage = externalDirectories[0];
			} else {
				externalStorage = ""
			}
		} else {
			externalStorage = ""
		}
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
			// let command = "rm -rf " + espaceDoubleQuotes + file.getFullPath() + espaceDoubleQuotes
			// LogV("Delete", file, command)
			// let _ = adbShell(command)
			print("Delete, \(file.getFullPath())")
			// TODO: TEST!!!
			adbHandler.deleteFile(file.getFullPath())
		}
	}
	
	func updateStorage() {
		totalSpaceInString = adbHandler.getTotalSpace(currentPath)
	}
	
	func getAvailableSpace() -> String {
		return adbHandler.getAvailableSpace(currentPath)
	}
	
	func getTotalSpace() -> UInt64 {
		return totalSpace
	}
	
	func getTotalSpaceInString() -> String {
		return totalSpaceInString
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
		let same = containSameElements(newDevices, array2: androidDevices)
		if (TIMER_VERBOSE) {
			LogV("Same: \(same)")
		}
		if (!same) {
			androidDevices.removeAll()
			androidDevices.append(contentsOf: newDevices)
            Swift.print("Androidhandler, Main:", ThreadUtils.isMainThread())
            self.observableAndroidDevices.value = self.androidDevices
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

//    From Android
	func pull(_ sourceFiles: Array<BaseFile>, destination: String, delegate: FileProgressDelegate) {
		cancelTask = false
		if (activeDevice != nil) {
			startedTask = false
			var i = 0
			var pullCommand = "" as String
			var size = 0 as UInt64
			while i < sourceFiles.count {
				pullCommand = pullCommand + "./adb" + " -s " + (activeDevice?.id)!
				let file = sourceFiles[i]
				let sourceFileName = file.path + HandlerConstants.SEPARATOR + file.fileName
				pullCommand = pullCommand + " pull " + espaceDoubleQuotes + sourceFileName + espaceDoubleQuotes + " " + espaceDoubleQuotes + destination + espaceDoubleQuotes + ";\n"
				if ((file.size == 0 || file.size == UInt64.max) && file.type == BaseFileType.Directory) {
					file.size = getSize(sourceFileName)
				}
				size = size + file.size
				i = i + 1
			}
			delegate.onStart(size, transferType: TransferType.AndroidToMac)
			i = 0
			delegate.currentFile(sourceFiles[i].fileName)
			
			print("------Start Time:", TimeUtils.getCurrentTime())
			
			print(pullCommand)
			self.adbAsync(pullCommand, with: { (output) in
//                    print("Pull Output:", output)
				if (output == nil) {
					DispatchQueue.main.async(execute: { () -> Void in
						print("This is run on the main queue, after the previous code in outer block")
						i = 0
						while i < sourceFiles.count {
							if (sourceFiles[i].type == BaseFileType.Directory) {
								sourceFiles[i].size = UInt64.max
							}
							i = i + 1
						}
						print("Complete, cancel:", self.cancelTask)
						if (self.cancelTask) {
							delegate.onCompletion(status: FileProgressStatus.kStatusCanceled)
						} else {
							delegate.onCompletion(status: FileProgressStatus.kStatusOk)
						}
					})
				} else {
					let outputLines = output!.characters.split {
						$0 == "\n" || $0 == "\r\n"
					}.map(String.init)
					let output = outputLines[outputLines.count - 1]
//                        print("Op:", output, " Regex:", self.regexPercentage)

//				TODO: Include in future, show current file being transferred.
//					let matchesFileName = self.matchesForRegexInText(self.regexFileName, text: output)
//					if (matchesFileName.count > 0) {
//						//                        let newStartIndex = advance(matches[0].startIndex, 1)
//						//                        let newEndIndex = advance(matches[0].endIndex, -2)
//						let fileName = matchesFileName[0]
////                            print("File:", fileName)
//						dispatch_async(dispatch_get_main_queue(), { () -> Void in
//							delegate.currentFile(fileName)
//						})
//					}
					let matchesPercentage = self.matchesForRegexInText(self.regexPercentage, text: output)
					if (matchesPercentage.count > 0) {
						//                        let newStartIndex = advance(matches[0].startIndex, 1)
						//                        let newEndIndex = advance(matches[0].endIndex, -2)
						var progressString = matchesPercentage[0]
						progressString.remove(at: progressString.startIndex)
						progressString.remove(at: progressString.characters.index(before: progressString.endIndex))
						progressString.remove(at: progressString.characters.index(before: progressString.endIndex))
						progressString = progressString.trimmingCharacters(
								in: CharacterSet.whitespacesAndNewlines
						)
//                            print("Matches:", progressString)
						if let progress = Int(progressString) {
//                                print("Percentage:", progress)
							DispatchQueue.main.async(execute: { () -> Void in
								if (progress == 100) {
									i = i + 1
									if (i < sourceFiles.count) {
										delegate.currentFile(sourceFiles[i].fileName)
									}
								}
								delegate.onProgress(progress)
							})
						}

//                            let progress = Int(progressString)
//                            print("Percentage:", progress)
					}
				}
			})
		} else {
			print("Warning, No active device")
		}

//        timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(AndroidHandler.testComplete), userInfo: nil, repeats: true)
		
	}
	
	let regexPercentage = "\\[.*%\\]"
	let regexFileName = "[^/]*$"
	
	func matchesForRegexInText(_ regex: String, text: String) -> [String] {
		
		do {
			let regex = try NSRegularExpression(pattern: regex, options: [])
			let nsString = text as NSString
			let results = regex.matches(in: text,
					options: [], range: NSMakeRange(0, nsString.length))
			return results.map {
				nsString.substring(with: $0.range)
			}
		} catch let error as NSError {
			print("invalid regex: \(error.localizedDescription)")
			return []
		}
	}

//    To Android
	func push(_ sourceFiles: Array<BaseFile>, destination: String, delegate: FileProgressDelegate) {
		cancelTask = false
		if (activeDevice != nil) {
			startedTask = false
			var size = 0 as UInt64
			var i = 0
			var pushCommand = "" as String
			while i < sourceFiles.count {
				let file = sourceFiles[i]
				pushCommand = pushCommand + "./adb" + " -s " + (activeDevice?.id)!
				let sourceFileName = file.path + HandlerConstants.SEPARATOR + file.fileName
				pushCommand = pushCommand + " push " + espaceDoubleQuotes + sourceFileName + espaceDoubleQuotes + " " + espaceDoubleQuotes + destination + HandlerConstants.SEPARATOR + espaceDoubleQuotes + ";\n"
//				TODO: Worst case!
//				if ((file.size == 0 || file.size == UInt64.max) && file.type == BaseFileType.Directory) {
////					file.size = getSize(sourceFileName)
//				}
				size = size + file.size
				i = i + 1
			}
			
			delegate.onStart(size, transferType: TransferType.MacToAndroid)
			i = 0
			delegate.currentFile(sourceFiles[i].fileName)
			
			print("------Start Time:", TimeUtils.getCurrentTime())
			print("Push:", pushCommand)
//        let output = adb(adbLaunchPath, arguments: arguments, directoryPath: adbDirectoryPath)
			self.adbAsync(pushCommand, with: { (output) in
//				print("Push:", output)
				if (output == nil) {
					DispatchQueue.main.async(execute: { () -> Void in
//                            print("This is run on the main queue, after the previous code in outer block")
						i = 0
						while i < sourceFiles.count {
							if (sourceFiles[i].type == BaseFileType.Directory) {
								sourceFiles[i].size = UInt64.max
							}
							i = i + 1
						}
						print("Complete, cancel:", self.cancelTask)
						if (self.cancelTask) {
							delegate.onCompletion(status: FileProgressStatus.kStatusCanceled)
						} else {
							delegate.onCompletion(status: FileProgressStatus.kStatusOk)
						}
					})
				} else {
					let outputLines = output!.characters.split {
						$0 == "\n" || $0 == "\r\n"
					}.map(String.init)
					let output = outputLines[outputLines.count - 1]
//					print("AndroidHandler, Time:", TimeUtils.getCurrentTime(), ", Op:", output, ", Regex:", self.regexPercentage)
					
					let matchesPercentage = self.matchesForRegexInText(self.regexPercentage, text: output)
					if (matchesPercentage.count > 0) {
						//                        let newStartIndex = advance(matches[0].startIndex, 1)
						//                        let newEndIndex = advance(matches[0].endIndex, -2)
						var progressString = matchesPercentage[0]
						progressString.remove(at: progressString.startIndex)
						progressString.remove(at: progressString.characters.index(before: progressString.endIndex))
						progressString.remove(at: progressString.characters.index(before: progressString.endIndex))
						progressString = progressString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
//						print("Matches:", progressString)
						if let progress = Int(progressString) {
//							print("Percentage:", progress)
							DispatchQueue.main.async(execute: { () -> Void in
								if (progress == 100) {
									i = i + 1
									if (i < sourceFiles.count) {
										delegate.currentFile(sourceFiles[i].fileName)
									}
								}
								delegate.onProgress(progress)
							})
						}
					}
				}
			})
		} else {
			print("Warning, no active")
		}
	}
	
	func isFileTypeString(str: String) -> Bool {
		return str.contains(HandlerConstants.DIRECTORY) || str.contains(HandlerConstants.FILE);
	}
	
	func openDirectoryData(_ path: String) -> Array<BaseFile>! {
		currentPath = path
		adbHandler.device = activeDevice
		return adbHandler.getDirectoryListing(path)
	}
	
	func updateSizes(_ files: Array<BaseFile>) {
		var i = 0;
		while i < files.count {
//			let fileName = files[i].path + HandlerConstants.SEPARATOR + files[i].fileName
//			var size: UInt64
//			if (files[i].type == BaseFileType.Directory) {
//				size = getSize(fileName)
//			} else {
//				size = getSize(fileName)
//			}
//			
//			files[i].size = size
			
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
	
	func upDirectoryData() -> Array<BaseFile>! {
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
			return openDirectoryData(currentPath)
		}
		return []
	}
	
	// TODO: Keep if used later!
	// func isDirectory(_ fileName: String) -> Bool {
	// 	let directory = currentPath;
	// 	let commands = "cd " + espaceDoubleQuotes + directory + espaceDoubleQuotes + "; [ -d " + espaceDoubleQuotes + directory + HandlerConstants.SEPARATOR + fileName + espaceDoubleQuotes + " ] && echo \"" + HandlerConstants.DIRECTORY + "\";";
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
	
	func cancelActiveTask() {
		if (startedTask) {
			if (activeTask != nil) {
				activeTask!.terminate()
			}
		} else {
			if (Verbose) {
				print("AndroidHandler, Warning, Task not Started!");
			}
		}
		cancelTask = true
	}
	
	//TODO: Handle active task cancelation!!
	fileprivate var activeTask: Process? = nil
	fileprivate var startedTask: Bool = false
	fileprivate var cancelTask: Bool = false
	
	fileprivate func adbAsync(_ commands: String, with: @escaping (_ output: String?) -> Void) {
		startedTask = true
		if (Verbose) {
			print("AndroidHandler, Started Adb Async");
		}
		self.startAdbIfNotStarted()
		
		let task = Process()
		activeTask = task
		if (Verbose) {
			print("AndroidHandler, Started Task");
		}
		task.launchPath = adbLaunchPath
		task.arguments = ["-l", "-c", commands]
		task.currentDirectoryPath = adbDirectoryPath
		
		let pipe = Pipe()
		task.standardOutput = pipe
		let outHandle = pipe.fileHandleForReading
		
		var obs1: NSObjectProtocol!
		obs1 = NotificationCenter.default.addObserver(
				forName: NSNotification.Name.NSFileHandleDataAvailable,
				object: outHandle, queue: nil) { notification -> Void in
			let data = outHandle.availableData
//			print("Data: ", data);
			if data.count > 0 {
				if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
//                        print("Output:", str)
					with(str as String)
				}
				outHandle.waitForDataInBackgroundAndNotify()
			} else {
				print("EOF on stdout from process")
				NotificationCenter.default.removeObserver(obs1)
			}
		}
		
		var obs2: NSObjectProtocol!
		obs2 = NotificationCenter.default.addObserver(
				forName: Process.didTerminateNotification,
				object: task, queue: nil) { notification -> Void in
			print("Terminated")
			with(nil)
			NotificationCenter.default.removeObserver(obs2)
		}
		
		outHandle.waitForDataInBackgroundAndNotify()
		task.launch()
		if (cancelTask) {
			task.terminate()
			activeTask = nil
			cancelTask = false
			print("Terminating!")
		}
		
		if (Verbose) {
			print("AndroidHandler, Launched Task");
		}
	}
	
	fileprivate func startAdbIfNotStarted() {
		let command = "./adb start-server"
		let task = Process()
		task.launchPath = adbLaunchPath
		task.arguments = ["-l", "-c", command]
		task.currentDirectoryPath = adbDirectoryPath
		
		let pipe = Pipe()
		task.standardOutput = pipe
		
		task.launch()
		
		task.waitUntilExit()
	}
}
