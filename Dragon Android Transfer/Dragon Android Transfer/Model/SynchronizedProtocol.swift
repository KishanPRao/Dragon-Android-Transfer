//
//  SynchronizedProtocol.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 19/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

protocol SynchronizedProtocol {
// Get a shared reader lock, run the given block, unlock, and return
// whatever the block returned
	mutating func get<T>(_ block: () -> T) -> T
	
// Get an exclusive writer lock, run the given block, unlock, and
// return whatever the block returned
//    mutating func set(block: ())
	mutating func set<T>(_ block: () -> T) -> T
}
