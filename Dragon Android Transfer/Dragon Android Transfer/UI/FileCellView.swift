//
//  FileCellView.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 29/01/17.
//  Copyright © 2017 Untitled-TBA. All rights reserved.
//

import Foundation

class FileCellView: NSTableCellView {
    var nameField: NSTextField? = nil
    var fileImage: NSImageView? = nil
    var sizeField: NSTextField? = nil
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        nameField = subviews[0] as? NSTextField
        fileImage = subviews[1] as? NSImageView
        sizeField = subviews[2] as? NSTextField
    }
}