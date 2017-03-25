//
// Created by Kishan P Rao on 11/03/17.
// Copyright (c) 2017 Untitled-TBA. All rights reserved.
//

import Foundation

class SegueFromLeft: NSStoryboardSegue {
	override func perform() {
//		src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
//		dst.view.transform = CGAffineTransformMakeTranslation(-src.view.frame.size.width, 0)

//		UIView.animateWithDuration(0.25,
//				delay: 0.0,
//				options: UIViewAnimationOptions.CurveEaseInOut,
//				animations: {
//					dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
//				},
//				completion: { finished in
//					src.presentViewController(dst, animated: false, completion: nil)
//				}
//		)


//		if let src = self.sourceController as? NSViewController,
//		   let dst = self.destinationController as? NSViewController {
//			src.view.superview?.addSubview(dst.view, positioned: NSWindowOrderingMode.Above, relativeTo: src.view)
//			dst.view.layer
//			dst.view.transform = CGAffineTransformMakeTranslation(-src.view.frame.size.width, 0)
//			
//			UIView.animateWithDuration(0.25,
//					delay: 0.0,
//					options: UIViewAnimationOptions.CurveEaseInOut,
//					animations: {
//						dst.view.transform = CGAffineTransformMakeTranslation(0, 0)
//					},
//					completion: { finished in
//						src.presentViewController(dst, animated: false, completion: nil)
//					}
//			)
//		}
		
		if let src = self.sourceController as? NSViewController,
		   let dest = self.destinationController as? NSViewController,
		   let window = src.view.window {
			let animator = MyCustomSwiftAnimator()
			src.presentViewController(dest, animator: animator)
//			let animator = NSViewControllerPresentationAnimator().animatePresentationOfViewController(dest, fromViewController: src)
//			src.presentViewController(dest, animator: animator)
//			NSViewControllerPresentationAnimator.animatePresentationOfViewController(dest, fromViewController: src)
		}

//		if let src = self.sourceController as? NSViewController,
//		   let dest = self.destinationController as? NSViewController,
//		   let window = src.view.window {
//			// calculate new frame:
//			var rect = window.frameRectForContentRect(dest.view.frame)
//			rect.origin.x += (src.view.frame.width - dest.view.frame.width) / 2
//			rect.origin.y += src.view.frame.height - dest.view.frame.height
//			// don’t shrink visible content, prevent minsize from intervening:
//			window.contentViewController = nil
//			// animate resizing (TODO: crossover blending):
//			window.setFrame(window.convertRectToScreen(rect), display: true, animate: true)
//			// set new controller
//			window.contentViewController = dest
//		}
	}
	
}