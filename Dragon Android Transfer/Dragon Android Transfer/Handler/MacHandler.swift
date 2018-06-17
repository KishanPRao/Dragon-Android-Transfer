//
//  MacHandler.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 14/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation


class MacHandler: NSObject {
	let ESCAPE_DOUBLE_QUOTES = "\""
	static let FINDER_ACTIVE_SCRIPT =
			"on isFinderActive()\n" +
					"tell application \"System Events\"\n" +
					"set activeApp to name of first application process whose frontmost is true\n" +
					"if \"Finder\" is in activeApp then\n" +
					"return true\n" +
					"else\n" +
					"return false\n" +
					"end if\n" +
					"end tell\n" +
					"end isFinderActive\n"
	
	static let RUNNABLE_FINDER_ACTIVE_SCRIPT =
			MacHandler.FINDER_ACTIVE_SCRIPT +
					"return isFinderActive()\n"
	
	func isFinderActive() -> Bool {
		Swift.print("isFinderActive, ", TimeUtils.getCurrentTime())
		var result = false
		if (runScript(MacHandler.RUNNABLE_FINDER_ACTIVE_SCRIPT) == "true") {
			result = true
		}
		
		print("Result:" + String(result), TimeUtils.getCurrentTime())
		return result
	}
	
	func getActivePath() -> String {
		Swift.print("getActivePath, ")
		let script =
				"tell application \"Finder\"\n" +
						"try\n" +
						"return POSIX path of (target of window 1 as alias)\n" +
						"on error errmess\n" +
						"return POSIX path of (path to Desktop Folder)\n" +
						"end try\n" +
						"end tell"
		
		let path = runScript(script)
		
		print("Path:" + path)
		
		return path
	}
	
	func runScript(_ script: String) -> String {
//        print("Script:", script)
		var output = "";
		var error: NSDictionary?
		if let scriptObject = NSAppleScript(source: script) {
			if let scriptOutput: NSAppleEventDescriptor = scriptObject.executeAndReturnError(
					&error) {
//                print(scriptOutput.stringValue)
				output = scriptOutput.stringValue!
			} else if (error != nil) {
				print("error: \(error)")
			}
		}
		return output
	}

//	func getFileSize(fileName: String) -> Number {
//		var size = 0 as Number
//		let script = "set fileName to (POSIX file \"" + fileName + "\" as alias)\n" +
//				"tell application \"Finder\" to set fileSize to size of file fileName\n" +
//				"return fileSize"
//		print("Script to Run:", script)
//		size = Number(runScript(script))!
//		print("Size:" + String(size))
//		return size
//	}
	
	fileprivate func bashShell(_ commands: String) -> String {
		let task = Process()
		task.launchPath = "/bin/bash"
		task.arguments = ["-l", "-c", commands]
		
		let pipe = Pipe()
		task.standardOutput = pipe
		
		task.launch()
		
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
		if (NSObject.VERBOSE) {
			print("Args:", commands, ":")
		}
		if (NSObject.VERBOSE) {
			print("Op:", output!)
		}
		
		task.waitUntilExit()
		return output! as String
	}
	
    func getSize(_ directoryName: String) -> Number {
//        let startTime = TimeUtils.getCurrentTime()
        let startDispatch = TimeUtils.getDispatchTime()
        var size = 0 as Number
//        let directoryURL = URL(fileURLWithPath: directoryName)
//        size = Number(BridgingUtils.nr_getAllocatedSize(URL(fileURLWithPath: directoryName), error: nil))
        
        size = getSizeFind(directoryName)
        
//        print("Size: \(size), start: \(startTime), end: \(TimeUtils.getCurrentTime())")
        
        let nanoTime = TimeUtils.getDispatchTime().uptimeNanoseconds - startDispatch.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        print("Size: \(size), time taken: \(timeInterval)")
        
        /*let prefetchedProperties = [
            URLResourceKey.isRegularFileKey,
            URLResourceKey.fileAllocatedSizeKey,
            URLResourceKey.totalFileAllocatedSizeKey,
        ];
        let enumerator = FileManager.default.enumerator(at: directoryURL,
                                                        includingPropertiesForKeys: prefetchedProperties,
                                                        options: FileManager.DirectoryEnumerationOptions(rawValue: 0),
                                                        errorHandler: nil)
        
        for contentItemURL in enumerator! {
            if let contentItemURL = contentItemURL as? NSURL {
                var fileSize: AutoreleasingUnsafeMutablePointer<NSNumber?> = nil
                
                
                contentItemURL.getResourceValue(fileSize, forKey: NSURLTotalFileAllocatedSizeKey)
                
                print("File Size: \(fileSize), \(fileSize.pointee?.doubleValue)")
            }
        }*/
        return size
    }
    
    func getSizeFind(_ directoryName: String) -> Number {
        var size = 0 as Number
        let command = "find " + ESCAPE_DOUBLE_QUOTES + directoryName + ESCAPE_DOUBLE_QUOTES + " ! -type d -print0 | xargs -0 stat -f '%z' | awk '{sum += $1} END{print sum}'"
//        print("Command to Run:", command)
        let output = bashShell(command)
        let outputStringArray = output.split {
            $0 == " " || $0 == "\t"
            }.map(String.init)
        print("Output:", outputStringArray)
        let maxSizeInMBytes = Number.max / 1024
        if let sizeInInt = Number(ShellParser.cleanString(outputStringArray[0])) {
            size = sizeInInt / 1024 //KB
            if (size > maxSizeInMBytes) {
                size = Number.max
            } else {
                size = size * 1024
            }
            //            size = sizeInInt
        }
        print("Size:" + String(size))
        return size
    }
    
	func getSizeDu(_ directoryName: String) -> Number {
		var size = 0 as Number
//		let command = "cd "+ESCAPE_DOUBLE_QUOTES+directoryName+ESCAPE_DOUBLE_QUOTES+"; du -sk;"
		let command = "du -sk " + ESCAPE_DOUBLE_QUOTES + directoryName + ESCAPE_DOUBLE_QUOTES + ";"
		print("Command to Run:", command)
		let output = bashShell(command)
		let outputStringArray = output.split {
			$0 == " " || $0 == "\t"
		}.map(String.init)
		print("Output:", outputStringArray)
		let maxSizeInMBytes = Number.max / 1024
		if let sizeInInt = Number(outputStringArray[0]) {
			size = sizeInInt
			if (size > maxSizeInMBytes) {
				size = Number.max
			} else {
				size = size * 1024
			}
//			size = sizeInInt
		}
		print("Size:" + String(size))
//		du -s
		return size
	}
	
	func getActiveFiles() -> Array<BaseFile>! {
		var path = getActivePath()
		let script =
				"tell application \"Finder\"\n" +
						"set names to \"\"\n" +
						"set theItems to selection\n" +
//        "display dialog number of theItems\n" +
				"repeat with itemRef in theItems\n" +
//        "display dialog (name of itemRef) as string\n" +
				"set names to names & (name of itemRef) & \"\n\"\n" +
				"end repeat\n" +
				"return names\n" +
				"end tell\n"
		let output = runScript(script)
		let outputNames = output.split {
			$0 == "\n" || $0 == "\r\n"
		}.map(String.init)
		print("Names:", outputNames)
		if (outputNames.count == 1) {
			let lastComponent = (path as NSString).lastPathComponent
//            print("Last Comp:", lastComponent," Path:", path)
			if (lastComponent == outputNames[0]) {
				path = (path as NSString).deletingLastPathComponent + HandlerConstants.SEPARATOR
			}
		}
		print("Path:", path)
		var i = 0;
		var activeFiles: Array<BaseFile> = [];
		while i < outputNames.count {
			let fileName = path + outputNames[i]
			let fileTypeScript = "tell application \"System Events\"\n" +
					"set fileName to (POSIX file \"" + fileName + "\" as alias)\n" +
					"if fileName is package folder or kind of fileName is \"Folder\" or kind of fileName is \"Volume\" then\n" +
					"return \"" + HandlerConstants.DIRECTORY + "\"\n" +
					"else\n" +
					"return \"" + HandlerConstants.FILE + "\"\n" +
					"end if\n" +
					"end tell\n"
			if (NSObject.VERBOSE) {
				print("Script:", fileTypeScript)
			}
			let output = runScript(fileTypeScript)
			var type: Int
//			var size: Number
			if (output.contains(HandlerConstants.DIRECTORY)) {
				type = BaseFileType.Directory;
//				size = getSize(fileName)
			} else {
				type = BaseFileType.File;
//				size = getSize(fileName)
//				size = getFileSize(fileName)
			}
			
			activeFiles.append(BaseFile.init(fileName: outputNames[i], path: path, type: type, size: 0))
//            print("Name:", outputNames[i], " Type:", output)
			i = i + 1
		}
//        print("Active Files", activeFiles)
		return activeFiles
	}
	
	func updateSizes(_ files: Array<BaseFile>) {
//		var activeFiles: Array<BaseFile> = [];
		var i = 0;
		while i < files.count {
			let fileName = files[i].path + files[i].fileName
			var size: Number
			if (files[i].type == BaseFileType.Directory) {
				size = getSize(fileName)
			} else {
				size = getSize(fileName)
//				size = getFileSize(fileName)
			}
			
			files[i].size = size

//			activeFiles.append(BaseFile.init(fileName: outputNames[i], path: path, type: type, size: size))
//            print("Name:", outputNames[i], " Type:", output)
			i = i + 1
		}
		if (NSObject.VERBOSE) {
			Swift.print("MacHandler, Sizes:", files);
		}
	}
}
