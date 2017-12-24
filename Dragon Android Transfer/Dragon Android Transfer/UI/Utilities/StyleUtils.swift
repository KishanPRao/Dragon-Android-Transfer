//
// Created by Kishan P Rao on 11/03/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class StyleUtils {
	static func updateButton(_ button: NSButton, withImage image: NSImage?) {
//		if let cell = button.cell as? NSButtonCell {
//			image!.size = cell.cellSize
//			cell.image = image!
//			cell.imageScaling = NSImageScaling.scaleAxesIndependently
//		}
		image!.size = button.frame.size
		button.image = image!
		button.imageScaling = NSImageScaling.scaleAxesIndependently
	}
	
	static func updateButtonWithCell(_ button: NSButton, withImage image: NSImage?) {
		if let cell = button.cell as? NSButtonCell {
			image!.size = cell.cellSize
			cell.image = image!
			cell.imageScaling = NSImageScaling.scaleAxesIndependently
		}
	}
}
