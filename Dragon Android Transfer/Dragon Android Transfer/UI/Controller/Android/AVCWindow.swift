//
//  AVCWindow.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension AndroidViewController {
	
	func resetPosition() {
		let previousFrame = self.view.window!.frame
		//		let rect = CGRect(x: previousFrame.origin.x, y: 0, width: previousFrame.width, height: previousFrame.height)
		let screenFrame = self.view.window!.screen!.frame
		let screenVisibleFrame = self.view.window!.screen!.visibleFrame
		//		Swift.print("AndroidViewController, before, visible:", screenVisibleFrame, ", frame:", screenFrame, ", prev:", previousFrame)
		let extraHeight = (screenFrame.height - screenVisibleFrame.height) + (screenFrame.origin.y - screenVisibleFrame.origin.y)
		let y = (screenVisibleFrame.height / 2) - (previousFrame.height / 2) + screenVisibleFrame.origin.y + extraHeight
		let x = (screenVisibleFrame.width / 2) - (previousFrame.width / 2) + screenVisibleFrame.origin.x
		let rect = CGRect(x: x, y: y, width: previousFrame.width, height: previousFrame.height)
		//		Swift.print("AndroidViewController, visible:", screenVisibleFrame, ", frame:", screenFrame, ", rect:", rect)
		self.view.window!.setFrame(rect, display: true)
	}
	
	
	func updateWindowSize() {
		if (!dirtyWindow) {
			return
		}
		if (self.view.window == nil) {
			//			Swift.print("AndroidViewController, Warning! Null Window")
			return
		}
		let screen = self.view.window!.screen!
		//		Swift.print("AndroidViewController, current screen:", screen.visibleFrame.width)
		DimenUtils.updateRatio(currentWidth: screen.visibleFrame.width)
		
		let windowFrame = self.view.window!.frame
		let newSize = DimenUtils.getUpdatedRect2(frame: windowFrame, dimensions: Dimens.android_controller_size)
		let extraHeight = (screen.frame.height - screen.visibleFrame.height) + (screen.frame.origin.y - screen.visibleFrame.origin.y)
		
		let finalRect = CGRect(x: newSize.origin.x, y: newSize.origin.y + (windowFrame.height - newSize.height) - extraHeight, width: newSize.width, height: newSize.height + extraHeight)
		
		//		Swift.print("AndroidViewController, previous:", windowFrame)
		//		Swift.print("AndroidViewController, new:", finalRect)
		
		if (finalRect.width == windowFrame.width) {
			if (NSObject.VERBOSE) {
				//                Swift.print("AndroidViewController, Warning! No Changes to Window")
			}
			return
		}
		//		TODO: Fix flickering screen update, if occurs again..
		//		Swift.print("AndroidViewController, extra H:", extraHeight)
		//		Swift.print("AndroidViewController, frame:", screen.frame)
		//		Swift.print("AndroidViewController, v frame:", screen.visibleFrame)
		//		Swift.print("AndroidViewController, origin:", self.view.window!.frame.origin.y)
		//		self.view.window!.setContentSize(NSSize(width: newSize.width, height: newSize.height))
		self.view.window!.setFrame(finalRect, display: true)
		view.frame = DimenUtils.getUpdatedRect2(frame: view.frame, dimensions: Dimens.android_controller_size)
		
		toolbarView.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_toolbar)
		//fileTable.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table)
		//		let scrollViewFrame = fileTable.enclosingScrollView!.frame
		//fileTable.enclosingScrollView!.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_file_table)
		updateList()
		
		messageText.font = NSFont(name: messageText.font!.fontName, size: DimenUtils.getDimension(dimension: Dimens.error_message_text_size))
		messageText.frame = DimenUtils.getUpdatedRect(dimensions: Dimens.error_message_text)

//        if (copyDialog != nil) {
//            let width = DimenUtils.getDimensionInInt(dimension: Dimens.copy_dialog_width)
//            let height = DimenUtils.getDimensionInInt(dimension: Dimens.copy_dialog_height)
//            let x = Int(getWindowWidth() / 2) - width / 2
//            let y = Int(getWindowHeight() / 2) - height / 2
//            copyDialog!.updateSize(x: x, y: y, width: width, height: height)
//        }
		//		if (helpWindow != nil && helpWindow!.isShowing) {
		if (helpWindow != nil && helpWindow!.isShowing && helpWindow!.needsUpdating()) {
			//			helpWindow!.updateSizes()
			Swift.print("AndroidViewController, updating Help")
			helpWindow!.endSheet()
			helpWindow!.setIsIntro(intro: shouldShowGuide())
			helpWindow!.updateSizes()
			helpWindow!.isShowing = true
			self.view.window!.beginSheet(helpWindow!.window!) { response in
				if (NSObject.VERBOSE) {
					Swift.print("AndroidViewController, Resp!");
				}
			}
		}
		dirtyWindow = false
	}
	
	internal func getWindowHeight() -> CGFloat {
		return self.view.bounds.height
	}
	
	internal func getWindowWidth() -> CGFloat {
		return self.view.bounds.width
	}
	
	internal func getScreenResolution() {
		let screenArray = NSScreen.screens()
		var index = 0
		while (index < screenArray!.count) {
			let screen = screenArray![index]
			index = index + 1
			Swift.print("AndroidViewController, screen:", screen)
			//			screen.
		}
		Swift.print("AndroidViewController, screens:", screenArray!)
		//		let screenRect = 
	}
	
	func screenUpdated() {
		/*updateWindowSize()
		 checkGuide()
		 */
	}
}
