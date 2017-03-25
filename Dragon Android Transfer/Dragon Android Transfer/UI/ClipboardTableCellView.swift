//
//  ClipboardTableCellView.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 22/01/17.
//  Copyright © 2017 Untitled-TBA. All rights reserved.
//

import Foundation

class ClipboardTableCellView: NSTableCellView {
    var nameField: NSTextField? = nil
    var fileImage: NSImageView? = nil
    var sizeField: NSTextField? = nil
	var showFullPath = false as Bool
	
//    func setShowFullPath(fullPath: Bool) {
//        showFullPath = fullPath
//    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        Swift.print("Items:", subviews)
        nameField = subviews[0] as? NSTextField
        fileImage = subviews[1] as? NSImageView
        sizeField = subviews[2] as? NSTextField
    }
}
