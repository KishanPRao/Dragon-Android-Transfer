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
	func onStart(_ totalSize: Number, transferType: Int)
    
    func currentFile(_ fileName: String)
	
    func onProgress(_ progress: Int)
	
	func onCompletion(status: FileProgressStatus)
}

enum FileProgressStatus: Int {
//	static let kStatusOk = 0
//	static let kStatusCanceled = 1
//	static let kStatusError = 2
	case kStatusOk
	case kStatusInProgress
	case kStatusCanceled
	case kStatusError
}
