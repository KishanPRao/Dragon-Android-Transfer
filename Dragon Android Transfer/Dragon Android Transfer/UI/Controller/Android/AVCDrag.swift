//
//  AVCDrag.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension AndroidViewController {
    
    func dragItem(items: [DraggableItem], fromAppToFinderLocation location: String) {
        LogI("Drag (to Finder) ", items, "->", location)
        
        var copyItemsAndroid: Array<BaseFile> = []
        for item in items {
            copyItemsAndroid.append(item as! BaseFile)
        }
        print("Copy:", copyItemsAndroid)
        transferHandler.updateClipboardAndroidItems(copyItemsAndroid)
        
        startTransfer()
        transferVc?.pasteToMac(location)
    }
    
    func dragItem(items: [String], fromFinderIntoAppItem appItem: DraggableItem) {
        LogI("Drag (to App)", items, "->", appItem)
        
        var copyItemsMac: Array<BaseFile> = []
        transferHandler.clearClipboardMacItems()
        transferHandler.clearClipboardAndroidItems()
        //        copyItemsMac = transferHandler.getActiveFiles()
        copyItemsMac.removeAll()
        let dropDestination = (appItem as! BaseFile)
        var dropDestinationPath: String
        if (dropDestination.type == BaseFileType.File) {
            dropDestinationPath = dropDestination.path
        } else {
            dropDestinationPath = dropDestination.getFullPath()
        }
        
        let fileManager = FileManager.default
        //        do {
        for item in items {
            let path = item.stringByDeletingLastPathComponent + HandlerConstants.SEPARATOR
            var isDirectory: ObjCBool = false
            fileManager.fileExists(atPath: item, isDirectory: &isDirectory)
            var type: Int
            if (isDirectory).boolValue {
                type = BaseFileType.Directory
            } else {
                type = BaseFileType.File
            }
            let name = item.lastPathComponent
            //            var attr = try fileManager.attributesOfItem(atPath: item)
            //            let fileSize = attr[FileAttributeKey.size] as! Number
            let file = BaseFile.init(fileName: name, path: path, type: type, size: 0)
            LogI("File", file)
            copyItemsMac.append(file)
        }
        transferHandler.updateClipboardMacItems(copyItemsMac)
        //		updateClipboard()
        
        
        startTransfer()
        transferVc?.pasteToAndroid(dropDestinationPath)
        //        } catch _ {
        //        	LogE("Cannot copy into app!")
        //        }
    }
    
    func onDropDestination(_ row: Int) {
        if (row >= self.androidDirectoryItems.count || row < 0) {
//            LogV("Warning: Drop Row out of range: \(row)")
            return
        }
        let isDirectory = androidDirectoryItems[row].type == BaseFileType.Directory
        if (!isDirectory && fileTable.dragDropRow == row) {
            //            ThreadUtils.runInMainThread({
            //            	self.fileTable.backgroundColor = self.tableSelectedBgColor
            //            })
            let color = ColorUtils.colorWithHexString(ColorUtils.listSelectedBackgroundColor) as NSColor
            fileTable.layer?.borderWidth = 2
            //            TODO: Set color only once!
            fileTable.layer?.borderColor = color.cgColor
        } else {
            fileTable.layer?.borderWidth = 0
            //            fileTable.layer.borderColor = UIColor.black.cgColor
            //            ThreadUtils.runInMainThread({
            //                self.fileTable.backgroundColor = self.tableBgColor
            //            })
        }
    }
    
    func onDragCompleted() {
        fileTable.layer?.borderWidth = 0
    }
}
