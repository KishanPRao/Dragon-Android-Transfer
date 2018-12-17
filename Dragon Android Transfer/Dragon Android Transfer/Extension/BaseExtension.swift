//
// Created by Kishan P Rao on 14/10/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

//TODO: What happens if 32 bit architecture?
typealias Number = UInt64

let DEBUG = true
//let DEBUG = false
let FILE_WRITE = false

extension Double {
    func roundUp() -> Double {
        return self < 0.0 ? 0.0 : self
    }
}

extension String {
    func appendLine(to url: URL) throws {
        try self.appending("\n").append(to: url)
    }
    func append(to url: URL) throws {
        let data = self.data(using: String.Encoding.utf8)
        try data?.append(to: url)
    }
}

extension Data {
    func append(to url: URL) throws {
        if let fileHandle = try? FileHandle(forWritingTo: url) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        } else {
            try write(to: url)
        }
    }
}


func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    if (DEBUG) {
        
        for item in items {
            Swift.print(item, separator: separator, terminator: terminator)
        }
        if (FILE_WRITE) {
        let path = "/Users/Kishan/dump.txt"
            for item in items {
                
                if let string = item as? String {
                    do {
                        let url = URL(fileURLWithPath: path)
    //                    try "Test \(NSDate())".appendLineToURL(url)
                        try string.appendLine(to: url)
    //                    let result = try String(contentsOfURL: url)
                    } catch {}
                }
            }
        }
    }
}

extension NSObject {
	class var VERBOSE: Bool {
		return DEBUG
	}
	
	var TAG: String {
		return String(describing: type(of: self))
	}

//    public func Print(_ items: Any...) {
//        PrintUtils.Print(TAG, items)
//    }
	
	var Verbose: Bool {
		return type(of: self).VERBOSE
	}
	
	public func LogE(_ items: Any...) {
		if (NSObject.VERBOSE && Verbose) {
			PrintUtils.Print(TAG, ["❗️", items])
		}
	}
	
	public func LogV(_ items: Any...) {
		if (NSObject.VERBOSE && Verbose) {
			PrintUtils.Print(TAG, ["✅", items])
		}
	}
	
	public func LogW(_ items: Any...) {
		if (NSObject.VERBOSE && Verbose) {
			PrintUtils.Print(TAG, ["⚠️", items])
		}
	}
	
	public func LogI(_ items: Any...) {
		if (NSObject.VERBOSE && Verbose) {
			PrintUtils.Print(TAG, ["🚹", items])
		}
	}
	
	public func LogD(_ items: Any...) {
		if (NSObject.VERBOSE && Verbose) {
			PrintUtils.Print(TAG, ["🗒", items])
		}
	}
	
	static func sendNotification(_ name: String, _ info: [AnyHashable: Any]? = nil) {
		//NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: object)
		NotificationCenter.default.post(name: Notification.Name(rawValue: name), object: nil, userInfo: info)
	}
	
	static func observeNotification(_ handler: Any, _ name: String, selector: Selector) {
		NotificationCenter.default.addObserver(handler, selector: selector, name: NSNotification.Name(rawValue: name), object: nil)
	}
    
    static func printStackTrace() {
        Thread.callStackSymbols.forEach{print($0)}
    }
}
