//
//  ProgressView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class ProgressView: VerboseView {
//    let PROGRESS_BACKGROUND_COLOR = ColorUtils.colorWithHexString("#5abbb2")
//    let PROGRESS_FOREGROUND_COLOR = ColorUtils.colorWithHexString("#009688")
    var progressBgColor = R.color.white
    var progressFgColor = R.color.black
    
    var mProgress: CGFloat = 0.0
    
//    override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//    }
	
	override init(frame frameRect: Foundation.NSRect) {
		super.init(frame: frameRect)
	}
	
	
	required init?(coder: NSCoder) {
        super.init(coder: coder)
//        wantsLayer = true
//        layer?.cornerRadius = 3.0
        self.cornerRadius(3.0)
    }
    
    func setProgress(_ progress: CGFloat) {
//		Swift.print("ProgressView, Time:", TimeUtils.getCurrentTime(), ", Progress:", progress)
        mProgress = progress
	
//		if (NSObject.VERBOSE) {
//			Swift.print("ProgressView, main?", Thread.isMainThread);
//		}
		
		needsDisplay = true
    }
    
    override func draw(_ dirtyRect: NSRect) {
		if (VerboseView.VERBOSE) {
//			Swift.print("ProgressView, Drawing");
		}
        progressBgColor.set()
        NSBezierPath.fill(dirtyRect)
        progressFgColor.set()
        let width = dirtyRect.width * (mProgress / 100.0)
        let rect = CGRect(x: 0, y: 0, width: width, height: dirtyRect.height)
        NSBezierPath.fill(rect)
    }
}
