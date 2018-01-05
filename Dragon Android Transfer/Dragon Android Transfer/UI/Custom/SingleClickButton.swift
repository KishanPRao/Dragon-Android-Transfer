//
//  SingleClickButton.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 05/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class SingleClickButton: NSButton {
    
    var singleClick = false
    var previousEvent: NSEvent? = nil
    
    private func eventsEqual(_ event1: NSEvent, _ event2: NSEvent) -> Bool {
//        LogV("eventsEqual", event1, event2)
        let xNotEqual = Int(event1.locationInWindow.x) != Int(event2.locationInWindow.y)
        let yNotEqual = Int(event1.locationInWindow.y) != Int(event2.locationInWindow.y)
        return !(xNotEqual && yNotEqual)
    }
    
    open override func mouseDown(with event: NSEvent) {
        if let previousEvent = previousEvent {
            let sameEvent = eventsEqual(previousEvent, event)
            self.previousEvent = event
            if (sameEvent) {
                return
            }
        }
        previousEvent = event
        super.mouseDown(with: event)
    }
}
