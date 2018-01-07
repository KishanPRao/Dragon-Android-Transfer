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
//	public static let kPasteBoardType = NSFilenamesPboardType
	private static let kFakeDraggableItem = BaseFile(fileName: "", path: "", type: 0, size: 0)
	private var mData = [BaseFile]()
	public var dragDelegate: DragNotificationDelegate? = nil
    public var dragUiDelegate: DragUiDelegate? = nil
    public let kPasteboardTypePasteLocation = "com.apple.pastelocation"
    public var draggedRows: IndexSet = []
    public var dragDropRow: Int = DRAG_DROP_NONE
    
    public var enableDrag = true
	
	func updateList(data: [BaseFile]) {
		self.mData = data
//		LogI("Update List", mData)
        for (i, element) in data.enumerated() {
            element.index = i
        }
		reloadData()
	}
	
	func addItem(item: BaseFile) {
		mData.append(item)
		reloadData()
	}
	
	func getData() -> [BaseFile] {
		return mData
	}
	
	func numberOfRows(in tableView: NSTableView) -> Int {
		return mData.count
	}
    
    func getDragDropRow() -> Int {
        return dragDropRow
    }
	
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if (!enableDrag) {
            return []
        }
        let emptyList = mData.count == 0
		if (dropOperation == .above) {
            if (emptyList) {
                let oldIndex = dragDropRow
                dragDropRow = DRAG_DROP_WHOLE
                deselectAllRows(oldIndex)
                return [.copy]
            } else if (row >= mData.count) {
                let oldIndex = dragDropRow
                dragDropRow = DRAG_DROP_WHOLE
                deselectAllRows(oldIndex)
                return [.copy]
            } else {
                return []
            }
		} else {
            if info.draggingSource() == nil {
                dragDropRow = row
                updateItemChanged(index: dragDropRow)
                if (dragUiDelegate != nil) {
                    dragUiDelegate?.onDropDestination(row)
                }
                return [.copy]
            } else {
                return []
            }
		}
	}
    
//    func tableView(_ tableView: NSTableView, writeRowsWith rowIndexes: IndexSet, to pboard: NSPasteboard) -> Bool {
//        LogI("writeRows!")
//        return true
//    }
    
//    override func dragImageForRows(with dragRows: IndexSet, tableColumns: [NSTableColumn], event dragEvent: NSEvent, offset dragImageOffset: NSPointPointer) -> NSImage {
//        draggedRows = dragRows
//        LogI("Drag Rows", draggedRows)
//        return super.dragImageForRows(with: dragRows, tableColumns: tableColumns, event: dragEvent, offset: dragImageOffset)
//    }
	
	
	func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        if (!enableDrag) {
            return false
        }
		let pb = info.draggingPasteboard()
        LogV("Pboard items", pb.pasteboardItems)
        var returnValue = false
        if let pboardItems = pb.pasteboardItems {
            var finderItems = [String]()
            for item in pboardItems {
                if let itemData = item.data(forType: kUTTypeFileURL as String),
                    let path = (URL(dataRepresentation: itemData, relativeTo: nil)?.path) {
                    finderItems.append(path)
                }
                returnValue = true
            }
            var data: BaseFile
            let emptyList = mData.count == 0
            if (row >= mData.count || emptyList) {
                data = TransferHandler.sharedInstance.getCurrentPathFile()
            } else {
                data = mData[row]
            }
            LogV("Copy from Finder, file:[", finderItems, "] into app item:", data)
            if let nonNilDelegate = dragDelegate {
                nonNilDelegate.dragItem(items: finderItems, fromFinderIntoAppItem: data as! DraggableItem)
            }
            return true
        }
		
        return returnValue
	}
	
	func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
//        return DraggableTableView.kFakeDraggableItem
        if (!enableDrag) {
            return nil
        }
        return mData[row] as! NSPasteboardWriting
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		register(forDraggedTypes: [kPasteBoardType])
		setDraggingSourceOperationMask(NSDragOperation.copy, forLocal: false)
		headerView = nil
		allowsMultipleSelection = true
		verticalMotionCanBeginDrag = true
		dataSource = self
	}
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                Swift.print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func convertDataToInt(data: NSData) -> Int {
        do {
            let dic: AnyObject! = try PropertyListSerialization.propertyList(from: data as Data, options: PropertyListSerialization.ReadOptions(rawValue: 0), format: nil) as AnyObject
            return dic as! Int
            
        } catch {
        }
        return 0
    }
    
    func updateItemChanged(index i: Int) {
        var row = i
        if (row < 0) {
            row = 0
        } else if (row >= numberOfRows) {
            row = numberOfRows - 1;
        }
        let rowSet = NSIndexSet(index: row) as IndexSet
        selectRowIndexes(rowSet, byExtendingSelection: false)
        
        let columnSet = NSIndexSet(index: 0) as IndexSet
        reloadData(forRowIndexes: rowSet, columnIndexes: columnSet)
    }
    
    func deselectAllRows(_ oldIndex: Int) {
        deselectAll(nil)
        if (oldIndex >= numberOfRows || oldIndex < 0) {
//            LogW("Bad Deselect Index")
            return
        }
        let rowSet = NSIndexSet(index: oldIndex) as IndexSet
        let columnSet = NSIndexSet(index: 0) as IndexSet
        reloadData(forRowIndexes: rowSet, columnIndexes: columnSet)
    }
    
    
//    Copying to Finder, drop destination
    override func draggingEnded(_ sender: NSDraggingInfo?) {
        if (!enableDrag) {
            return
        }
        let oldDrag = dragDropRow
        dragDropRow = DRAG_DROP_NONE
//        updateItemChanged(index: oldDrag)
        if (dragUiDelegate != nil) {
            dragUiDelegate?.onDropDestination(oldDrag)
        }
        if let senderUnwrap = sender {
            var appItems = [BaseFile]()
            let pb = senderUnwrap.draggingPasteboard()
//            LogI("Items", senderUnwrap.draggingPasteboard().pasteboardItems)
            var draggedIndex = -1
            for item in pb.pasteboardItems! {
                if let data = item.data(forType: kWritableType) {
    //                LogI("Item", item.data(forType: kWritableType))
    //                LogV("Item", item.string(forType: kWritableType))
                    let index = convertDataToInt(data: data as NSData)
//                    LogV("Index", index)
                    draggedIndex = index
                    appItems.append(mData[index])
                } else {
//                    LogW("Bad!")
                }
            }
            
            let indexSet = selectedRowIndexes
            var currentIndex = indexSet.first
            while (currentIndex != nil && currentIndex != NSNotFound) {
                if (currentIndex != draggedIndex) {
                    let currentItem = mData[currentIndex!]
                    appItems.append(currentItem)
                }
                currentIndex = indexSet.integerGreaterThan(currentIndex!)
            }
            
            if (pb.types?.contains(kPasteboardTypePasteLocation))! {
                let url = NSURL(string: (pb.string(forType: kPasteboardTypePasteLocation))!)
                if let copyPath = url?.absoluteURL?.path {
                    LogV("Copy from app item:", appItems, "to", copyPath)
                    if let nonNilDelegate = dragDelegate {
                        nonNilDelegate.dragItem(items: appItems as! [DraggableItem], fromAppToFinderLocation: copyPath)
                    }
                } else {
//                    LogE("Cannot Copy!")
                }
            }
        }
	}
}
