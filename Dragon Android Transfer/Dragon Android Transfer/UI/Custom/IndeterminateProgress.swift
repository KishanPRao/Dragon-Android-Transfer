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
    let xOffsetStep: CGFloat = 5.5
    
    private func update() {
        var width = frame.width / 2.0
        var xOffset = self.xOffset.truncatingRemainder(dividingBy: frame.width)
        let t = Double((xOffset / self.frame.width))
        xOffset = self.frame.width * CGFloat(self.getTime(t));
//        print("Indeterminate: \(xOffset), \(t) -> \(self.getTime(t))")
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
    
//    let dummyAnimation =
    
    func getTime(_ t: Double) -> Double {
        /*let path = NSBezierPath(rect: CGRect(x: 0, y: 0,
                                       width: 500,
                                       height: 500)
        let fillLayer = CAShapeLayer(layer: self.layer)
        fillLayer.path = path.cgPath*/
        return AnimationUtils.solve(t: t, curveType: .easeInEaseOut)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        progressBackground.set()
        backgroundRect.fill()
        progressForeground.set()
        path.fill()
        
        if (!isHidden) {
            ThreadUtils.runInMainThreadAfter(delayMs: IndeterminateProgress.Fps60_Delay, {
                self.xOffset = self.xOffset + self.xOffsetStep
                /*let timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                
                var point1: [Float] = [0.1,0.1]
                var point2: [Float] = [0.1,0.1]
                
                timingFunction.getControlPoint(at: 1, values: &point1)
                timingFunction.getControlPoint(at: 2, values: &point2)
 
                print("Indeterminate: \(String(describing: point1)),\(String(describing: point2))")
 */
                self.update()
                self.needsDisplay = true
            })
        }
    }
    
    func show() {
        print("Show")
        if (isHiding) {
            cancelActiveAnimation = true
        }
        self.alphaValue = 1.0
        self.isHidden = false
        self.needsDisplay = true
        print("Show done")
    }
    
    var isHiding = false
    var cancelActiveAnimation = false
    
    func hide() {
//        print("Hide")
//        NSObject.printStackTrace()
        isHiding = true
        NSAnimationContext.runAnimationGroup({ context in
            context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            context.duration = R.number.progressAnimHideDuration
            self.animator().alphaValue = 0.0
        }, completionHandler: {
            self.isHiding = false
            //print("Animation completed")
            if (!self.cancelActiveAnimation) {
            	self.isHidden = true
                print("Hidden Progress!")
            } else {
                print("Not Hidden!")
            }
            self.cancelActiveAnimation = false
//            print("Hide done")
        })
    }
}
