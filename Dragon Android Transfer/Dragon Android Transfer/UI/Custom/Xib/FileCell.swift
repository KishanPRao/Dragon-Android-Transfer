//
//  FileCell.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 05/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class FileCell: NSTableCellView {
	
	@IBOutlet var nameField: NSTextField!
	@IBOutlet var fileImage: NSImageView!
	@IBOutlet var sizeField: NSTextField!
	@IBOutlet var contentView: NSView!
	
	override func awakeFromNib() {
		super.awakeFromNib()
	}
    
    var isDraggingCell = false
    
    var isSelected: Bool = false {
        didSet {
            if (isSelected) {
                if (self.isDraggingCell) {
                    self.contentView.setBackground(R.color.mainViewColor)
                } else {
                    self.contentView.setBackground(R.color.listSelectedBackgroundColor)
                }
            } else {
                self.contentView.setBackground(NSColor.clear)
//                self.contentView.wantsLayer = false
            }
        }
    }
	
	private func updateText(_ textField: NSTextField) {
        textField.updateMainFont()
		textField.textColor = R.color.textColor
//		textField.setBackground(R.color.tableItemBg)
//		textField.setBackground(R.color.clear)
	}
	
	override init(frame frameRect: Foundation.NSRect) {
		super.init(frame: frameRect)
		Bundle.main.loadNibNamed(NSNib.Name(rawValue: "FileCell"), owner: self, topLevelObjects: nil)
//		Swift.print("File Cell Test", contentView.frame, self)
//        text.textColor = R.color.white
		
//        let fileName = nameField!
//        fileName.textColor = ColorUtils.colorWithHexString(ColorUtils.listTextColor)
//        fileName.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_file_table_file_cell_file_name_text_size))
        
        updateText(nameField)
//		fileName.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table_file_cell_file_name)
		updateText(sizeField)
		
		contentView.frame = frame
		addSubview(self.contentView)
//        text.frame.size.width = frame.size.width
	}
	
	/*
	override func resize(withOldSuperviewSize oldSize: NSSize) {
		super.resize(withOldSuperviewSize: oldSize)
	}*/
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
}
