//
//  ViewController.swift
//  Simple Android Transfer
//
//  Created by Kishan P Rao on 11/3/17.
//  Copyright © 2017 Untitled-TBA. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let mainStoryboard: NSStoryboard = NSStoryboard(name: "Main", bundle: nil)
		let sourceViewController = mainStoryboard.instantiateController(withIdentifier: "androidViewController") as! NSViewController
		self.insertChildViewController(sourceViewController, at: 0)
        self.view.wantsLayer = true
		self.view.addSubview(sourceViewController.view)
		self.view.frame = sourceViewController.view.frame
	}
}
