//
//  ViewController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 11/3/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	var androidViewController: AndroidViewController? = nil 
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let mainStoryboard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
		let sourceViewController = mainStoryboard.instantiateController(withIdentifier: "androidViewController") as! NSViewController
		androidViewController = sourceViewController as? AndroidViewController
		self.insertChildViewController(sourceViewController, at: 0)
        self.view.wantsLayer = true
		self.view.addSubview(sourceViewController.view)
		self.view.frame = sourceViewController.view.frame
	}
}
