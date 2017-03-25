//
// Created by Kishan P Rao on 11/03/17.
// Copyright (c) 2017 Untitled-TBA. All rights reserved.
//

import Foundation

class DisabledTextField: NSTextField {
	override func hitTest(_ aPoint: Foundation.NSPoint) -> NSView? {
		return nil
	}
}
