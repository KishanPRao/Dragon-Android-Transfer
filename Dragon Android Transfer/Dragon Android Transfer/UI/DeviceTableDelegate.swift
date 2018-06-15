//
//  DeviceTableDelegate.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 24/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Cocoa

class DeviceTableDelegate: NSObject, NSTableViewDelegate {
    private var androidDirectoryItems: Array<BaseFile> = []
    public var fileTable: DraggableTableView? = nil
    
    public func setAndroidDirectoryItems(items androidDirectoryItems: Array<BaseFile>) {
        //Swift.print("Set Android Dir Items", androidDirectoryItems)
        self.androidDirectoryItems = androidDirectoryItems
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = SelectionTableRowView()
        rowView.selectedColor = R.color.listSelectedBackgroundColor
        return rowView
    }
	
	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
//		return 25
//        return DimenUtils.getDimension(dimension: Dimens.android_controller_file_table_file_cell_height) - DimenUtils.getDimension(dimension: Dimens.android_controller_file_table_file_cell_margin)
        return 45
	}
	
	func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
		if (NSObject.VERBOSE) {
//			TODO: Check later..
//			Swift.print("AndroidViewController: select:", row, ", Table:", tableView, ", FileTable:", fileTable, ", Item:", androidDirectoryItems[row]);
		}
//		if (tableView == fileTable) {
//			let rowItem = tableView.rowView(atRow: row, makeIfNecessary: true)
//			//        print("Row:", rowItem?.viewAtColumn(0))
//			let cellView = rowItem?.view(atColumn: 0) as! NSView
//			setBackgroundColorTo(cellView, color: ColorUtils.listSelectedBackgroundColor)
//		}
		return true
    }
	
	@IBAction func tableSelectionChanged(_ sender: Any) {
		if (NSObject.VERBOSE) {
//			Swift.print("AndroidViewController: tableSelectionChanged:", fileTable.selectedRow);
		}
    }
    
    let tableSelectedBgColor = ColorUtils.colorWithHexString(ColorUtils.listSelectedBackgroundColor)
    let tableBgColor = ColorUtils.colorWithHexString(ColorUtils.mainViewColor)
	
	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		if (row >= self.androidDirectoryItems.count) {
            print("Warning: Row out of range: \(row)")
			return nil
		}
        
        let returnView: FileCell?
        if let spareView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "file_cell"),
                                          owner: self) as? FileCell {
            returnView = spareView
            
        } else {
//            let height = 40.0 as CGFloat
            let height = 40.0 as CGFloat
            let newCell = FileCell(frame: NSRect(x: 0, y: 0, width: self.fileTable!.frame.size.width, height: height))
            returnView = newCell
            //      Possibility “This NSLayoutConstraint is being configured with a constant that exceeds internal limits” error to occur. Old version SDK?
        }
        
        if let cellView = returnView {
            let file = self.androidDirectoryItems[row]
            //            print("File:", file)
            let fileName = cellView.nameField!
            fileName.stringValue = file.fileName
            
            let fileSize = cellView.sizeField!
            fileSize.stringValue = SizeUtils.getBytesInFormat(file.size)
//            fileSize.textColor = ColorUtils.colorWithHexString(ColorUtils.listTextColor)
//            fileSize.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_file_table_file_cell_file_size_text_size))
//            fileSize.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table_file_cell_file_size)
            
            let fileImage = cellView.fileImage!
//            fileImage.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table_file_cell_file_image)
            let isDirectory = file.type == BaseFileType.Directory
            if (isDirectory) {
                fileImage.image = NSImage(named: NSImage.Name(rawValue: R.drawable.folder))
            } else {
                fileImage.image = NSImage(named: NSImage.Name(rawValue: R.drawable.file))
            }
            if let fileTable = fileTable {
                let indexSet = fileTable.selectedRowIndexes
                if (indexSet.contains(row)) {
//                    ColorUtils.setBackgroundColorTo(cellView, color: ColorUtils.listSelectedBackgroundColor)
                    cellView.isSelected = true
                } else {
//                    cellView.setBackground(R.color.tableItemBg)
//                    cellView.setBackground(R.color.clear)
//                    cellView.setBackground(NSColor.clear)
                    cellView.isSelected = false
                    //                ColorUtils.setBackgroundColorTo(cellView, color: ColorUtils.listItemBackgroundColor)
                }
                
                /*if (!isDirectory && fileTable.dragDropRow == row) {
                    print("Clear color: \(row)")
                    ColorUtils.setBackgroundColorTo(cellView, color: ColorUtils.mainViewColor)
                } else {
                    print("Clear color: \(row)")
                    ColorUtils.setBackgroundColorTo(cellView, color: R.color.clear)
                    //            setBackgroundColorTo(cellView, color: ColorUtils.listBackgroundColor)
                }*/
                if (!isDirectory) {
                    if (fileTable.dragDropRow == row) {
                        print("Drag color: \(row)")
                        ColorUtils.setBackgroundColorTo(cellView, color: ColorUtils.mainViewColor)
                    } else {
                        print("Clear color: \(row)")
                        ColorUtils.setBackgroundColorTo(cellView, color: R.color.clear)
                    }
                }
            }
        }
        return returnView
	}
	
	func tableViewSelectionDidChange(_ notification: Notification) {
        guard let fileTable = fileTable else {
            return
        }
		if (fileTable.numberOfSelectedRows > 0) {
//			let selectedItem = self.androidDirectoryItems[self.fileTable.selectedRow].fileName
//			print("Selected:", selectedItem)
			
			let indexSet = fileTable.selectedRowIndexes
			var i = 0
			AppDelegate.itemSelected = false
			AppDelegate.multipleItemsSelected = false
			AppDelegate.directoryItemSelected = false
			var itemSelected = false
			while (i < androidDirectoryItems.count) {
				let rowItem = fileTable.rowView(atRow: i, makeIfNecessary: false)
				if (rowItem != nil) {
//                    let cellView = rowItem?.view(atColumn: 0) as! NSView
                    let cellView = rowItem?.view(atColumn: 0) as! FileCell
					if (indexSet.contains(i)) {
//                        ColorUtils.setBackgroundColorTo(cellView, color: ColorUtils.listSelectedBackgroundColor)
                        cellView.isSelected = true
						
						if (itemSelected) {
							AppDelegate.multipleItemsSelected = true
						}
						itemSelected = true
						if (self.androidDirectoryItems[i].type == BaseFileType.Directory) {
							AppDelegate.directoryItemSelected = true
						}
						AppDelegate.itemSelected = true
					} else {
//                        cellView.setBackground(R.color.tableItemBg)
//                        cellView.setBackground(NSColor.clear)
                        cellView.isSelected = false
//						ColorUtils.setBackgroundColorTo(cellView, color: ColorUtils.listItemBackgroundColor)
					}
				}
				i = i + 1
			}
		}
	}
    
    func cleanup() {
        fileTable = nil
    }
}
