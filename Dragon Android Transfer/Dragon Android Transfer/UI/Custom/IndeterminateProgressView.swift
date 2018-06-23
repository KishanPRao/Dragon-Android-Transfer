//
//  IndeterminateProgressView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 22/10/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class IndeterminateProgressView : NSView {
//    Spinning Indeterminate, like Android.
    let PROGRESS_FOREGROUND_COLOR = ColorUtils.colorWithHexString(ColorUtils.indeterminateProgressForegroundColor)
    let circularPath = NSBezierPath()
    let lineWidth = 5.0 as CGFloat
    let totalTimeMs = 1 * 1000 as CGFloat
    
    override init(frame frameRect: Foundation.NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
    }
    
    override var isHidden: Bool {
        get {
            return super.isHidden
        }
        set(v) {
            super.isHidden = v
            if (!v) {
            	self.needsDisplay = true
            }
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let time = CGFloat(CFAbsoluteTimeGetCurrent() * 1000.0)

        circularPath.removeAllPoints()
        circularPath.lineWidth = lineWidth
        
        let progress = ((time.truncatingRemainder(dividingBy: (totalTimeMs)) / totalTimeMs))
//        LogV("Draw", time, progress)
        
        let offset = (progress * 360.0) as CGFloat
//        LogV("Draw", offset, progress)
        let startAngle = 0.0 + offset as CGFloat
        let endAngle = 230.0 + offset as CGFloat
        
        PROGRESS_FOREGROUND_COLOR.set()
        let center = CGPoint (x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        let circleRadius = (frame.size.width - lineWidth) / 2.0
        
        circularPath.appendArc(withCenter: center, radius: circleRadius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        circularPath.stroke()
        
        if (!isHidden) {
            ThreadUtils.runInMainThreadAfter(delayMs: IndeterminateProgressView.Fps30_Delay, {
                self.needsDisplay = true
            })
        }
    }
}
