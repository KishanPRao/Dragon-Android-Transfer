//
//  AVCTable.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 13/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

extension AndroidViewController {
    
    internal func initTable() {
        fileTable.delegate = self
        fileTable.dragDelegate = self
        fileTable.dragUiDelegate = self
        //        self.fileTable.intercellSpacing = NSSize(width: 0, height: 5)
        let doubleClickSelector: Selector = #selector(AndroidViewController.doubleClickList(_:))
        fileTable.doubleAction = doubleClickSelector
//        fileTable.register(NSNib.init(nibNamed: NSNib.Name("FileCell"), bundle: nil), forIdentifier: FileCell.Identifier)
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = SelectionTableRowView()
        /*guard let fileTable = fileTable else {
            return rowView
        }
        if (fileTable.dragDropRow == row) {
            rowView.selectedColor = R.color.mainViewColor
        } else {
            rowView.selectedColor = R.color.listSelectedBackgroundColor
        }*/
        rowView.selectedColor = R.color.listSelectedBackgroundColor
        return rowView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        //        return 25
        //        return DimenUtils.getDimension(dimension: Dimens.android_controller_file_table_file_cell_height) - DimenUtils.getDimension(dimension: Dimens.android_controller_file_table_file_cell_margin)
        return 45
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        if (VerboseObject.VERBOSE) {
            //            TODO: Check later..
            //            Swift.print("AndroidViewController: select:", row, ", Table:", tableView, ", FileTable:", fileTable, ", Item:", androidDirectoryItems[row]);
        }
        //        if (tableView == fileTable) {
        //            let rowItem = tableView.rowView(atRow: row, makeIfNecessary: true)
        //            //        print("Row:", rowItem?.viewAtColumn(0))
        //            let cellView = rowItem?.view(atColumn: 0) as! NSView
        //            setBackgroundColorTo(cellView, color: ColorUtils.listSelectedBackgroundColor)
        //        }
        return true
    }
    
    /*
    @IBAction func tableSelectionChanged(_ sender: Any) {
        if (NSObject.VERBOSE) {
            //            Swift.print("AndroidViewController: tableSelectionChanged:", fileTable.selectedRow);
        }
    }*/
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (row >= self.androidDirectoryItems.count) {
            LogW("Warning: Row out of range: \(row)")
            return nil
        }
//        let startTime = TimeUtils.getDispatchTime()
        
        let returnView: FileCell?
        if let spareView = tableView.makeView(withIdentifier: FileCell.Identifier,
                                          owner: nil) as? FileCell {
//            print("tableView, Make view: \(row)")
//            print("tableView frame: \(spareView.frame)")
            returnView = spareView
            
        } else {
            //            let height = 40.0 as CGFloat
            let height = 40.0 as CGFloat
            let newCell = FileCell(frame: NSRect(x: 0, y: 0, width: self.fileTable!.frame.size.width, height: height))
//            newCell.identifier = NSUserInterfaceItemIdentifier(rawValue: "file_cell")
            returnView = newCell
            //            Not used. TODO: Remove, if needed
            print("tableView, New Cell: \(row)")
            //      Possibility “This NSLayoutConstraint is being configured with a constant that exceeds internal limits” error to occur. Old version SDK?
        }
//        print("1. tableView, Cell Time Taken: \(TimeUtils.getDifference(startTime))ms")
        
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
//            print("2. Cell Time Taken: \(TimeUtils.getDifference(startTime))ms")
            
            let fileImage = cellView.fileImage!
            //            fileImage.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table_file_cell_file_image)
            let isDirectory = file.type == BaseFileType.Directory
            if (isDirectory) {
                fileImage.image = NSImage(named: NSImage.Name(rawValue: R.drawable.folder))
            } else {
                fileImage.image = NSImage(named: NSImage.Name(rawValue: R.drawable.file))
            }
//            print("3. Cell Time Taken: \(TimeUtils.getDifference(startTime))ms")
            if let fileTable = fileTable {
                if (!isDirectory) {
                    if (fileTable.dragDropRow == row) {
                        //                        print("AVC Drag color: \(row)")
                        //                        ColorUtils.setBackgroundColorTo(cellView, color: ColorUtils.mainViewColor)
                        cellView.isDraggingCell = true
                    } else {
                        cellView.isDraggingCell = false
                        //                        print("AVC Clear color: \(row), \(fileTable.dragDropRow)")
                        //                        ColorUtils.setBackgroundColorTo(cellView, color: R.color.clear)
                    }
                }
//                print("4. Cell Time Taken: \(TimeUtils.getDifference(startTime))ms")
                let indexSet = fileTable.selectedRowIndexes
//                print("5. Cell Time Taken: \(TimeUtils.getDifference(startTime))ms")
                if (indexSet.contains(row)) {
//                    print("6. Cell Time Taken: \(TimeUtils.getDifference(startTime))ms")
                    //                    ColorUtils.setBackgroundColorTo(cellView, color: ColorUtils.listSelectedBackgroundColor)
                    if (!cellView.isSelected) {
                        cellView.isSelected = true
                    }
                } else {
//                    print("6. Cell Time Taken: \(TimeUtils.getDifference(startTime))ms")
                    //                    cellView.setBackground(R.color.tableItemBg)
                    //                    cellView.setBackground(R.color.clear)
                    //                    cellView.setBackground(NSColor.clear)
                    if (cellView.isSelected) {
                        cellView.isSelected = false
                    }
                    //                ColorUtils.setBackgroundColorTo(cellView, color: ColorUtils.listItemBackgroundColor)
                }
//                print("7. Cell Time Taken: \(TimeUtils.getDifference(startTime))ms")
            }
        }
//        print("Cell Time Taken: \(TimeUtils.getDifference(startTime))ms")
        return returnView
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        guard let fileTable = fileTable else {
            return
        }
        if (fileTable.numberOfSelectedRows > 0) {
            //            let selectedItem = self.androidDirectoryItems[self.fileTable.selectedRow].fileName
            //            print("Selected:", selectedItem)
            
            let indexSet = fileTable.selectedRowIndexes
            var i = 0
            AppDelegate.itemSelected = false
            AppDelegate.multipleItemsSelected = false
            AppDelegate.directoryItemSelected = false
            var itemSelected = false
            while (i < androidDirectoryItems.count) {
                let rowItem = fileTable.rowView(atRow: i, makeIfNecessary: false)
                if (indexSet.contains(i)) {
                    if  let rowItem = rowItem {
                        let cellView = rowItem.view(atColumn: 0) as! FileCell
                        cellView.isSelected = true
                    }
                    if (itemSelected) {
                        AppDelegate.multipleItemsSelected = true
                    }
                    itemSelected = true
                    if (self.androidDirectoryItems[i].type == BaseFileType.Directory) {
                        AppDelegate.directoryItemSelected = true
                    }
                    AppDelegate.itemSelected = true
                } else {
                    if  let rowItem = rowItem {
                        let cellView = rowItem.view(atColumn: 0) as! FileCell
                        cellView.isSelected = false
                    }
                }
                i = i + 1
            }
        }
    }
}
