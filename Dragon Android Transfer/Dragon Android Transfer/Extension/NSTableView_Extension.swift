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
}
