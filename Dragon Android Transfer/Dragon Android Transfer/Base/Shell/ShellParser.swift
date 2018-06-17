//
//  ShellParser.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 24/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Cocoa
import Foundation

@objcMembers
public class ShellParser: NSObject {
	static let EXTREME_VERBOSE = false
	static let BLOCK_SIZE_IN_FLOAT = Float(1024)
	
	static fileprivate func splitLines(_ string: String) -> [String] {
		return string.split {
			$0 == "\n" || $0 == "\r\n"
		}.map(String.init)
	}
	
	static func isFileTypeString(str: String) -> Bool {
		return str.contains(HandlerConstants.DIRECTORY) || str.contains(HandlerConstants.FILE);
	}
	
	public static func parseListOutput(_ data: String, currentPath: String) -> [BaseFile] {
		let listString = data;
		var directories: [BaseFile] = [];
		let outputInLines = splitLines(listString)
		var noOutput = false
//        print("List Output:", outputInLines)
		noOutput = outputInLines.count <= 0 || outputInLines.count <= 2 || (outputInLines.count == 3 && outputInLines[2].contains("No such file"))
		//		noOutput = outputInLines.count <= 0 || outputInLines.count <= 2
		if (noOutput) {
			print("No Output!!!!")
			//			print("Output:", outputInLines)
			return directories
		}
		var i = 0
		let maxSizeInMBytes = Number.max / 1024
		while (i < outputInLines.count) {
			var fileType = BaseFileType.File;
			var sizeInKiloBytes = Number.max as Number
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
			i = i + 1
			if (fileType == BaseFileType.File) {
				let sizeStringArray = outputInLines[i].split {
					$0 == " " || $0 == "\t"
				}.map(String.init)
				if let sizeInInt = Number(sizeStringArray[0]) {
					sizeInKiloBytes = sizeInInt
					if (sizeInKiloBytes > maxSizeInMBytes) {
						sizeInKiloBytes = Number.max
					} else {
						sizeInKiloBytes = sizeInKiloBytes * 1024
					}
					//				sizeInBytes = sizeInInt
				}
			} else {
				sizeInKiloBytes = 0
			}
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
	
	public static func parseDeviceListOutput(_ devicesString: String) -> [String] {
		var androidDevices = [String]()
		
		let devices = splitLines(devicesString)
		var i = 1
		while i < devices.count {
			let deviceId = devices[i].split {
				$0 == "\t"
			}.map(String.init)[0]
			androidDevices.append(deviceId)
			i = i + 1
		}
		return androidDevices
	}
	
	//@objc
	public static func parseStorageOutput(_ fileNames: String, info output: String) -> Array<StorageItem> {
		var storages = [StorageItem]()
		storages.append(StorageItem(Path("Internal Storage", "/sdcard/Test/")))
		let outputLines = splitLines(output)
		let fileNamesLines = splitLines(fileNames)
		var skipLines = 0
		if (outputLines.count > 0 && outputLines[0].hasPrefix("total")) {
			skipLines = 1
		}
		var i = skipLines
		while (i < outputLines.count) {
			let line = outputLines[i]
			if (!line.contains("self") && !line.contains("emulated") && !line.contains("system")) {
				storages.append(StorageItem(Path("External Storage", "/storage/" + fileNamesLines[i - skipLines])))
			}
			i = i + 1
		}
		return storages
	}
	
	private static func parseSpaceOutput(_ output: String) -> [String] {
		let outputInLines = splitLines(output)
		if (outputInLines.count < 2) {
			print("Cannot update!")
			return []
		}
		let outputInTabs = outputInLines[1].split {
			$0 == " "
		}.map(String.init)
		return outputInTabs
	}
    
    /*
    @objc
    public static func parseTotalSpaceInInt(_ output: String) -> Number {
        var spaceInInt = 0
        let outputInTabs = parseSpaceOutput(output)
        if (outputInTabs.count == 0) {
            return spaceInInt
        }
        if let totalSpaceInInt = Number(outputInTabs[1]) {
            //            totalSpace = totalSpaceInInt * Number(BLOCK_SIZE_IN_FLOAT)
            spaceInInt = totalSpaceInInt * Number(BLOCK_SIZE_IN_FLOAT)
        } else {
            //            Solaris
            spaceInInt = outputInTabs[1]
        }
        return spaceInInt
    }*/
    
    @objc
    public static func parseTotalSpace(_ output: String) -> String {
        var spaceInString = SizeUtils.ZERO_BYTES
        let outputInTabs = parseSpaceOutput(output)
        if (outputInTabs.count == 0) {
            return spaceInString
        }
        if let totalSpaceInInt = Number(outputInTabs[1]) {
            //            totalSpace = totalSpaceInInt * Number(BLOCK_SIZE_IN_FLOAT)
            spaceInString = SizeUtils.getBytesInFormat(totalSpaceInInt * Number(BLOCK_SIZE_IN_FLOAT))
        } else {
            //            Solaris
            spaceInString = outputInTabs[1] + " B"
        }
        if (EXTREME_VERBOSE) {
            //            print("Output:", outputInTabs)
        }
        if (EXTREME_VERBOSE) {
            //            print("Total:", totalSpace)
        }
        return spaceInString
    }
	
	@objc
	public static func parseAvailableSpace(_ output: String) -> String {
		var spaceInString = SizeUtils.ZERO_BYTES
		let outputInTabs = parseSpaceOutput(output)
		if (outputInTabs.count == 0) {
			return spaceInString
		}
		if let totalSpaceInInt = Number(outputInTabs[1]) {
			if let usedSpaceInInt = Number(outputInTabs[2]) {
				let availableSpaceInInt = (totalSpaceInInt - usedSpaceInInt) * Number(BLOCK_SIZE_IN_FLOAT) as Number
				spaceInString = SizeUtils.getBytesInFormat(availableSpaceInInt)
			}
		} else {
//			Solaris
			spaceInString = outputInTabs[3] + " B"
		}
		return spaceInString
	}
	
	@objc
	public static func parseFileExists(_ rawOutput: String) -> Bool {
		let output = rawOutput.replacingOccurrences(of: "\r\n", with: "").replacingOccurrences(of: "\n", with: "")
		let exists = (output == HandlerConstants.EXIST)
		Swift.print("AndroidHandler, exists:", exists)
		return exists
	}
	
	@objc
	public static func parseFileSize(_ rawOutput: String) -> UInt64 {
		let maxSizeInMBytes = Number.max / 1024
		var sizeInBytes = Number.max as Number
		let sizeStringArray = cleanString(rawOutput).split {
			$0 == " " || $0 == "\t"
		}.map(String.init)
		if sizeStringArray.count > 0, let sizeInInt = Number(sizeStringArray[0]) {
            sizeInBytes = sizeInInt
//            sizeInBytes = sizeInInt / 1024 //KB
			if (sizeInBytes > maxSizeInMBytes) {
				sizeInBytes = Number.max
			} else {
				sizeInBytes = sizeInBytes * 1024
			}
		}
		return sizeInBytes
	}
	
	@objc
	public static func cleanString(_ rawString: String) -> String {
		let cleanString = rawString.trimmingCharacters(
				in: CharacterSet.whitespacesAndNewlines
		)
		return cleanString
	}
	
	@objc
	public static func parseDeviceInfoOutput(_ devId: String, infoString: String) -> AndroidDeviceMac {
		let deviceName = ShellParser.cleanString(infoString)
		let deviceId = ShellParser.cleanString(devId)
		let device = AndroidDeviceMac.init(id: deviceId, name: deviceName)
		return device
	}
	
	
	static let regexPercentage = "\\[.*%\\]"
	static let regexFileName = "[^/]*$"
	
	private static func matchesForRegexInText(_ regex: String, text: String) -> [String] {
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
	
	@objc
	public static func parseTransferOutput(_ output: String) -> Int {
		let outputLines = splitLines(output)
		let output = outputLines[outputLines.count - 1]
//        print("parseTransferOutput: \(output)")
		let matchesPercentage = self.matchesForRegexInText(self.regexPercentage, text: output)
		if (matchesPercentage.count > 0) {
			var progressString = matchesPercentage[0]
			progressString.remove(at: progressString.startIndex)
			progressString.remove(at: progressString.index(before: progressString.endIndex))
			progressString.remove(at: progressString.index(before: progressString.endIndex))
			progressString = cleanString(progressString)
			let progress = Int(progressString)
			return progress!
		}
		return -1
	}
}
