//
//  FileProgressDelegate.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 14/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

//All delegate methods must be called on Main Thread
protocol FileProgressDelegate: class {
	func onStart(_ totalSize: UInt64, transferType: Int)
    
    func currentFile(_ fileName: String)
	
    func onProgress(_ progress: Int)
	
	func onCompletion()
}
