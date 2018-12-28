//
//  Concurrency.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

func synchronized(_ lock:AnyObject, _ block:() throws -> Void ) rethrows {
    objc_sync_enter(lock)
    defer {
        objc_sync_exit(lock)
    }
    
    try block()
}
