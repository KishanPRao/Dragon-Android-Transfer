//
//  AbstractThread.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 09/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class AbstractThread: Thread {
    func lock(_ block: () -> Void) {
        synchronized(self, block)
    }
    
    open func begin() {
        //        no-op
    }
    
    open func end() {
        //        no-op
    }
    
    open func loop() {
        //        no-op
    }
    
    open func quit() {
        self.cancel()
    }
    
    override func main() {
        begin()
        while !isCancelled {
            loop()
        }
        end()
    }
}
