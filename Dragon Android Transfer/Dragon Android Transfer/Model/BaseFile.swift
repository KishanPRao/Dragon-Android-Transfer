//
//  BaseFile.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 25/12/16.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Cocoa


public class BaseFile: DraggableItem/*, CustomDebugStringConvertible*/ {
	//	internal let TAG = "BaseFile"
	var fileName: String = ""
	var path: String = ""
	var type: Int
	var size: Number
	
	//    UI Specific:
	//    var index: Int = -1
	
	init(fileName: String, path: String, type: Int, size: Number) {
		self.fileName = fileName
		self.path = path
		self.type = type
		self.size = size
	}
	
	func getFullPath() -> String {
		return path + HandlerConstants.SEPARATOR + fileName
	}
	
	public override var description: String {
		return "BaseFile: \(fileName, path, type, size)"
	}
	
	//    func writingOptions(forType type: String, pasteboard: NSPasteboard) -> NSPasteboardWritingOptions {
	//
	//        if self is DraggableItem {
	//            LogV("Draggable!")
	//            if self is NSPasteboardWriting {
	//                LogI("Pasteboard Item!!")
	//            } else {
	//                LogV("Not Pboard!")
	//            }
	//        }
	//        else {
	//            LogI("Not Dragg")
	//        }
	//
	//        //        kPasteBoardType
	//        pasteboard.declareTypes([NSFilenamesPboardType], owner: self)
	//        //		LogV("writingOptions", type, pasteboard, type)
	//        return sFakeUrl.writingOptions(forType: type, pasteboard: pasteboard)
	//    }
	//
	//    func writableTypes(for pasteboard: NSPasteboard) -> [String] {
	//        if self is DraggableItem {
	//            LogV("Draggable!")
	//            if self is NSPasteboardWriting {
	//                LogI("Pasteboard Item!!")
	//            } else {
	//                LogV("Not Pboard!")
	//            }
	//        }
	//        else {
	//            LogI("Not Dragg")
	//        }
	//
	//        //		LogV("writableTypes")
	//        return [kWritableType]
	//    }
	//
	//    func pasteboardPropertyList(forType type: String) -> Any? {
	//        if self is DraggableItem {
	//            LogV("Draggable!")
	//            if self is NSPasteboardWriting {
	//                LogI("Pasteboard Item!!")
	//            } else {
	//                LogV("Not Pboard!")
	//            }
	//        }
	//        else {
	//            LogI("Not Dragg")
	//        }
	//
	//        //		LogV("pasteboardPropertyList")
	//        //        return DraggableItem.sFakeUrl.pasteboardPropertyList(forType: type)
	//        return self.index
	//    }
}
