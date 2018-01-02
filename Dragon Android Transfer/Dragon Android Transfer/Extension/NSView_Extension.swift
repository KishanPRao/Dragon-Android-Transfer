//
//  NSView_Extension.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 31/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension NSView {
    internal static let FPS = 30.0 as Double
    //internal static let FPS = 60.0 as Double
    internal static let FPS_DELAY = Int(FPS / (1000.0 as Double))
    
    public func setBackground(_ color: NSColor) {
        self.wantsLayer = true
        layer?.backgroundColor = color.cgColor
    }
    
    func dropShadow() {
        self.shadow = NSShadow()
        //self.layer?.backgroundColor = NSColor.red.cgColor
        //self.layer?.cornerRadius = 5.0
        self.layer?.shadowOpacity = 1.0
        //self.layer?.shadowColor = ColorUtils.colorWithHexString("132e5a").cgColor
        self.layer?.shadowColor = NSColor.black.cgColor
        self.layer?.shadowOffset = NSMakeSize(0, 0)
        self.layer?.shadowRadius = 20
    }
    
    class func fromNib<T: NSView>() -> T? {
        var viewArray = NSArray()
        guard Bundle.main.loadNibNamed(String(describing: T.self), owner: T.self, topLevelObjects: &viewArray) else {
            Swift.print("Type:", String(describing: T.self))
            Swift.print("Type2:", T.self)
            Swift.print("Type3:", NSStringFromClass(T.self))
            return nil
        }
        return viewArray.first(where: { $0 is T }) as? T
    }
}
