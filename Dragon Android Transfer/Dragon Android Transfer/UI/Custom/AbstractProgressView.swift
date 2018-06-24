//
//  AbstractProgressView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 24/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa

class AbstractProgressView: VerboseView {
    var progressBgColor = R.color.white
    var progressFgColor = R.color.black
    
    internal var mProgress: CGFloat = 0.0
    var animationProgress: CGFloat = 0.0
    var previousProgress: CGFloat = 0.0
    
    var animationDurationInMs = 500
    let animationDelayInMs = NSView.Fps60_Delay
    var startTime = DispatchTime.now()
    
    /*override init(frame frameRect: Foundation.NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.cornerRadius(3.0)
    }
 */
    
    func setProgress(_ progress: CGFloat) {
        //        Swift.print("ProgressView, Time:", TimeUtils.getCurrentTime(), ", Progress:", progress)
        previousProgress = mProgress
        mProgress = progress
        startTime = TimeUtils.getDispatchTime()
        needsDisplay = true
    }
    
    func resetProgress() {
        previousProgress = 0
        animationProgress = 0
        mProgress = 0
        needsDisplay = true
    }
    
    func drawProgress(_ dirtyRect: NSRect) {
        LogW("Needs to be overridden")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        if (VerboseView.VERBOSE) {
            //            Swift.print("ProgressView, Drawing");
        }
        drawProgress(dirtyRect)
        if (mProgress > animationProgress) {
            let currentTime = TimeUtils.getDispatchTime()
            let timeTakenInNano = currentTime.uptimeNanoseconds - startTime.uptimeNanoseconds
            let animationDurationInMs = Double(self.animationDurationInMs)
            var t = Double(timeTakenInNano / 1_000_000) / Double(animationDurationInMs)
            if (t > 1.0) {
                t = 1.0
            }
            let y = CGFloat(AnimationUtils.solve(t: t, curveType: .easeInEaseOut))
            let diff = (mProgress - previousProgress)
            animationProgress = previousProgress + (diff * y)
            //            LogV("Anim Prog: \(animationProgress), orig: \(mProgress), \(t) : \(y)")
            ThreadUtils.runInMainThreadAfter(delayMs: self.animationDelayInMs) {
                self.needsDisplay = true
            }
        } else {
            //            LogD("Anim Done")
        }
    }
}
