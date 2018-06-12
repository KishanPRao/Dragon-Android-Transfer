//
//  MVCTable.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension MenuViewController {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = SelectionTableRowView()
        rowView.selectedColor = R.color.menuItemSelectBg
        return rowView
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (row >= self.storages.count) {
            print("Warning: Row out of range!")
            return nil
        }
        //LogV("Menu Table View")
        let returnCell: MenuCell?
        if let spareView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "menu_cell"),
                                                            owner: self) as? MenuCell {
            returnCell = spareView
            
        } else {
//            let height = 35.0 as CGFloat
            let height = rowHeight
            let newCell = MenuCell(frame: NSRect(x: 0, y: 0, width: self.navigationParent.frame.width, height: height))
            returnCell = newCell
        }
        if let cell = returnCell {
            let storage = storages[row]
            var imageName: String
            if (storage.isInternal) {
                imageName = "internal_storage"
            } else {
                imageName = "external_storage"
            }
            let image = NSImage(named: NSImage.Name(rawValue: imageName))
            cell.image.image = image
//            view.image.imageScaling = .scaleProportionallyUpOrDown
            cell.image.imageScaling = .scaleAxesIndependently
            cell.text.stringValue = storage.path.name
            if selectedStorageIndex == row {
//                var nsCell = tableColumn?.dataCell(forRow: row) as! NSCell
//                tableColumn?.width = cell.contentView.frame.width
                cell.isSelected = true
            } else {
//                tableColumn?.width = cell.contentView.frame.width
                cell.isSelected = false
            }
//            LogI("Selected: \(row), \(selectedStorageIndex), \(cell.isSelected)")
//            tableColumn.
        }
        return returnCell
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        //LogV("Menu numOfRows")
        return self.storages.count
    }
}
