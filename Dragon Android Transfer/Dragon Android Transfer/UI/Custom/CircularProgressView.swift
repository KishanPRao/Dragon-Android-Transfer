//
//  CircularProgressView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 24/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa

class CircularProgressView: AbstractProgressView {
    let circularPath = NSBezierPath()
    let lineWidth = 5.0 as CGFloat
//    let lineWidth = 7.0 as CGFloat
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
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
    
    private func drawCircle(startAngle: CGFloat, endAngle: CGFloat, color: NSColor) {
        circularPath.removeAllPoints()
        circularPath.lineWidth = lineWidth
        color.set()
        let center = CGPoint (x: frame.size.width / 2.0, y: frame.size.height / 2.0)
        let circleRadius = (frame.size.width - lineWidth) / 2.0
        let offset = 90.0 as CGFloat
        
        circularPath.appendArc(withCenter: center,
                               radius: circleRadius,
                               startAngle: -endAngle + offset,
                               endAngle: offset,
                               clockwise: false)
        circularPath.lineCapStyle = .roundLineCapStyle
        circularPath.stroke()
    }
    
    override func drawProgress(_ dirtyRect: NSRect) {
        let progress = mProgress / 100.0
        drawCircle(startAngle: 0.0, endAngle: 360.0, color: progressBgColor)
        drawCircle(startAngle: 0.0, endAngle: (progress * 360.0), color: progressFgColor)
    }
}
