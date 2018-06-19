//
// Created by Kishan P Rao on 14/10/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension NSObject {
	class var VERBOSE: Bool {
		return true
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
