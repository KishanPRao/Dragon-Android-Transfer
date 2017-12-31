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
        //overlayView = ClickableView(frame: NSRect(x: 0, y: 0, width: 100, height: 100))
        // fileTable.delegate = self
        fileTable.delegate = tableDelegate
        tableDelegate.setAndroidDirectoryItems(items: androidDirectoryItems)
        tableDelegate.fileTable = fileTable
        fileTable.dragDelegate = self
        fileTable.dragUiDelegate = self
        let doubleClickSelector: Selector = #selector(AndroidViewController.doubleClickList(_:))
        fileTable.doubleAction = doubleClickSelector
        
        self.devicesPopUp.removeAllItems()
        self.devicesPopUp.action = #selector(AndroidViewController.onPopupSelected(_:))
        self.devicesPopUp.target = self
        updatePopupDimens()
        
        overlayView.isHidden = true
        
        ColorUtils.setBackgroundColorTo(view, color: ColorUtils.mainViewColor)
        ColorUtils.setBackgroundColorTo(toolbarView, color: ColorUtils.toolbarColor)
        ColorUtils.setBackgroundColorTo(deviceSelectorView, color: ColorUtils.storageToolbarDeselectedColor)
        ColorUtils.setBackgroundColorTo(statusView, color: ColorUtils.statusViewColor)
        
        internalStorageButton.normalColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarDeselectedColor)
        internalStorageButton.pressedColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarSelectedColor)
        internalStorageButton.pressedSelectedColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarPressedSelectedColor)
        internalStorageButton.textSelectedColor = ColorUtils.colorWithHexString(ColorUtils.storageSelectedTextColor)
        internalStorageButton.textDeselectedColor = ColorUtils.colorWithHexString(ColorUtils.storageDeselectedTextColor)
        
        externalStorageButton.normalColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarDeselectedColor)
        externalStorageButton.pressedColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarSelectedColor)
        externalStorageButton.pressedSelectedColor = ColorUtils.colorWithHexString(ColorUtils.storageToolbarPressedSelectedColor)
        externalStorageButton.textSelectedColor = ColorUtils.colorWithHexString(ColorUtils.storageSelectedTextColor)
        externalStorageButton.textDeselectedColor = ColorUtils.colorWithHexString(ColorUtils.storageDeselectedTextColor)
        
        fileTable.backgroundColor = ColorUtils.colorWithHexString(ColorUtils.listBackgroundColor)
        fileTable.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.none
        //        fileTable.draggingDestinationFeedbackStyle = NSTableViewDraggingDestinationFeedbackStyle.sourceList
        
        externalStorageButton.isHidden = true
        
        var image = NSImage(named: "back_button.png")
        image!.size = backButton.cellSize
        backButton.image = image!
        
        //		backButton.imageScaling = NSImageScaling.ScaleProportionallyDown
        //		backButton.imageScaling = NSImageScaling.ScaleProportionallyUpOrDown
        backButton.imageScaling = NSImageScaling.scaleAxesIndependently
        
        clipboardIcon = NSImage(named: "clipboard_icon.png")
        clipboardIconPlain = NSImage(named: "clipboard_icon_plain.png")
        StyleUtils.updateButton(clipboardButton, withImage: clipboardIcon)
        
        image = NSImage(named: "refresh.png")
        StyleUtils.updateButtonWithCell(refreshButton, withImage: image)
        //		backButton.imageScaling = NSImageScaling.ScaleProportionallyDown
        //		clipboardButton.scale = NSImageScaling.ScaleProportionallyUpOrDown
        messageText.alignment = NSCenterTextAlignment
        messageText.font = NSFont(name: messageText.font!.fontName, size: DimenUtils.getDimension(dimension: Dimens.error_message_text_size))
        updateDeviceStatus()
        updateActiveStorageButton()
        
        //		fileTable.register(forDraggedTypes: [NSGeneralPboard])
        
        
        let imageView = NSImageView()
        imageView.image = NSApplication.shared().applicationIconImage
        mDockTile.contentView = imageView
        
        mDockProgress = NSProgressIndicator(frame: NSMakeRect(0.0, 0.0, mDockTile.size.width, 10))
        mDockProgress?.style = NSProgressIndicatorStyle.barStyle
        mDockProgress?.isIndeterminate = false
        mDockProgress?.minValue = 0
        mDockProgress?.maxValue = 100
        imageView.addSubview(mDockProgress!)
        
        mDockProgress?.isBezeled = true
        mDockProgress?.isHidden = true
        
        let progressSize = 120.0 as CGFloat
        //TODO: Move to storyboard.
        mCircularProgress = IndeterminateProgressView(
            frame: NSRect(x: (self.view.frame.width - progressSize) / 2.0,
                          y: (self.view.frame.height - progressSize) / 2.0,
                          width: progressSize,
                          height: progressSize))
        self.view.addSubview(mCircularProgress!)
        mCircularProgress?.isHidden = true
        //        parent.center fromView:parent.superview];
    }
    
    internal func showProgress() {
        self.mCircularProgress?.alphaValue = 1.0
        self.mCircularProgress?.isHidden = false
    }
    
    internal func hideProgress() {
        NSAnimationContext.runAnimationGroup({ _ in
            NSAnimationContext.current().duration = 0.5
            self.mCircularProgress?.animator().alphaValue = 0.0
        }, completionHandler: {
            //print("Animation completed")
            //self.mCircularProgress?.isHidden = true
        })
        // self.mCircularProgress?.isHidden = true
    }
    
    internal func updatePopupDimens() {
        //TODO: Update only when needed.
        devicesPopUp.font = NSFont.userFont(ofSize: DimenUtils.getDimension(dimension: Dimens.android_controller_toolbar_device_popup_text_size))
        let popupRect = DimenUtils.getUpdatedRect(dimensions: Dimens.android_controller_toolbar_device_popup)
        var width: CGFloat
        if (androidDevices.count > 0) {
            devicesPopupButton.sizeToFit()
            width = devicesPopupButton.frame.width
        } else {
            width = popupRect.width
        }
        devicesPopupButton.frame = CGRect(x: popupRect.origin.x, y: popupRect.origin.y, width: width, height: popupRect.height)
    }
}
