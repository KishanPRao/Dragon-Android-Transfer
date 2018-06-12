//
//  Log.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 12/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

/**
 Build a better logging when needed.
 */

/*
import Cocoa

enum LogEvent: String {
    case e = "[‼️]" // error
    case i = "[ℹ️]" // info
    case d = "[💬]" // debug
    case v = "[🔬]" // verbose
    case w = "[⚠️]" // warning
    case s = "[🔥]" // severe
}
extension Date {
    func toString() -> String {
        return Logger.dateFormatter.string(from: self as Date)
    }
}

class Log: NSObject {
    
    static var dateFormat = "yyyy-MM-dd hh:mm:ssSSS" // Use your own
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone.current
        return formatter
    }
    
    func print(_ object: Any) {
        // Only allowing in DEBUG mode
        #if DEBUG
            Swift.print(object)
        #endif
    }
    private class func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last!
    }
    class func e( _ object: Any,// 1
        filename: String = #file, // 2
        line: Int = #line, // 3
        column: Int = #column, // 4
        funcName: String = #function) {
        if isLoggingEnabled {
            print("\(Date().toString()) \(LogEvent.e.rawValue)[\(sourceFileName(filePath: filename))]:\(line) \(column) \(funcname) -> \(object)")
        }
    }
}*/
