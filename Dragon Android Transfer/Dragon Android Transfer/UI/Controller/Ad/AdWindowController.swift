//
//  AdWindowController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 08/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa

class AdWindowController: NSWindowController, WKNavigationDelegate {
	public var frameSize = NSRect()
    @IBOutlet weak var view: NSView!
    public var url = ""
    let height = 300.0 as CGFloat
    var webView: WKWebView? = nil
    
    public func updateFrame(_ frame: NSRect) {
    	frameSize = frame
        let frame = NSRect(x: frameSize.origin.x + frameSize.width, y: frameSize.origin.y + height / 2.0,
                           width: frameSize.width, height: height)
        if let window = window {
//            window.setFrame(frame, display: true)
            window.setFrame(frame, display: true, animate: true)
            self.view.frame.size = window.frame.size
            webView?.frame.size = frame.size
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        LogI("Frame: \(frameSize)")
        if let window = window {
//            window.styleMask = .borderless
//            window.styleMask = .fullScreen
            //            window.styleMask = .titled	//Best
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window .styleMask.remove( [ .resizable ] )
            
//            window.resize
            window.isMovable = false
            
            window.standardWindowButton(.zoomButton)?.superview?.setBackground(R.color.windowBg)
            
            window.standardWindowButton(.zoomButton)?.isHidden = true
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.fullScreenButton)?.isHidden = true
        }
        updateFrame(frameSize)
//        let frame = NSRect(x: frameSize.origin.x + frameSize.width, y: frameSize.origin.y + height / 2.0,
//                           width: frameSize.width, height: height)
        
//        self.view.frame = window!.frame
        let url = URL(string: self.url)
        let request = URLRequest(url: url!)
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        if let webView = webView {
        	webView.translatesAutoresizingMaskIntoConstraints = true
        	webView.load(request)
        	webView.navigationDelegate = self
        	self.view.addSubview(webView)
        }
        LogV("View Loaded")
    }
 
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        LogV("Failed")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        LogV("Start")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LogV("Finish")
    }
}
