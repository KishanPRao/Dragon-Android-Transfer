//
// Created by Kishan P Rao on 04/10/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class ThreadUtils {
    
    static func runInBackgroundThread(_ closure: @escaping () -> ()) {
        DispatchQueue.global(qos: .background).async {
            closure()
        }
    }
    
    static func runInBackgroundThreadAsync(_ closure: @escaping () -> ()) {
        let concurrentQueue = DispatchQueue(label: "com.queue.Concurrent", attributes: .concurrent)
        concurrentQueue.async {
            closure()
        }
    }
    
    static func runInMainThread(_ closure: @escaping () -> ()) {
        DispatchQueue.main.async {
            closure()
        }
    }
    
    static func runInMainThreadIfNeeded(_ closure: @escaping () -> ()) {
		if (ThreadUtils.isMainThread()) {
			closure()
		} else {
			runInMainThread({
				closure()
			})
		}
    }
    
    static func runInMainThreadAfter(delayMs delayInMs: Int, _ closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(delayInMs), execute: {
            closure()
        })
    }
    
    static func isMainThread() -> Bool {
        return Thread.isMainThread
    }
}
