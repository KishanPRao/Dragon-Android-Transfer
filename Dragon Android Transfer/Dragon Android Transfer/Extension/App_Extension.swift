//
//  App_Extension.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 10/07/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//
import Cocoa

extension NSApplication {
    
    func relaunch(afterDelay seconds: TimeInterval = 0.5) /*-> Never*/ {
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep \(seconds); open \"\(Bundle.main.bundlePath)\""]
        task.launch()
        
        self.terminate(nil)
    }
}
