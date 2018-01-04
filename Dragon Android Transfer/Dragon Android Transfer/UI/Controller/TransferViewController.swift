//
//  TransferViewController.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 04/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class TransferViewController: NSViewController {
    
    @IBOutlet weak var closeButton: NSButton!
    
    func close() {
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.setBackground(R.color.transferBg)
        closeButton.setImage(name: R.drawable.cancel_transfer)
        closeButton.action = #selector(close)
        closeButton.target = self
    }
}
