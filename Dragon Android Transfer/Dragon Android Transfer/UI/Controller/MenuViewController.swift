//
//  MenuViewController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 29/12/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

import RxSwift

class MenuViewController: NSViewController,
NSTableViewDelegate, NSTableViewDataSource
{
    @IBOutlet weak var overlayView: ClickableView!
    @IBOutlet weak var navigationParent: NSView!
    @IBOutlet weak var back: ImageButton!
    @IBOutlet weak var popup: NSPopUpButtonCell!
    @IBOutlet weak var table: NSTableView!
    @IBOutlet weak var tableOuter: NSScrollView!
    
    @IBOutlet weak var testPopup: NSPopUpButton!
    internal let transferHandler = TransferHandler.sharedInstance
    let AnimationDuration = 0.25
    public var frameSize = NSRect()
    internal var storages = [StorageItem]()
    
    @IBAction func closeMenu(_ sender: Any) {
        print("Close Menu")
        animate(open: false) {
            print("Close end")
            self.view.removeFromSuperview()
            self.removeFromParentViewController()
        }
    }
	/*
	override func viewDidLoad() {
		super.viewDidLoad()
        
	}*/
	
	override func viewWillAppear() {
		super.viewWillAppear()
		
        print("Menu, view!")
        
        initUi()
        observe()
	}
    
    private func initUi() {
        
        //self.view.wantsLayer = true
        //self.view.layer?.backgroundColor = R.color.menuBgColor.cgColor
        //self.view.layerContentsRedrawPolicy = NSViewLayerContentsRedrawPolicy.onSetNeedsDisplay
        initUiContent()
        initSizes()
        animate(open: true) {
            print("Opened")
        }
        /*overlayView.setOnClickListener() {
            self.closeMenu(nil)
        }*/
        
        overlayView.setOnClickListener() {
            print("Done")
            self.closeMenu(self)
        }
    }
    
    func onPopupSelected(_ sender: Any) {
        let index = self.popup.indexOfSelectedItem
        print("Popup Selected", index)
    }
    
    private func initUiContent() {
        //print("Dark:", R.color.menuBgColor, R.color.dark)
        self.popup.removeAllItems()
        self.popup.action = #selector(onPopupSelected(_:))
        self.popup.target = self
        overlayView.setBackground(R.color.menuBgColor)
        navigationParent.setBackground(R.color.menuNavColor)
        navigationParent.dropShadow()
        //testPopup.layer?.backgroundColor = R.color.black.cgColor
        //popup.backgroundColor = R.color.black
        table.backgroundColor = R.color.menuTableColor
        table.delegate = self
        table.dataSource = self
        back.setImage(name: "menu_back.png")
    }
    
    private func initSizes() {
        let newSize = NSSize(width: frameSize.width, height: frameSize.height)
        self.view.frame.size = newSize
        self.overlayView.frame.size = newSize
        
        let navigationSize = NSSize(width: frameSize.width * 0.5, height: frameSize.height)
        self.navigationParent.frame.origin = self.view.frame.origin
        self.navigationParent.frame.size = navigationSize
        self.tableOuter.frame.origin = CGPoint(x: 0, y: popup.accessibilityFrame().origin.y - popup.cellSize.height)
        self.tableOuter.frame.size = NSSize(width: frameSize.width * 0.5, height: frameSize.height - popup.cellSize.height)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
    }
    
    private func animate(open: Bool, handler: @escaping () -> ()) {
        //window.setFrame(frameSize, display: true)
        //self.view.frame.size = NSSize(width: frameSize.width, height: frameSize.height)
        let animView = self.navigationParent!
        let fadeView = self.overlayView!
        var dx = animView.frame.size.width
        var alpha = CGFloat(1.0)
        if (open) {
            animView.frame = animView.frame.offsetBy(dx: -dx, dy: 0)
            fadeView.alphaValue = 0
        } else {
            dx = -dx
            alpha = 1 - alpha
        }
        
        print("Dx", dx)
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = AnimationDuration
            animView.animator().frame = animView.frame.offsetBy(dx: dx, dy: 0)
            fadeView.animator().alphaValue = alpha
        }, completionHandler: handler)
    }
}
