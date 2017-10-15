//
// Created by Kishan P Rao on 04/10/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class ThreadUtils {
	
	static func runInBackgroundThread(closure: @escaping () -> ()) {
		DispatchQueue.global(qos: .background).async {
			closure()
		}
	}
	
	static func runInMainThread(closure: @escaping () -> ()) {
		DispatchQueue.main.async {
			closure()
		}
	}
}