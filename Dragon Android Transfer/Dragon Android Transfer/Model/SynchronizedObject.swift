//
//  SynchronizedObject.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 19/01/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class SynchronizedObject<T>: BaseObject {
	fileprivate var lock : SynchronizedProtocol = SynchronizedDispatchLock();
	fileprivate var item: T
	
	init(_ item: T) {
		self.item = item
	}
	
	func get<U>(_ block: @escaping (T) -> U) -> U {
		return lock.get { [unowned self] in
			return block(self.item)
		}
	}
	
	func set<U>(_ block: @escaping (inout T) -> U) -> U {
		return lock.set { [unowned self] in
			return block(&self.item)
		}
	}
	
	var description: String { return "\(item)" }
}

public struct SynchronizedDispatchLock: SynchronizedProtocol {
	fileprivate let semaphore = DispatchSemaphore(value: 1)
	
	public init() {}
	
	func get<T>(_ block: () -> T) -> T {
		return returnWithLock(block)
	}
	
	fileprivate func returnWithLock<T>(_ body: () -> T) -> T {
		let result: T
		semaphore.wait(timeout: DispatchTime.distantFuture)
		result = body()
		semaphore.signal()
		return result
	}
	
	func set<T>(_ block: () -> T) -> T {
		return returnWithLock(block)
	}
	
//    private func runWithLock(body: ()) {
	fileprivate func runWithLock<T>(_ body: () -> T) {
		semaphore.wait(timeout: DispatchTime.distantFuture)
		body()
		semaphore.signal()
	}
}
