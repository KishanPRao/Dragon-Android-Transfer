//
//  OverlayView.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 14/01/17.
//  Copyright © 2017 Untitled-TBA. All rights reserved.
//

import Foundation

class OverlayView: NSView {
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		wantsLayer = true
		layer?.backgroundColor = NSColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5).cgColor
	}
	
	override func mouseDown(with theEvent: NSEvent) {
//        Swift.print("Ignore Mouse!")
	}
}
