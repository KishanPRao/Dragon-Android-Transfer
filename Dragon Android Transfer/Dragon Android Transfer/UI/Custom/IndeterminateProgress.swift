//
//  IndeterminateProgress.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 02/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class IndeterminateProgress: NSView {
    let progressForeground = R.color.toolbarProgressFg
    let progressBackground = R.color.toolbarProgressBg
    var foregroundRect1 = NSRect()
    var foregroundRect2 = NSRect()
    var backgroundRect = NSRect()
    var path = NSBezierPath()
    
    var xOffset: CGFloat = 0.0
    
    private func update() {
        var width = frame.width / 2.0
        let xOffset = self.xOffset.truncatingRemainder(dividingBy: frame.width)
        let totalSize = xOffset + width
        
        //LogV("Offset:", xOffset, " total:", totalSize)
        path.removeAllPoints()
        foregroundRect1.update(x: xOffset, y: 0, width: width, height: frame.height)
        path.appendRect(foregroundRect1)
        
        if (totalSize > frame.width) {
            width = (totalSize - frame.width)
            foregroundRect2.update(x: 0, y: 0, width: width, height: frame.height)
            path.appendRect(foregroundRect2)
        }
        backgroundRect.update(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    
    private func commonInit() {
        //LogV("Init Progress")
        setBackground(R.color.toolbarColor)
        update()
    }
    
    override func resize(withOldSuperviewSize oldSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSize)
        update()
    }
    
    override init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        progressBackground.set()
        backgroundRect.fill()
        progressForeground.set()
        path.fill()
        
        if (!isHidden) {
            //            TODO: Animate using kCAMediaTimingFunctionEaseInEaseOut function, somehow.
            ThreadUtils.runInMainThreadAfter(delayMs: NSView.FPS_DELAY, {
                self.xOffset = self.xOffset + 5
                self.update()
                self.needsDisplay = true
            })
        }
    }
    
    func show() {
//        print("Show")
        cancelActiveAnimation = true
        self.alphaValue = 1.0
        self.isHidden = false
        self.needsDisplay = true
//        print("Show done")
    }
    
    var cancelActiveAnimation = false
    
    func hide() {
//        print("Hide")
//        NSObject.printStackTrace()
        NSAnimationContext.runAnimationGroup({ context in
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            context.duration = R.number.progressAnimHideDuration
            self.animator().alphaValue = 0.0
        }, completionHandler: {
            //print("Animation completed")
            if (!self.cancelActiveAnimation) {
            	self.isHidden = true
            }
//            print("Hide done")
        })
    }
}
