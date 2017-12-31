//
//  MenuViewController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class MenuViewController: NSViewController {
    
    @IBOutlet weak var label: NSTextField!
    @IBAction func closeMenu(_ sender: Any) {
        print("Close Menu")
//        animate(open: true) {
//            print("Close end")
//            self.dismissViewController(self)
//        }
    }
	
//	internal func getWind() -> NSWindow {
//		LogV("Menu Win", view.window)
//		return view.window!
//	}
	
	public var frameSize = NSRect()
    
//    private func animate(open: Bool, handler: @escaping () -> ()) {
//        let window = getWind()
//        //window.setFrame(frameSize, display: true)
//        //self.view.frame.size = NSSize(width: frameSize.width, height: frameSize.height)
//        var dx = self.view.frame.size.width
//        if (!open) {
//            dx = -dx
//        }
//        print("Dx", dx)
//        self.view.frame = self.view.frame.offsetBy(dx: -dx, dy: 0)
//        NSAnimationContext.runAnimationGroup({ context in
//            context.duration = 1
//            self.view.animator().frame = self.view.frame.offsetBy(dx: dx, dy: 0)
//        }, completionHandler: handler)
//    }
	
	func closeWindow(_ notification: NSNotification) {
		//LogI("Close Window!", notification)
//		if (notification.name == NSNotification.Name.NSWindowDidUpdate) {
//			LogV("Update")
//		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
        /*
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = .viewNotSizable
 */

	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
        print("Menu, view!")
        let center = NotificationCenter.default
        //center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidResignKey, object: getWind())
		
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidResignMain, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidBecomeKey, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidBecomeMain, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidChangeScreen, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidDeminiaturize, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidExpose, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidMiniaturize, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidMove, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidResignKey, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidResize, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidUpdate, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowWillClose, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowWillMiniaturize, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowWillMove, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowWillBeginSheet, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowWillBeginSheet, object: getWind())
//        center.addObserver(self, selector: #selector(closeWindow), name: NSNotification.Name.NSWindowDidChangeOcclusionState, object: getWind())

//		self.view.window?.titleVisibility = NSWindowTitleVisibility.Hidden;
//		self.view.window?.titlebarAppearsTransparent = YES;
////        self.view.window?.styleMask |= NSFullSizeContentViewWindowMask;
//		self.window.styleMask.insert(.fullSizeContentView)
		
		/*
		
		self.view.window?.titleVisibility = NSWindowTitleVisibility.hidden
		self.view.window?.titlebarAppearsTransparent = true
		self.view.window?.isMovableByWindowBackground = true
		self.view.window?.styleMask = NSWindowStyleMask.fullSizeContentView
		*/
		
		
//		getWind().standardWindowButton(NSWindowButton.closeButton)?.isHidden = true
//		getWind().standardWindowButton(NSWindowButton.miniaturizeButton)?.isHidden = true
//		getWind().standardWindowButton(NSWindowButton.zoomButton)?.isHidden = true
//		
//		getWind().titleVisibility = .hidden
//		getWind().titlebarAppearsTransparent = true
//		getWind().styleMask.insert(.fullSizeContentView)
//		getWind().styleMask.remove(NSWindowStyleMask.resizable)
		
		print("Dark:", R.color.menuBgColor, R.color.dark)
		
		self.view.wantsLayer = true
		self.view.layer?.backgroundColor = R.color.menuBgColor.cgColor
		self.view.layerContentsRedrawPolicy = NSViewLayerContentsRedrawPolicy.onSetNeedsDisplay

//		let newSize = NSMakeRect(self.frame.origin.x,
//				self.frame.origin.y - 100,
//				self.frame.width, self.frame.height + 100)
		
		
//		let window = getWind()
//		window.setFrame(frameSize, display: true)
        self.view.frame.size = NSSize(width: frameSize.width, height: frameSize.height)
//        self.view.frame.size = NSRect(
//		window.animator().setFrame(window.frame.offsetBy(dx: -180, dy: 0), display: true)
//		window.animator().setFrame(window.frame.offsetBy(dx: 180, dy: 0), display: true, animate: true)


//		var windowFrame = self.view.window?.frame
//		let oldX = windowFrame?.origin.x
//		let oldY = windowFrame?.origin.y
//		let oldWidth = windowFrame?.size.width
//		let oldHeight = windowFrame?.size.height
//		let toAdd = CGFloat(50.0)
//		let newY = oldY! - toAdd
//		let newHeight = oldHeight! + toAdd
//		windowFrame? = NSMakeRect(oldX!, newY, oldWidth!, newHeight)
//		self.view.window?.animator().setFrame(windowFrame!, display: true, animate: true)
	/*
		window.animationBehavior = .none
		window.backgroundColor = .clear
		window.isMovableByWindowBackground = true
		
		*/
//		window.isMovable = false
		/*let dx = self.view.frame.size.width
		self.view.frame = self.view.frame.offsetBy(dx: -dx, dy: 0)
		NSAnimationContext.runAnimationGroup({ context in
			context.duration = 1
			view.animator().frame = self.view.frame.offsetBy(dx: dx, dy: 0)
		}, completionHandler: {
//			self.view.isHidden = true
		})*/
        
        
        
//        animate(open: true) {
//            print("Opened")
//        }
	}
	
	public func update(_ frame: NSRect) {
		
	}
	
//	override func mouseDown(_ event: NSEvent) {
//		super.mouseDown(event)
//		let windowFrame = [[self window] frame];
//		
//		initialLocation = [NSEvent mouseLocation];
//		
//		initialLocation.x -= windowFrame.origin.x;
//		initialLocation.y -= windowFrame.origin.y;
//	}
	
//	override func mouseDragged(_ event: NSEvent) {
//		super.mouseDragged(event)
//	}
//	
//	override func mouseUp(_ event: NSEvent) {
//		super.mouseUp(event)
//	}
	
	override func viewDidAppear() {
		super.viewDidAppear()
		LogV("viewDidAppear", label)
//		let window = getWind()
//		window.alphaValue = 0
//		let anim: [String: Any?] = [
////			NSViewAnimationTargetKey: nil,
//			NSViewAnimationTargetKey: window,
//			NSViewAnimationEndFrameKey: NSViewAnimationFadeInEffect
//		]
//		window.setFrame(window.frame.offsetBy(dx: -180, dy: 0), display: true)
//		let anim: [String: Any?] = [
////			NSViewAnimationTargetKey: nil,
//			NSViewAnimationTargetKey: window,
//			NSViewAnimationEndFrameKey: window.frame.offsetBy(dx: 180, dy: 0)
//		]
//		
//		let array = [anim]
//		let animation = NSViewAnimation(viewAnimations: array)
//		animation.animationBlockingMode = .nonblocking
//		animation.animationCurve = .easeIn
//		animation.duration = 1
//		animation.start()
//		LogV("viewDidAppear done")

//		self.view.frame = self.view.frame.offsetBy(dx: -180, dy: 0)
//		NSAnimationContext.runAnimationGroup({ context in
////			view.animator.frame = CGRectOffset(view.frame, 180, 0)
////			view.animator().frame = CGRect.offsetBy(180, 0)
//			view.animator().frame = self.view.frame.offsetBy(dx: 180, dy: 0)
//
////			self.window.animator().frame = self.window.offsetBy(dx: 180, dy: 0)
//			context.duration = 20
//		}, completionHandler: {
////			self.view.isHidden = true
//		})
	}
}
