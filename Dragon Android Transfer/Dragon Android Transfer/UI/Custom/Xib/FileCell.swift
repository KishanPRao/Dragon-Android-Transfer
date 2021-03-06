//
//  FileCell.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 05/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class FileCell: NSTableCellView {
    public static let Identifier = NSUserInterfaceItemIdentifier(rawValue: "fileCell")
    
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
                    self.contentView.setBackground(R.color.tableBg)
//                    self.contentView.setBackground(R.color.tableItemBg)
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
//        textField.textColor = R.color.textColor
        textField.textColor = R.color.white
//		textField.setBackground(R.color.tableItemBg)
//		textField.setBackground(R.color.clear)
	}
    
    func initCell() {
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: "FileCell"), owner: self, topLevelObjects: nil)
        //        Swift.print("File Cell Test", contentView.frame, self)
        //        text.textColor = R.color.white
        
        //        let fileName = nameField!
        //        fileName.textColor = ColorUtils.colorWithHexString(ColorUtils.listTextColor)
        //        fileName.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_file_table_file_cell_file_name_text_size))
        
        nameField.updateMainFont()
        nameField.textColor = R.color.textColor
        //        fileName.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table_file_cell_file_name)
        
        sizeField.updateMainFont()
        sizeField.textColor = R.color.dialogTextColor
        
        contentView.frame = frame
//        LogD("tableView, cell Initialized!")
        addSubview(self.contentView)
        //        text.frame.size.width = frame.size.width
    }
	
	override init(frame frameRect: Foundation.NSRect) {
		super.init(frame: frameRect)
//        LogD("tableView, cell frame init")
        
//        initCell()
	}
	
	/*
	override func resize(withOldSuperviewSize oldSize: NSSize) {
		super.resize(withOldSuperviewSize: oldSize)
	}*/
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
        if (!frame.isEmpty) {
            initCell()
        }
//        LogD("tableView, cell init: \(frame)")
	}
}
