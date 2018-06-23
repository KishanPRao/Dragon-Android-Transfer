//
//  AnimationUtils.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 23/06/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa

class AnimationUtils: NSObject {
    static let timingFunction = UnitBezierMac()
    
    static func solve(t: Double, curveType: BezierCurveType = .linear) -> Double {
        timingFunction.updateCurveType(curveType)
        return timingFunction.solve(t)
    }
}
