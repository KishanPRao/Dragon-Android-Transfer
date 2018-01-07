//
// Created by Kishan P Rao on 07/01/18.
// Copyright (c) 2018 Kishan P Rao. All rights reserved.
//

import Foundation
import WebKit

class AdViewController: NSViewController, WKNavigationDelegate {
	public var url = ""
	public var frameSize = NSRect()
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        if let window = self.view.window {
            LogV("Has Window!")
//            window.level = NSPopUpMenuWindowLevel
//            window.level = NSStatusWindowLevel
//            window.styleMask = .borderless
//            window.ignoresMouseEvents = true
//            window.collectionBehavior = .fullScreenPrimary
//            window.frame.size.width = frameSize.size.width
//            window.frame.size.height = frameSize.size.height
//            window.setFrame(frameSize, display: true)
//            LogI("Ctrl: ", window.windowController)
        }
    }
    
	override func viewDidLoad() {
		super.viewDidLoad()
        
        self.view.frame = NSRect(x: 0, y: 0, width: frameSize.width, height: 300)
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
