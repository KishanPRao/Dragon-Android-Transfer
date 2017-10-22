//
//  AndroidHandler.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/16.
//  Copyright © 2016 Kishan P Rao. All rights reserved.
//

import Foundation

public class AndroidHandler: NSObject {
    override class var VERBOSE: Bool {
        return false
    }
    let EXTREME_VERBOSE = false
    let TIMER_VERBOSE = false
	static let ESCAPE_DOUBLE_QUOTES = "\""
	static let SINGLE_QUOTES = "'"
//    let DEVICE_UPDATE_DELAY = 0.01
	let DEVICE_UPDATE_DELAY = 1
	
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
	
	fileprivate static let GNU_TYPE = "GNU"
	fileprivate static let BSD_TYPE = "BSD"
	fileprivate static let SOLARIS_TYPE = "SOLARIS"
	fileprivate static var sJavaType = ""
	fileprivate static let JAVA_TYPE_COMMAND =
			"TYPE=" + AndroidHandler.ESCAPE_DOUBLE_QUOTES + AndroidHandler.ESCAPE_DOUBLE_QUOTES + ";" +
					"GNU=" + AndroidHandler.ESCAPE_DOUBLE_QUOTES + AndroidHandler.GNU_TYPE + AndroidHandler.ESCAPE_DOUBLE_QUOTES + ";" +
					"BSD=" + AndroidHandler.ESCAPE_DOUBLE_QUOTES + AndroidHandler.BSD_TYPE + AndroidHandler.ESCAPE_DOUBLE_QUOTES + ";" +
					"SOLARIS=" + AndroidHandler.ESCAPE_DOUBLE_QUOTES + AndroidHandler.SOLARIS_TYPE + AndroidHandler.ESCAPE_DOUBLE_QUOTES + ";" +
					"if ls --color -d . >/dev/null 2>&1; then " +
					"TYPE=$GNU;" +
					"elif ls -G -d . >/dev/null 2>&1; then " +
					"TYPE=$BSD;" +
					"else " +
					"TYPE=$SOLARIS;" +
					"fi;" +
					"echo \"$TYPE\";"
	
	fileprivate static let LS_FILE_SIZE_COMMAND = "LS_FILE"
	fileprivate static let GNU_LS_FILE_SIZE = "LS_FILE() { output=$(ls -sk -- \"$1\"); first=${output%% *}; echo \"$first\"; }\n"
	fileprivate static let SOLARIS_LS_FILE_SIZE = "LS_FILE() { output=$(ls -s -- \"$1\"); first=${output%% *}; echo \"$first\"; }\n"
	fileprivate static let GNU_LS_SIZE_COMMAND_NAME = "GNU_LS"
	fileprivate static let GNU_LS_SIZE_COMMAND = "GNU_LS(){ lsOutput=$(ls -AskLR -- \"$1\"); output=$(echo \"$lsOutput\" | grep '^total [0-9]*$'); total=0; for size in $output; do if [ $size = \"total\" ]; then continue; fi; total=$(( total + size )); done; echo \"$total\"; }\n"
//	private static let SOLARIS_LS_SIZE_COMMAND = "SOLARIS_LS(){ total=0; for a in $(ls -sR \"$1\" | grep '^total [0-9]*$'); do if [ $a = \"total\" ]; then continue; fi; total=$(( total + a )); done; echo \"$total\"; }\n"
	fileprivate static let SOLARIS_LS_SIZE_COMMAND_NAME = "SOLARIS_LS"
	fileprivate static let SOLARIS_LS_SIZE_COMMAND = "SOLARIS_LS(){ lsOutput=$(ls -sR -- \"$1\"); output=$(echo \"$lsOutput\" | grep '^total [0-9]*$'); total=0; for size in $output; do if [ $size = \"total\" ]; then continue; fi; total=$(( total + size )); done; echo \"$total\"; }\n"
	
	fileprivate static let GNU_LS_SIZE = GNU_LS_FILE_SIZE + GNU_LS_SIZE_COMMAND + "ls | for name in *; do echo \"$name\"; if [ -d \"$name\" ]; then echo \"DIRECTORY\"; GNU_LS \"$name\"; else echo \"FILE\"; LS_FILE \"$name\"; fi; done;"

//	private static let BSD_LS_SIZE_COMMAND = GNU_LS_SIZE
	fileprivate static let BSD_LS_SIZE = GNU_LS_SIZE
	fileprivate static let SOLARIS_LS_SIZE = GNU_LS_FILE_SIZE + SOLARIS_LS_SIZE_COMMAND + "ls | for name in *; do echo \"$name\"; if [ -d \"$name\" ]; then echo \"DIRECTORY\"; SOLARIS_LS \"$name\"; else echo \"FILE\"; LS_FILE \"$name\"; fi; done;"
	
	override init() {
		currentPath = ""
		adbLaunchPath = "/bin/bash"

//        test { (result) in
//            print("Op:", result)
//        }
	}
	
	func initialize() {
		adbDirectoryPath = self.extractAdbAsset()
	}
	
	func isFirstLaunch() -> Bool {
		let resourcePath = Bundle.main.resourcePath!
		let fileManager = FileManager.default
		return !(fileManager.fileExists(atPath: resourcePath + "/adb"))
	}
	
	fileprivate func test(_ completion: @escaping (_ result: String) -> Void) {
		let task = Process()
		task.launchPath = "/bin/sh"
		task.arguments = ["-c", "echo 1 ; sleep 3 ; echo 2 ; sleep 5 ; echo 3 ; sleep 5 ; echo 4"]
		
		let pipe = Pipe()
		task.standardOutput = pipe
		let outHandle = pipe.fileHandleForReading
		outHandle.waitForDataInBackgroundAndNotify()
		
		var obs1: NSObjectProtocol!
		obs1 = NotificationCenter.default.addObserver(
				forName: NSNotification.Name.NSFileHandleDataAvailable,
				object: outHandle, queue: nil) { notification -> Void in
			let data = outHandle.availableData
			if data.count > 0 {
				if let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
//                        print("got output: \(str)")
					completion(str as String)
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
			print("terminated")
			NotificationCenter.default.removeObserver(obs2)
		}
		
		task.launch()
		
	}
	
	func extractAdbAsset() -> String {
		let resourcePath = Bundle.main.resourcePath!
		if (!isFirstLaunch()) {
			return resourcePath
		}
		let fileManager = FileManager.default
		let fileExists = fileManager.fileExists(atPath: resourcePath + "/adb")
		print("AndroidHandler, file Exists:", fileExists)
		let data = NSDataAsset.init(name: "adb")?.data
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
	
	func synced(_ lock: AnyObject, closure: ()) {
		print("Try Enter:", TimeUtils.getCurrentTime())
		objc_sync_enter(lock)
		closure
		objc_sync_exit(lock)
		print("Release Lock:", TimeUtils.getCurrentTime())
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
		var directories = [] as Array<String>
		let output = adbShell("cd /storage; ls -l;");
		let fileNames = adbShell("cd /storage; ls;");
//        print("File Names:", fileNames)
		let outputLines = splitLines(output)
		let fileNamesLines = splitLines(fileNames)
		var skipLines = 0
		if (outputLines.count > 0 && outputLines[0].hasPrefix("total")) {
			skipLines = 1
		}
		var i = skipLines
//		print("Output:", outputLines)
		while (i < outputLines.count) {
//            print("i:", i)
			let line = outputLines[i]
			if (!line.contains("self") && !line.contains("emulated") && !line.contains("system")) {
//                print("Appending:", fileNamesLines[i - skipLines]," Line:", line)
				directories.append("/storage/" + fileNamesLines[i - skipLines])
			}
			i = i + 1
		}
		return directories
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
			let externalDirectories = getExternalStorageDirectories()
			print("External Directories:", externalDirectories)
			if (externalDirectories.count > 0) {
				externalStorage = externalDirectories[0];
			} else {
				externalStorage = ""
			}
			var output = adbShell(AndroidHandler.JAVA_TYPE_COMMAND)
			output = output.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
			LogV("AndroidHandler, Type:", output);
			AndroidHandler.sJavaType = output
			if (Verbose) {
//				print("AndroidHandler, Type:", AndroidHandler.JAVA_TYPE);
//				print("AndroidHandler, Type GNU:", AndroidHandler.GNU_TYPE);
//				print("AndroidHandler, equal to GNU?", AndroidHandler.JAVA_TYPE == AndroidHandler.GNU_TYPE);
			}

//			if (Verbose) {
//				var lsSizeCommand: String
//				if (AndroidHandler.sJavaType == AndroidHandler.GNU_TYPE) {
//					lsSizeCommand = AndroidHandler.GNU_LS_SIZE
//				} else if (AndroidHandler.sJavaType == AndroidHandler.BSD_TYPE) {
//					lsSizeCommand = AndroidHandler.BSD_LS_SIZE
//				} else {
//					lsSizeCommand = AndroidHandler.SOLARIS_LS_SIZE
//				}
//				lsSizeCommand = lsSizeCommand.replacingOccurrences(of: "ls |", with: "cd /sdcard; ls |")
////				lsSizeCommand = lsSizeCommand.stringByReplacingOccurrencesOfString("ls |", withString: "cd " + currentPath + " ls |")
//				let output1 = adbShell(lsSizeCommand)
//				print("AndroidHandler, Size:", output1);
//			}
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
		var command = "[ -" + (isFile ? "f": "d") + " " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + filePath + AndroidHandler.ESCAPE_DOUBLE_QUOTES + " ]" +
				" && echo " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + HandlerConstants.EXIST + AndroidHandler.ESCAPE_DOUBLE_QUOTES + 
				" || echo " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + HandlerConstants.NOT_EXIST + AndroidHandler.ESCAPE_DOUBLE_QUOTES
		let output = adbShell(command).replacingOccurrences(of: "\r\n", with: "").replacingOccurrences(of: "\n", with: "")
		let exists = (output == HandlerConstants.EXIST)
		Swift.print("AndroidHandler, exists:", exists)
		return exists
	}
	
	func fileExists(_ name: String) -> Bool {
		return exists(currentPath + HandlerConstants.SEPARATOR + name, isFile: true)
	}
	
	func folderExists(_ name: String) -> Bool {
		return exists(currentPath + HandlerConstants.SEPARATOR + name, isFile: false)
	}
	
	func createNewFolder(_ folderName: String) {
		let command = "mkdir " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + currentPath + HandlerConstants.SEPARATOR + folderName + AndroidHandler.ESCAPE_DOUBLE_QUOTES
		adbShell(command)
//		TODO: Need check? Success?
	}
    
    func delete(_ files: Array<BaseFile>) {
        for file in files {
            let command = "rm -rf " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + file.getFullPath() + AndroidHandler.ESCAPE_DOUBLE_QUOTES
            LogV("Delete", file, command)
            adbShell(command)
        }
    }
	
	func updateStorage() {
		var command: String
		if (AndroidHandler.sJavaType == AndroidHandler.GNU_TYPE || AndroidHandler.sJavaType == AndroidHandler.BSD_TYPE) {
			command = "df -k "
		} else {
			command = "df "
		}
		let output = adbShell(command + AndroidHandler.ESCAPE_DOUBLE_QUOTES + currentPath + AndroidHandler.ESCAPE_DOUBLE_QUOTES)
		let outputInLines = splitLines(output)
		if (outputInLines.count < 2) {
			print("Cannot update!")
//			totalSpace = 0
			totalSpaceInString = "0B"
			return
		}
		let outputInTabs = outputInLines[1].characters.split {
			$0 == " "
		}.map(String.init)
		if let totalSpaceInInt = UInt64(outputInTabs[1]) {
//			totalSpace = totalSpaceInInt * UInt64(BLOCK_SIZE_IN_FLOAT)
			totalSpaceInString = SizeUtils.getBytesInFormat(totalSpaceInInt * UInt64(BLOCK_SIZE_IN_FLOAT))
		} else {
//			Solaris
			totalSpaceInString = outputInTabs[1] + "B"
		}
		if (EXTREME_VERBOSE) {
//			print("Output:", outputInTabs)
		}
		if (EXTREME_VERBOSE) {
//			print("Total:", totalSpace)
		}
	}
	
	func getAvailableSpace() -> String {
		var command: String
		if (AndroidHandler.sJavaType == AndroidHandler.GNU_TYPE || AndroidHandler.sJavaType == AndroidHandler.BSD_TYPE) {
			command = "df -k "
		} else {
			command = "df "
		}
		var availableSpace = "0B";
		let output = adbShell(command + AndroidHandler.ESCAPE_DOUBLE_QUOTES + currentPath + AndroidHandler.ESCAPE_DOUBLE_QUOTES)
		let outputInLines = splitLines(output)
		if (outputInLines.count < 2) {
			print("Cannot update!")
			return availableSpace
		}
		let outputInTabs = outputInLines[1].characters.split {
			$0 == " "
		}.map(String.init)
		if let totalSpaceInInt = UInt64(outputInTabs[1]) {
			if let usedSpaceInInt = UInt64(outputInTabs[2]) {
				let availableSpaceInInt = (totalSpaceInInt - usedSpaceInInt) * UInt64(BLOCK_SIZE_IN_FLOAT) as UInt64
				availableSpace = SizeUtils.getBytesInFormat(availableSpaceInInt)
			}
		} else {
//			Solaris
			availableSpace = outputInTabs[3] + "B"
		}
		return availableSpace
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
	
	fileprivate func getSize(_ fileName: String) -> UInt64 {
		let maxSizeInMBytes = UInt64.max / 1024
		let command = "du -sk " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + fileName + AndroidHandler.ESCAPE_DOUBLE_QUOTES + ";"
		let output = adbShell(command)
		var sizeInBytes = UInt64.max as UInt64
		let sizeStringArray = output.characters.split {
			$0 == " " || $0 == "\t"
		}.map(String.init)
		if let sizeInInt = UInt64(sizeStringArray[0]) {
			sizeInBytes = sizeInInt
			if (sizeInBytes > maxSizeInMBytes) {
				sizeInBytes = UInt64.max
			} else {
				sizeInBytes = sizeInBytes * 1024
			}
		}
		return sizeInBytes
	}
	
	func adbDevices() {
		if (TIMER_VERBOSE) {
			print("Try Enter:", TimeUtils.getCurrentTime())
		}
		objc_sync_enter(self)
		
		let devicesString = adb("./adb devices;")
		
		let devices = devicesString.characters.split {
			$0 == "\n" || $0 == "\r\n"
		}.map(String.init)
		var i = 1
//        androidDevices.removeAll()
		var localAndroidDevices: Array<AndroidDevice> = []
		while i < devices.count {
			var deviceId = devices[i].characters.split {
				$0 == "\t"
			}.map(String.init)[0]
//            .display gives "nicer" name
			var deviceName = adb("./adb -s " + deviceId + " shell getprop ro.product.model")
			deviceId = deviceId.trimmingCharacters(
					in: CharacterSet.whitespacesAndNewlines
			)
			deviceName = deviceName.trimmingCharacters(
					in: CharacterSet.whitespacesAndNewlines
			)
//            print("Device Id:", deviceId)
//            print("Device Name:", deviceName)
			let device = AndroidDevice.init(id: deviceId, name: deviceName)
//            androidDevices.append(device)
			localAndroidDevices.append(device)
//            androidDevices.set { protected in
//                protected.append(device)
//            }
			i = i + 1
		}
		let same = containSameElements(localAndroidDevices, array2: androidDevices)
//        localAndroidDevices.sortInPlace({$0.name < $1.name})
		if (TIMER_VERBOSE) {
			print("Same Elements", same)
		}
		if (!same) {
			androidDevices.removeAll()
			androidDevices.append(contentsOf: localAndroidDevices)
			DispatchQueue.main.async {
				if (self.deviceNotificationDelegate != nil) {
					self.deviceNotificationDelegate?.onUpdate()
				}
			}
		}
//        androidDevices.set { protected in
//            protected.removeAll()
//            protected.appendContentsOf(localAndroidDevices)
//        }
		if (TIMER_VERBOSE) {
			print("Devices:", androidDevices)
		}
//        devicesUpdating = false
		
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
				pullCommand = pullCommand + " pull " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + sourceFileName + AndroidHandler.ESCAPE_DOUBLE_QUOTES + " " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + destination + AndroidHandler.ESCAPE_DOUBLE_QUOTES + ";\n"
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


//    var timer: NSTimer?


//    @objc func testComplete() {
//        delegate?.onCompletion()
//    }
//
//    var delegate: FileProgressDelegate?


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
				pushCommand = pushCommand + " push " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + sourceFileName + AndroidHandler.ESCAPE_DOUBLE_QUOTES + " " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + destination + HandlerConstants.SEPARATOR + AndroidHandler.ESCAPE_DOUBLE_QUOTES + ";\n"
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
		let listString = adbListData(currentPath);
		var directories: Array<BaseFile> = [];
		let outputInLines = splitLines(listString)
		var noOutput = false
//		print("Output:", outputInLines)
		noOutput = outputInLines.count <= 0 || outputInLines.count <= 2 || (outputInLines.count == 3 && outputInLines[2].contains("No such file"))
//		noOutput = outputInLines.count <= 0 || outputInLines.count <= 2
		if (noOutput) {
			print("No Output!!!!")
//			print("Output:", outputInLines)
			return directories
		}
		var i = 0
		let maxSizeInMBytes = UInt64.max / 1024
		while (i < outputInLines.count) {
			var fileType = BaseFileType.File;
			var sizeInKiloBytes = UInt64.max as UInt64
			var name = ""
			var extraNewLine = ""
			while (!isFileTypeString(str: outputInLines[i])) {
				name = name + extraNewLine + outputInLines[i]
				i = i + 1
				extraNewLine = "\n";
			}
			if (outputInLines[i].contains(HandlerConstants.DIRECTORY)) {
				fileType = BaseFileType.Directory
			}
//			name = outputInLines[i]
//			i = i + 1
//            if (isFileTypeString(str: outputInLines[i])) {
//				if (outputInLines[i].contains(HandlerConstants.DIRECTORY)) {
//					fileType = BaseFileType.Directory
//				}
//            } else {
//                //TODO: Recurse? Bad idea, update internal.
//                name = name + outputInLines[i]
//                i = i + 1
//            }
			i = i + 1
			if (fileType == BaseFileType.File) {
				let sizeStringArray = outputInLines[i].characters.split {
					$0 == " " || $0 == "\t"
				}.map(String.init)
				if let sizeInInt = UInt64(sizeStringArray[0]) {
					sizeInKiloBytes = sizeInInt
					if (Verbose) {
//						print("AndroidHandler: Size in KBytes:", sizeInKiloBytes);
					}
					if (sizeInKiloBytes > maxSizeInMBytes) {
						sizeInKiloBytes = UInt64.max
					} else {
						sizeInKiloBytes = sizeInKiloBytes * 1024
					}
//				sizeInBytes = sizeInInt
				}
			} else {
				sizeInKiloBytes = 0
			}
//			if let sizeInInt = UInt64(outputInLines[i]) {
//				sizeInKiloBytes = sizeInInt
////				if (Verbose) {
////					print("AndroidHandler: Size in KBytes:", sizeInKiloBytes);
////				}
//				if (sizeInKiloBytes > maxSizeInMBytes) {
//					sizeInKiloBytes = UInt64.max
//				} else {
//					sizeInKiloBytes = sizeInKiloBytes * 1024
//				}
////				directories.append(BaseFile.init(fileName: name, path: currentPath, type: fileType, size: sizeInKiloBytes))
//			}
			directories.append(BaseFile.init(fileName: name, path: currentPath, type: fileType, size: sizeInKiloBytes))
			i = i + 1
		}
		if (EXTREME_VERBOSE) {
			print("Dirs:", directories)
		}
		directories.sort { file, file1 in
			return file.fileName.lowercased() < file1.fileName.lowercased()
		}
		if (EXTREME_VERBOSE) {
			print("Sorted Dirs:", directories)
		}
		return directories;
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
		let fileName = file.path + HandlerConstants.SEPARATOR + file.fileName
		var size: UInt64
		if (file.type == BaseFileType.Directory) {
			size = getSize(fileName)
		} else {
			size = getSize(fileName)
		}
		
		file.size = size
		if (Verbose) {
			print("AndroidHandler, Sizes:", file);
		}
	}
	
	fileprivate func adbListData(_ directory: String) -> String {
		let name = AndroidHandler.ESCAPE_DOUBLE_QUOTES + "$name" + AndroidHandler.ESCAPE_DOUBLE_QUOTES
//		For every type of file, size calc:
//		let commands = "cd "+AndroidHandler.ESCAPE_DOUBLE_QUOTES+directory+AndroidHandler.ESCAPE_DOUBLE_QUOTES+"; ls | for name in *; do echo "+name+"; if [ -d "+name+" ]; then echo "+AndroidHandler.ESCAPE_DOUBLE_QUOTES+HandlerConstants.DIRECTORY+AndroidHandler.ESCAPE_DOUBLE_QUOTES+"; else echo "+AndroidHandler.ESCAPE_DOUBLE_QUOTES+HandlerConstants.FILE+AndroidHandler.ESCAPE_DOUBLE_QUOTES+"; fi; du -sk "+name+"; done;"
//		let commands = "cd " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + directory + AndroidHandler.ESCAPE_DOUBLE_QUOTES + "; ls | for name in *; do echo " + name + "; if [ -d " + name + " ]; then echo " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + HandlerConstants.DIRECTORY + AndroidHandler.ESCAPE_DOUBLE_QUOTES + "; echo \"0\"; else echo " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + HandlerConstants.FILE + AndroidHandler.ESCAPE_DOUBLE_QUOTES + "; du -sk " + name + "; fi; done;"

//		var lsSizeCommand: String
//		var lsSizeCommandName: String
//		if (AndroidHandler.JAVA_TYPE == AndroidHandler.GNU_TYPE) {
//			lsSizeCommand = AndroidHandler.GNU_LS_SIZE_COMMAND
//			lsSizeCommandName = AndroidHandler.GNU_LS_SIZE_COMMAND_NAME
//		} else if (AndroidHandler.JAVA_TYPE == AndroidHandler.BSD_TYPE) {
//			lsSizeCommand = AndroidHandler.GNU_LS_SIZE_COMMAND
//			lsSizeCommandName = AndroidHandler.GNU_LS_SIZE_COMMAND_NAME
//		} else {
//			lsSizeCommand = AndroidHandler.SOLARIS_LS_SIZE_COMMAND
//			lsSizeCommandName = AndroidHandler.SOLARIS_LS_SIZE_COMMAND_NAME
//		}
		var commands: String
		if (AndroidHandler.sJavaType == AndroidHandler.GNU_TYPE) {
			commands = AndroidHandler.GNU_LS_FILE_SIZE
		} else if (AndroidHandler.sJavaType == AndroidHandler.BSD_TYPE) {
			commands = AndroidHandler.GNU_LS_FILE_SIZE
		} else {
			commands = AndroidHandler.SOLARIS_LS_FILE_SIZE
		}
		//TODO: While retrieving ls output and appending FILE etc, remove illegal characters (like "\n")
		commands = commands + "cd " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + directory + AndroidHandler.ESCAPE_DOUBLE_QUOTES + "; ls | for name in *; do echo " + name +
				"; if [ -d " + name + " ]; then echo " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + HandlerConstants.DIRECTORY + AndroidHandler.ESCAPE_DOUBLE_QUOTES + "; echo \"0\"; else echo " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + HandlerConstants.FILE + AndroidHandler.ESCAPE_DOUBLE_QUOTES + "; " + AndroidHandler.LS_FILE_SIZE_COMMAND + " " + name + "; fi; done;"
////		lsSizeCommand = lsSizeCommand.stringByReplacingOccurrencesOfString("ls |", withString: "cd /sdcard; ls |")
//		lsSizeCommand = lsSizeCommand.stringByReplacingOccurrencesOfString("ls |", withString: "cd " + currentPath + "; ls |")
//		let output = adbShell(lsSizeCommand)
        
        LogV("Adb List Data", directory, ", Command:", commands)
		let output = adbShell(commands)
		if (EXTREME_VERBOSE) {
//			print("Output:", output)
		}
		return output
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
	
	func isDirectory(_ fileName: String) -> Bool {
		let directory = currentPath;
		let commands = "cd " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + directory + AndroidHandler.ESCAPE_DOUBLE_QUOTES + "; [ -d " + AndroidHandler.ESCAPE_DOUBLE_QUOTES + directory + HandlerConstants.SEPARATOR + fileName + AndroidHandler.ESCAPE_DOUBLE_QUOTES + " ] && echo \"" + HandlerConstants.DIRECTORY + "\";";
		let output = adbShell(commands);
		let isDir = output.contains(HandlerConstants.DIRECTORY)
		if (Verbose) {
			print("Dir?", directory + HandlerConstants.SEPARATOR + fileName, isDir, output, commands)
		}
		return isDir;
    }
    
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
	
	fileprivate func adb(_ commands: String) -> String {
		self.startAdbIfNotStarted()
		
		let task = Process()
		task.launchPath = adbLaunchPath
		task.arguments = ["-l", "-c", commands]
		task.currentDirectoryPath = adbDirectoryPath
		
		let pipe = Pipe()
		task.standardOutput = pipe
		
		task.launch()
		
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
		if (EXTREME_VERBOSE) {
			print("Commands:", commands)
		}
		if (EXTREME_VERBOSE) {
			print(output!)
		}
		
		task.waitUntilExit()
		return output! as String
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
	
	fileprivate func adbShell(_ commands: String) -> String {
		if (activeDevice != nil) {
			var adbCommand = "./adb -s " + (activeDevice?.id)!
			adbCommand = adbCommand + " shell " + "'" + commands + "'"
//			adbCommand = adbCommand + " shell; " + "" + commands + ""
			if (Verbose) {
//				print("Adb Command:", adbCommand)
			}
			return adb(adbCommand)
		} else {
			print("Warning, trying shell, no active")
			return ""
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
