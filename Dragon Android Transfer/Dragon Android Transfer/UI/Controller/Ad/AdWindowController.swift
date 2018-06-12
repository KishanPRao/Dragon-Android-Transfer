//
//  AdWindowController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 08/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Cocoa
//import WebKit

class AdWindowController: NSWindowController, WKNavigationDelegate {
	public var frameSize = NSRect()
    @IBOutlet weak var view: NSView!
    public var url = ""
    var width = 500.0 as CGFloat
    var height = 300.0 as CGFloat
    var webView: WKWebView? = nil
    var isClosable = false
    
    public func updateFrame(_ frame: NSRect) {
    	frameSize = frame
//        LogD("Update frame: \(frame)")
        let frame = NSRect(x: frameSize.origin.x + frameSize.width,
                           y: frameSize.origin.y + (frame.size.height / 2.0) - (height / 2.0),
                           width: width,
                           height: height)
        if let window = window {
//            window.setFrame(frame, display: true)
            window.setFrame(frame, display: true, animate: true)
            var viewFrame = frame
//            if isClosable {
                viewFrame.size.height = viewFrame.size.height - window.titlebarHeight
//            }
            self.view.frame.size = viewFrame.size
            webView?.frame.size = viewFrame.size
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        LogI("Frame: \(frameSize)")
        if let window = window {
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.styleMask.remove( [ NSWindow.StyleMask.resizable ] )
            
            if isClosable {
//                window.standardWindowButton(.zoomButton)?.superview?.setBackground(R.color.windowBg)
            } else {
//                window.standardWindowButton(.zoomButton)?.superview?.isHidden = true
//                window.styleMask = .borderless
//                window.styleMask.remove( [ .titled ] )
            }
            window.standardWindowButton(.zoomButton)?.superview?.setBackground(R.color.windowBg)
            
            window.isMovable = false
            
            window.standardWindowButton(.closeButton)?.isHidden = !isClosable
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
            webView.acceptsTouchEvents = true
        	webView.translatesAutoresizingMaskIntoConstraints = true
        	webView.load(request)
        	webView.navigationDelegate = self
        	self.view.addSubview(webView)
        }
        self.view.setBackground(R.color.black)
        LogV("View Loaded")
        //        TODO: If failed loading..
    }
 
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        LogV("Failed")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        LogV("Start")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        LogV("Finish")
        webView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
            if complete != nil {
                webView.evaluateJavaScript("document.body.offsetHeight", completionHandler: { (height, error) in
                    if let height = height as? CGFloat {
//                    self.frameSize.size.height = height! as! CGFloat
                    	self.height = height + self.window!.titlebarHeight
                        self.LogI("Height: \(self.height)")
                    	self.updateFrame(self.frameSize)
                    }
                })
            }
        })
    }
}
