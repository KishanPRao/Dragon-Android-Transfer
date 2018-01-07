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
    
    override func windowDidLoad() {
        super.windowDidLoad()
        let frame = NSRect(x: 0, y: 0, width: frameSize.width, height: 300)
        if let window = window {
            LogV("Loaded")
//            window.setFrame(NSRect(x: 0, y: 0, width: 1920, height: 50), display: true)
            window.setFrame(frame, display: true, animate: true)
//            window.styleMask = .borderless
        }
        
        self.view.frame = frame
        let url = URL(string: self.url)
        let request = URLRequest(url: url!)
        let webConfiguration = WKWebViewConfiguration()
        let webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = true
        webView.load(request)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
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
