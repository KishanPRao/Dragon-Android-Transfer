//
// Created by Kishan P Rao on 31/12/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

public extension NSWindow {
	public var titlebarHeight: CGFloat {
		let contentHeight = contentRect(forFrameRect: frame).height
		return frame.height - contentHeight
	}
    
    public func updateWindowColor() {
        let window = self
        if (R.color.isDark) {
            window.appearance = NSAppearance(named: .vibrantDark)
        }
        window.titlebarAppearsTransparent = true
    }
}

