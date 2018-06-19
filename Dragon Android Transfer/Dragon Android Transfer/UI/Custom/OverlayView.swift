//
//  OverlayView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 14/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class OverlayView: ClickableView {
	let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
	
	func show() {
        cancelActiveAnimation = true
		self.alphaValue = 0.0
		self.isHidden = false
		self.needsDisplay = true
		NSAnimationContext.runAnimationGroup({ context in
			context.timingFunction = timingFunction
			context.duration = R.integer.animStartDuration
			self.animator().alphaValue = 1.0
		}, completionHandler: {
            self.cancelActiveAnimation = false
//            if (!self.cancelActiveAnimation) {
//                self.isHidden = true
//            }
		})
	}

    var cancelActiveAnimation = false
	
	func hide(_ handler: @escaping () -> () = {}) {
		NSAnimationContext.runAnimationGroup({ context in
			context.timingFunction = timingFunction
			context.duration = R.integer.overlayAnimHideDuration
			self.animator().alphaValue = 0.0
		}, completionHandler: {
            if (!self.cancelActiveAnimation) {
                self.isHidden = true
            }
			handler()
		})
	}
}
