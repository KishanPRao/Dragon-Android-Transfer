//
//  Utils.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 09/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class Utils {
    static func getFilesFor(directory dirPath: String) -> ([String]?, UInt64) {
        var files = [String]()
        var totalSize = 0 as UInt64
        do {
            let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
            let enumerator = FileManager.default.enumerator(at: URL(fileURLWithPath: dirPath),
                                                            includingPropertiesForKeys: resourceKeys,
                                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                print("directoryEnumerator error at \(url): ", error)
                                                                return true
            })!
            
            for case let fileURL as URL in enumerator {
                let resourceValues = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                //                print(fileURL.path, resourceValues.creationDate!, resourceValues.isDirectory!)
                if (!resourceValues.isDirectory!) {
                    var path = fileURL.path
                    totalSize += (getFileSize(path))
                    //                    let parentPath = (dirPath as NSString).deletingLastPathComponent
                    path = path.replacingOccurrences(of: "\(dirPath)/", with: "")
                    files.append(path)
                }
            }
        } catch {
            print(error)
        }
        //        for file in files {
        //            print("File: \(file)")
        //        }
        return (files, totalSize)
    }
    
    static func getFileSize(_ path: String) -> UInt64 {
        var fileSize : UInt64 = 0
        do {
            //                        TODO: Write extension to String, removeEndFileSep()
            let attr = try FileManager.default.attributesOfItem(atPath: path)
            fileSize = attr[FileAttributeKey.size] as! UInt64
            let dict = attr as NSDictionary
            fileSize = dict.fileSize()
        } catch {
            print("File size retrieval error: \(error)")
        }
        return fileSize
    }
}

extension Data {
    
    init<T>(from value: T) {
        var value = value
        self.init(buffer: UnsafeBufferPointer(start: &value, count: 1))
    }
    
    func to<T>(type: T.Type) -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}
