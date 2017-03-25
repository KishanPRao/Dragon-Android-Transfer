//
// Created by Kishan P Rao on 11/03/17.
// Copyright (c) 2017 Untitled-TBA. All rights reserved.
//

import Foundation

class StyleUtils {
	static func updateButton(_ button: NSButton, withImage image: NSImage?) {
		if let cell = button.cell as? NSButtonCell {
			image!.size = cell.cellSize
			cell.image = image!
			cell.imageScaling = NSImageScaling.scaleAxesIndependently
		}
	}
}
