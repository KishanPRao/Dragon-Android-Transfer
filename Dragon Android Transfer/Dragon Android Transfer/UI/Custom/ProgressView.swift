//
//  ProgressView.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class ProgressView: AbstractProgressView {
	required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.cornerRadius(3.0)
    }
    
    override func drawProgress(_ dirtyRect: NSRect) {
        progressBgColor.set()
        NSBezierPath.fill(dirtyRect)
        progressFgColor.set()
        let width = dirtyRect.width * (animationProgress / 100.0)
        let rect = CGRect(x: 0, y: 0, width: width, height: dirtyRect.height)
        NSBezierPath.fill(rect)
    }
}
