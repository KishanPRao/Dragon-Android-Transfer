//
// Created by Kishan P Rao on 14/10/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class DraggableItem: NSObject, NSPasteboardWriting {
//: NSObject, NSPasteboardWriting {
	static let sFakeLocation = "fakeLocation"
	static let sFakeUrl = NSURL(string: sFakeLocation)!

    var index: Int = -1

	//      Copying to Finder
	func writingOptions(forType type: String, pasteboard: NSPasteboard) -> NSPasteboardWritingOptions {
//        kPasteBoardType
		pasteboard.declareTypes([NSFilenamesPboardType], owner: self)
//		LogV("writingOptions", type, pasteboard, type)
		return DraggableItem.sFakeUrl.writingOptions(forType: type, pasteboard: pasteboard)
	}

	func writableTypes(for pasteboard: NSPasteboard) -> [String] {
//		LogV("writableTypes")
		return [kWritableType]
	}

	func pasteboardPropertyList(forType type: String) -> Any? {
//		LogV("pasteboardPropertyList")
//        return DraggableItem.sFakeUrl.pasteboardPropertyList(forType: type)
        return index
	}
}
