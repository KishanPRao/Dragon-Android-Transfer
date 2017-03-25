//
// Created by Kishan P Rao on 11/03/17.
// Copyright (c) 2017 Untitled-TBA. All rights reserved.
//

import Foundation

class CrossfadeSegue: NSStoryboardSegue {
	
	override init(identifier: String?, source sourceController: Any, destination destinationController: Any) {
		let myIdentifier: String
		if identifier == nil {
			myIdentifier = ""
		} else {
			myIdentifier = identifier!
		}
		super.init(identifier: myIdentifier, source: sourceController, destination: destinationController)
	}
	
	
	override func perform() {
		let sourceViewController = self.sourceController as! NSViewController
		let destinationViewController = self.destinationController as! NSViewController
		let containerViewController = sourceViewController.parent! as NSViewController
		
		containerViewController.insertChildViewController(destinationViewController, at: 1)
		
		let targetSize = destinationViewController.view.frame.size
		let targetWidth = destinationViewController.view.frame.size.width
		let targetHeight = destinationViewController.view.frame.size.height
		
		sourceViewController.view.wantsLayer = true
		destinationViewController.view.wantsLayer = true
		
		containerViewController.transition(from: sourceViewController, to: destinationViewController, options: NSViewControllerTransitionOptions.crossfade, completionHandler: nil)
		
		sourceViewController.view.animator().setFrameSize(targetSize)
		destinationViewController.view.animator().setFrameSize(targetSize)
		
		let currentFrame = containerViewController.view.window?.frame
		let currentRect = NSRectToCGRect(currentFrame!)
		let horizontalChange = (targetWidth - containerViewController.view.frame.size.width) / 2
		let verticalChange = (targetHeight - containerViewController.view.frame.size.height) / 2
		let newWindowRect = NSMakeRect(currentRect.origin.x - horizontalChange, currentRect.origin.y - verticalChange, targetWidth, targetHeight)
		containerViewController.view.window?.setFrame(newWindowRect, display: true, animate: true)
		
		containerViewController.removeChildViewController(at: 0)
	}
}
