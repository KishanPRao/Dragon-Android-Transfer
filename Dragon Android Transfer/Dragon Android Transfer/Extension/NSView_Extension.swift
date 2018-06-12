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
	
	func cornerRadius(_ radius: CGFloat = 5.0) {
//        self.layer?.masksToBounds = true
		self.wantsLayer = true
		self.layer?.cornerRadius = radius
	}
    
    func loadNib() {
		let nibName = String(describing: type(of: self))
//        LogV("Load Nib for", nibName)
//        LogV("Load Nib for", String(describing: type(of: self)))
		Bundle.main.loadNibNamed(NSNib.Name(rawValue: nibName), owner: self, topLevelObjects: nil)
    }
	
//	class func fromNib<T:NSView>() -> T? {
//		var viewArray = NSArray()
//		guard Bundle.main.loadNibNamed(String(describing: T.self), owner: T.self, topLevelObjects: &viewArray) else {
//			Swift.print("Type:", String(describing: T.self))
//			Swift.print("Type2:", T.self)
//			Swift.print("Type3:", NSStringFromClass(T.self))
//			return nil
//		}
//		return viewArray.first(where: { $0 is T }) as? T
//	}
    func makeFirstResponder(_ window: NSWindow?) {
        if (self.acceptsFirstResponder) {
            window?.makeFirstResponder(self)
        }
    }
	
	func bringToFront() {
		if (isInFront()) {
//            LogV("is in front!")
			return
		}
		let superView = self.superview
		if let superView = superView {
			self.removeFromSuperview()
			superView.addSubview(self, positioned: .above, relativeTo: nil)
		}
	}
	
	func isInFront() -> Bool {
		let view = self
		let visibleBool = view.superview?.subviews.last?.isEqual(view)
		if let visibleBool = visibleBool, visibleBool {
			return visibleBool
		} else {
			return false
		}
	}
    
    func animate(show: Bool) {
        if (show && alphaValue == 1.0) || (!show && alphaValue == 0) {
            return
        }
        let alpha = (show ? 1.0 : 0.0) as CGFloat
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = R.integer.animStartDuration
            self.animator().alphaValue = alpha
        }, completionHandler: nil)
    }
}
