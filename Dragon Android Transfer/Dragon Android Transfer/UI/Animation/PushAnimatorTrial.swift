//
//  PushAnimatorTrial.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation
import Cocoa

public class PushAnimatorTrial: NSObject, NSViewControllerPresentationAnimator {
	
	public func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
		// bool indicating whether the view uses a layer as its backing store
		viewController.view.wantsLayer = true
		// http://stackoverflow.com/a/30425508/2179970
		viewController.view.layer?.backgroundColor = CGColor.init(red: 1, green: 0, blue: 0, alpha: 0)
		viewController.view.frame = CGRect(x: fromViewController.view.frame.size.width, y: 0,
				width: fromViewController.view.frame.size.width, height: fromViewController.view.frame.size.height)
		fromViewController.addChildViewController(viewController)
		fromViewController.view.addSubview(viewController.view)
		
		let futureFrame = CGRect(x: 0, y: 0, width: viewController.view.frame.size.width,
				height: viewController.view.frame.size.height)
		
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.75
			viewController.view.animator().frame = futureFrame
			
		}, completionHandler: nil)
	}
	
	public func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
		let futureFrame = CGRect(x: viewController.view.frame.size.width, y: 0,
				width: viewController.view.frame.size.width, height: viewController.view.frame.size.height)
		
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 0.75
			context.completionHandler = {
				viewController.view.removeFromSuperview()
				viewController.removeFromParentViewController()
			}
			
			viewController.view.animator().frame = futureFrame
		}, completionHandler: nil)
		
	}
}
