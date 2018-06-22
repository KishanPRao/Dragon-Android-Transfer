//
// Created by Kishan P Rao on 06/01/18.
// Copyright (c) 2018 Kishan P Rao. All rights reserved.
//

import Foundation

extension NSTableView {
	
//	override func keyDown(with event: NSEvent) {
//		if (event.keyCode == 13) {
////			self.doubleAction?.unsafelyUnwrapped()
//		}
//		super.keyDown(with: event)
//	}

//	override func performKeyEquivalent(with event: NSEvent) -> Bool {
//		if (event.keyCode == 13) {
//			self.doubleAction
//		}
//		return super.performKeyEquivalent(event)
//	}
    
    internal func notifyItemChanged(index: Int) {
        if index == -1 {
            return
        }
        let indexSet = IndexSet(integer: index)
        let columnSet = NSIndexSet(index: 0) as IndexSet
        self.reloadData(forRowIndexes: indexSet, columnIndexes: columnSet)
    }
    
    func updateItemSelected(index i: Int) {
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
    
    func updateItemChanged(index i: Int) {
        var row = i
        if (row < 0) {
            row = 0
        } else if (row >= numberOfRows) {
            row = numberOfRows - 1;
        }
        let rowSet = NSIndexSet(index: row) as IndexSet
        let columnSet = NSIndexSet(index: 0) as IndexSet
        reloadData(forRowIndexes: rowSet, columnIndexes: columnSet)
    }
    
    func deselectAllRows(_ updateIndex: Int) {
        deselectAll(nil)
        if (updateIndex >= numberOfRows || updateIndex < 0) {
            //            LogW("Bad Deselect Index")
            return
        }
        let rowSet = NSIndexSet(index: updateIndex) as IndexSet
        let columnSet = NSIndexSet(index: 0) as IndexSet
        reloadData(forRowIndexes: rowSet, columnIndexes: columnSet)
    }
    
    func deselectAllRows() {
        deselectAll(nil)
        reloadData()
    }
}
