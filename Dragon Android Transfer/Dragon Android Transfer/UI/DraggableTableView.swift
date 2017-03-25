//
//  DraggableTableView.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 14/01/17.
//  Copyright © 2017 Untitled-TBA. All rights reserved.
//

import Foundation
import Cocoa

class DraggableTableView: NSTableView {
	var droppedFilePath: String?
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		register(forDraggedTypes: [NSFilenamesPboardType, NSURLPboardType, NSPasteboardTypeTIFF])
	}
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
//        if checkExtension(sender) {
//            fileTypeIsOk = true
		return .copy
//        } else {
//            fileTypeIsOk = false
//            return .None
//        }
	}
	
	override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
//        if fileTypeIsOk {
		return .copy
//        } else {
//            return .None
//        }
	}
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		if let board = sender.draggingPasteboard().propertyList(forType: "NSFilenamesPboardType") as? NSArray,
		let imagePath = board[0] as? String {
// THIS IS WERE YOU GET THE PATH FOR THE DROPPED FILE
			droppedFilePath = imagePath
			Swift.print("Dropped File:", droppedFilePath)
			return true
		}
		return false
	}
}
