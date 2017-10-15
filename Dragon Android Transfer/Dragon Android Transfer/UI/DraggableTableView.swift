//
//  DraggableTableView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 14/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation
import Cocoa

class DraggableTableView: NSTableView, NSTableViewDataSource {
	public static let kPasteBoardType = NSFilenamesPboardType
	public static let kWritableType = kPasteboardTypeFileURLPromise
	private static let kFakeDraggableItem = DraggableItem()
	private var mData = [DraggableItem]()
	private var mFinderCopyItem: DraggableItem? = nil
	public var dragDelegate: DragNotificationDelegate? = nil
	public let kPasteboardTypePasteLocation = "com.apple.pastelocation"
    public var draggedRows: IndexSet = []
	
	func updateList(data: [DraggableItem]) {
		self.mData = data
//		LogI("Update List", mData)
		reloadData()
	}
	
	func addItem(item: DraggableItem) {
		mData.append(item)
		reloadData()
	}
	
	func getData() -> [DraggableItem] {
		return mData
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return mData.count
	}
	
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        let emptyList = mData.count == 0
		if (dropOperation == .above) {
            if (emptyList) {
                return [.copy]
            } else {
				return []
            }
		} else {
            if info.draggingSource() == nil {
                return [.copy]
            } else {
                return []
            }
		}
	}
    
    override func dragImageForRows(with dragRows: IndexSet, tableColumns: [NSTableColumn], event dragEvent: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
        draggedRows = dragRows
        LogI("Drag Rows", draggedRows)
        return super.dragImageForRows(with: dragRows, tableColumns: tableColumns, event: dragEvent, offset: dragImageOffset)
    }
	
	
	func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
		let pb = info.draggingPasteboard()
		if let itemData = pb.pasteboardItems?.first?.data(forType: kUTTypeFileURL as String),
		   let path = (URL(dataRepresentation: itemData, relativeTo: nil)?.path) {
            var data: DraggableItem
            let emptyList = mData.count == 0
            if (emptyList) {
                data = TransferHandler.sharedInstance.getCurrentPathFile()
            } else {
                data = mData[row]
            }
			LogV("Copy from Finder, file:[", path + "] into app item:", data)
			if let nonNilDelegate = dragDelegate {
				nonNilDelegate.dragItem(item: path, fromFinderIntoAppItem: data)
            }
            mFinderCopyItem = nil
			return true
        }
        mFinderCopyItem = nil
		
		return false
	}
	
	func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
		mFinderCopyItem = mData[row]
		return DraggableTableView.kFakeDraggableItem
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		register(forDraggedTypes: [DraggableTableView.kPasteBoardType])
		setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
		headerView = nil
		allowsMultipleSelection = true
		verticalMotionCanBeginDrag = true
		dataSource = self
	}

//    Copying to Finder, drop destination
	override func draggingEnded(_ sender: NSDraggingInfo?) {
		let pb = sender?.draggingPasteboard()
		if (pb?.types?.contains(kPasteboardTypePasteLocation))! {
			let url = NSURL(string: (pb?.string(forType: kPasteboardTypePasteLocation))!)
			if let finderCopyItem = mFinderCopyItem, let copyPath = url?.absoluteURL?.path {
                LogV("Copy from app item:", finderCopyItem, "to", copyPath)
				if let nonNilDelegate = dragDelegate {
					nonNilDelegate.dragItem(item: finderCopyItem, fromAppToFinderLocation: copyPath)
				}
			} else {
//                LogE("Cannot Copy!")
			}
		}
        mFinderCopyItem = nil
	}
}
