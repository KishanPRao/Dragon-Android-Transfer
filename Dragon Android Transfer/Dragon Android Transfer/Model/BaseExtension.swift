//
// Created by Kishan P Rao on 14/10/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension NSObject {
	class var VERBOSE: Bool {
		return false
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
        if (NSObject.VERBOSE) {
        PrintUtils.Print(TAG, ["❗️", items])
        }
    }
    
    public func LogV(_ items: Any...) {
        if (NSObject.VERBOSE) {
        PrintUtils.Print(TAG, ["✅", items])
        }
    }
    
    public func LogW(_ items: Any...) {
        if (NSObject.VERBOSE) {
        PrintUtils.Print(TAG, ["⚠️", items])
        }
    }
    
    public func LogI(_ items: Any...) {
        if (NSObject.VERBOSE) {
        PrintUtils.Print(TAG, ["🚹", items])
        }
    }
    
    public func LogD(_ items: Any...) {
        if (NSObject.VERBOSE) {
        PrintUtils.Print(TAG, ["🗒", items])
        }
    }
}
