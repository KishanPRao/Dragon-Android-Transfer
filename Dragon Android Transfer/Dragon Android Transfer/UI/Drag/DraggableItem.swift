//
// Created by Kishan P Rao on 14/10/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

public class DraggableItem: NSObject, NSPasteboardWriting {
//: NSObject, NSPasteboardWriting {
	static let sFakeLocation = "fakeLocation"
	static let sFakeUrl = NSURL(string: sFakeLocation)!

    var index: Int = -1

	//      Copying to Finder
	public func writingOptions(forType type: NSPasteboard.PasteboardType, pasteboard: NSPasteboard) -> NSPasteboard.WritingOptions {
//        kPasteBoardType
		pasteboard.declareTypes([kPasteBoardType], owner: self)
//		LogV("writingOptions", type, pasteboard, type)
		return DraggableItem.sFakeUrl.writingOptions(forType: type, pasteboard: pasteboard)
	}

	public func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
//		LogV("writableTypes")
		return [NSPasteboard.PasteboardType(rawValue: kWritableType)]
	}

	public func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
//		LogV("pasteboardPropertyList")
//        return DraggableItem.sFakeUrl.pasteboardPropertyList(forType: type)
        return index
	}
}
