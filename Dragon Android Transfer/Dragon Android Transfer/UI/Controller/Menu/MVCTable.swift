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
        let height = 45.0 as CGFloat
        return height
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return SelectionTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (row >= self.storages.count) {
            print("Warning: Row out of range!")
            return nil
        }
        //LogV("Menu Table View")
        let returnView: MenuCell?
        if let spareView = tableView.make(withIdentifier: "menu_cell",
                                                            owner: self) as? MenuCell {
            returnView = spareView
            
        } else {
            let height = 35.0 as CGFloat
            let newCell = MenuCell(frame: NSRect(x: 0, y: 0, width: self.navigationParent.frame.width, height: height))
            returnView = newCell
        }
        if let view = returnView {
            let storage = storages[row]
            var imageName: String
            if (storage.isInternal) {
                imageName = "internal_storage"
            } else {
                imageName = "external_storage"
            }
            let image = NSImage(named: imageName)
            view.image.image = image
//            view.image.imageScaling = .scaleProportionallyUpOrDown
            view.image.imageScaling = .scaleAxesIndependently
            view.text.stringValue = storage.path.name
        }
        
        return returnView
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        //LogV("Menu numOfRows")
        return self.storages.count
    }
}
