//
//  ExtensionBaseFile.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 04/11/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension DraggableItem where Self :BaseFile {
    
    //      Copying to Finder
    func writingOptions(forType type: String, pasteboard: NSPasteboard) -> NSPasteboardWritingOptions {
        //        kPasteBoardType
        pasteboard.declareTypes([NSFilenamesPboardType], owner: self)
        //		LogV("writingOptions", type, pasteboard, type)
        return sFakeUrl.writingOptions(forType: type, pasteboard: pasteboard)
    }
    
    func writableTypes(for pasteboard: NSPasteboard) -> [String] {
        //		LogV("writableTypes")
        return [kWritableType]
    }
    
    func pasteboardPropertyList(forType type: String) -> Any? {
        //		LogV("pasteboardPropertyList")
        //        return DraggableItem.sFakeUrl.pasteboardPropertyList(forType: type)
        return self.index
    }
}
