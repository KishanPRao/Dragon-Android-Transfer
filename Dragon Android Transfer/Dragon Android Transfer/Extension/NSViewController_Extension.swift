//
// Created by Kishan P Rao on 07/01/18.
// Copyright (c) 2018 Kishan P Rao. All rights reserved.
//

import Foundation

extension NSViewController {
	
	class func loadFromStoryboard<T: Any>(name: String) -> T {
		let storyBoard = NSStoryboard(name: NSStoryboard.Name(rawValue: name), bundle: Bundle.main)
//		print("Loading Storyboard")
		return storyBoard.instantiateInitialController() as! T
	}
}
