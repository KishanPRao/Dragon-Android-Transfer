//
//  NonDeselectTableView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 22/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa

class NonDeselectTableView: NSTableView {
    //    override func keyDown(with event: NSEvent) {
    ////        if (event.keyCode == NSEvent.) {
    //////            self.doubleAction?.unsafelyUnwrapped()
    ////            LogV("Enter!")
    ////        }
    ////        self.interpretKeyEvents([event])
    //        LogV("Key: \(event.keyCode)")
    ////        NSEventModifierFlags.
    //    kReturn
    //        switch event.modifierFlags.intersection(.deviceIndependentFlagsMask) {
    //            case [.]:
    //                LogV("")
    //        }
    //        super.keyDown(with: event)
    //    }
    
    //    override func performKeyEquivalent(with event: NSEvent) -> Bool {
    //        if (event.keyCode == 13) {
    ////            self.doubleAction
    //            LogV("Enter!")
    //        }
    //        return super.performKeyEquivalent(with: event)
    //    }
    
    override func mouseDown(with event: NSEvent) {
        let globalLocation = event.locationInWindow
        let localLocation = self.convert(globalLocation, to: nil)
        let clickedRow = self.row(at: localLocation)
        if (clickedRow != -1) {
            super.mouseDown(with: event)
        }
    }
}
