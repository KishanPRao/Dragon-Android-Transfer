//
//  AVCUi.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

extension AndroidViewController {
	
	internal func initUi() {
        initTable()
		
		ColorUtils.setBackgroundColorTo(view, color: ColorUtils.mainViewColor)
		toolbarView.setBackground(R.color.toolbarColor)
		
		fileTable.backgroundColor = R.color.tableBg
		fileTable.selectionHighlightStyle = .none
		messageText.alignment = .center
//        messageText.font = NSFont(name: messageText.font!.fontName, size: DimenUtils.getDimension(dimension: Dimens.error_message_text_size))
//        let font = NSFont(name: R.font.mainFont, size: DimenUtils.getDimension(dimension: Dimens.error_message_text_size))
//        messageText.font = font
        messageText.updateMainFont(18.0)
		messageText.textColor = R.color.textColor
		messageText.setBackground(R.color.tableBg)
        self.resetDeviceStatus()
		updateDeviceStatus()
		
		menuButton.setImage(name: "menu")
        //        TODO: Tooltip problem on menu open
        menuButton.toolTip = R.string.helpMenu
		backButton.setImage(name: R.drawable.path_selector_back)
        backButton.toolTip = R.string.helpBack
		
		overlayView.isHidden = true
		overlayView.setBackground(R.color.menuBgColor)
		
		/*
		let progressSize = 120.0 as CGFloat
		//TODO: Move to storyboard.
		mCircularProgress = IndeterminateProgressView(
			frame: NSRect(x: (self.view.frame.width - progressSize) / 2.0,
						  y: (self.view.frame.height - progressSize) / 2.0,
						  width: progressSize,
						  height: progressSize))
		self.view.addSubview(mCircularProgress!)
		mCircularProgress?.isHidden = true
 */
		
//        pathSelectorRootView.setBackground(R.color.pathSelectorBg)
        pathSelectorRootView.setBackground(R.color.clear)
		loadingProgress.isHidden = true
		//        parent.center fromView:parent.superview];
	}
	
	@objc internal func showProgress() {
        self.fileTable.enableKeys = false
		self.loadingProgress.show()
		self.overlayView.show()
	}
	
	internal func hideProgress() {
		self.loadingProgress.hide()
		self.overlayView.hide()
        self.fileTable.enableKeys = true
        fileTable.makeFirstResponder(self.view.window)
		/*
		NSAnimationContext.runAnimationGroup({ _ in
			NSAnimationContext.current().duration = 0.5
			self.loadingProgress.animator().alphaValue = 0.0
		}, completionHandler: {
			//print("Animation completed")
			//self.mCircularProgress?.isHidden = true
		})
		// self.mCircularProgress?.isHidden = true
 */
	}
}
