//
// Created by Kishan P Rao on 11/03/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class MyCustomSwiftAnimator: NSObject, NSViewControllerPresentationAnimator {
	
	func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
		let bottomVC = fromViewController
		let topVC = viewController
		topVC.view.wantsLayer = true
//		topVC.view.layerContentsRedrawPolicy = .onSetNeedsDisplay
		topVC.view.layerContentsRedrawPolicy = NSView.LayerContentsRedrawPolicy.onSetNeedsDisplay
		topVC.view.alphaValue = 0
		bottomVC.view.addSubview(topVC.view)
//		var frame : CGRect = NSRectToCGRect(bottomVC.view.frame)
//		frame = frame.insetBy(dx: 40, dy: 40)
		topVC.view.frame = NSRectFromCGRect(NSRectToCGRect(bottomVC.view.frame))
		NSAnimationContext.runAnimationGroup({ (context) -> Void in
			context.duration = 0.2
			topVC.view.animator().alphaValue = 1.0
			
		}, completionHandler: nil)
		
	}
	
	func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
		let topVC = viewController
		topVC.view.wantsLayer = true
		topVC.view.layerContentsRedrawPolicy = NSView.LayerContentsRedrawPolicy.onSetNeedsDisplay
		
		NSAnimationContext.runAnimationGroup({ (context) -> Void in
			context.duration = 0.2
			topVC.view.animator().alphaValue = 0
		}, completionHandler: {
			topVC.view.removeFromSuperview()
		})
	}


//	@objc func  animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
//	}
//	
//	
//	@objc func  animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
//	}
	
}
