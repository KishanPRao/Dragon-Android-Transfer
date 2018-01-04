//
//  OverlayView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 14/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class OverlayView: ClickableView {
    let AnimationDuration = 0.25
    
    func show() {
//        cancelActiveAnimation = true
        self.alphaValue = 0.0
        self.isHidden = false
        self.needsDisplay = true
        NSAnimationContext.runAnimationGroup({ context in
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            context.duration = AnimationDuration
            self.animator().alphaValue = 1.0
        }, completionHandler: {
//            if (!self.cancelActiveAnimation) {
//                self.isHidden = true
//            }
        })
    }
    
//    var cancelActiveAnimation = false
    
    func hide() {
        NSAnimationContext.runAnimationGroup({ context in
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            context.duration = AnimationDuration
            self.animator().alphaValue = 0.0
        }, completionHandler: {
//            if (!self.cancelActiveAnimation) {
                self.isHidden = true
//            }
        })
    }
}
