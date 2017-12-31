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
        return 50
    }
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        print("Clicked", tableColumn)
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
            let newCell = MenuCell(frame: NSRect(x: 0, y: 0, width: self.navigationParent.frame.width, height: 50))
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
            view.image.imageScaling = .scaleProportionallyUpOrDown
            view.text.stringValue = storage.name
        }
        
        return returnView
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return true
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        LogV("Menu numOfRows")
        return self.storages.count
    }
}
