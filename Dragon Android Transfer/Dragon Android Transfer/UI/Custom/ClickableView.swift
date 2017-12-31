//
//  ClickableView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 14/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class ClickableView: NSView {
    
    override init(frame frameRect: Foundation.NSRect) {
        super.init(frame: frameRect)
    }
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
        /*
		wantsLayer = true
		layer?.backgroundColor = NSColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5).cgColor
 */
	}
    
    var onClick: () -> () = {}
    
    func setOnClickListener(onClick: (@escaping () -> ())) {
        self.onClick = onClick
    }
	
	override func mouseDown(with theEvent: NSEvent) {
//        Swift.print("Ignore Mouse!")
        onClick()
	}
}
