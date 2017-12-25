//
//  ShellParser.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 24/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Cocoa
import Foundation

@objc
public class ShellParser : NSObject {
    
    static fileprivate func splitLines(_ string: String) -> [String] {
        return string.characters.split {
            $0 == "\n" || $0 == "\r\n"
            }.map(String.init)
    }
    
    static func isFileTypeString(str: String) -> Bool {
        return str.contains(HandlerConstants.DIRECTORY) || str.contains(HandlerConstants.FILE);
    }
    
    public static func parseListOutput(_ data: String) -> [BaseFile] {
        let EXTREME_VERBOSE = false
        let listString = data;
        var directories: [BaseFile] = [];
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
            i = i + 1
            if (fileType == BaseFileType.File) {
                let sizeStringArray = outputInLines[i].characters.split {
                    $0 == " " || $0 == "\t"
                    }.map(String.init)
                if let sizeInInt = UInt64(sizeStringArray[0]) {
                    sizeInKiloBytes = sizeInInt
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
            //directories.append(BaseFile.init(fileName: name, path: currentPath, type: fileType, size: sizeInKiloBytes))
            directories.append(BaseFile.init(fileName: name, path: "", type: fileType, size: sizeInKiloBytes))
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
            let deviceId = devices[i].characters.split {
                $0 == "\t"
                }.map(String.init)[0]
            androidDevices.append(deviceId)
            i = i + 1
        }
        return androidDevices
    }
    
    @objc
    public static func cleanString(_ rawString: String) -> String {
    	let cleanString = rawString.trimmingCharacters(
    		in: CharacterSet.whitespacesAndNewlines
    	)
    	return cleanString
    }
    
	@objc 
    public static func parseDeviceInfoOutput(_ devId: String, infoString: String) -> AndroidDevice {
		let deviceName = ShellParser.cleanString(infoString)
        let deviceId = ShellParser.cleanString(devId)
		let device = AndroidDevice.init(id: deviceId, name: deviceName)
        return device
    }
}
