//
//  PasteboardWriter.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 07/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class PasteboardWatcher : NSObject {
    
    // assigning a pasteboard object
    private let pasteboard = NSPasteboard.general()
    
    // to keep track of count of objects currently copied
    // also helps in determining if a new object is copied
    private var changeCount : Int
    
    // used to perform polling to identify if url with desired kind is copied
    private var timer: Timer?
    
    // the delegate which will be notified when desired link is copied
    var delegate: PasteboardWatcherDelegate?
    
    // the kinds of files for which if url is copied the delegate is notified
    private let fileKinds : [String]
    
    /// initializer which should be used to initialize object of this class
    /// - Parameter fileKinds: an array containing the desired file kinds
    init(fileKinds: [String]) {
        // assigning current pasteboard changeCount so that it can be compared later to identify changes
        changeCount = pasteboard.changeCount
        
        // assigning passed desired file kinds to respective instance variable
        self.fileKinds = fileKinds
        
        super.init()
    }
    /// starts polling to identify if url with desired kind is copied
    /// - Note: uses an NSTimer for polling
    func startPolling () {
        // setup and start of timer
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(PasteboardWatcher.checkForChangesInPasteboard), userInfo: nil, repeats: true)
    }
    
    func stopPolling() {
    }
    
    /// method invoked continuously by timer
    /// - Note: To keep this method as private I referred this answer at stackoverflow - [Swift - NSTimer does not invoke a private func as selector](http://stackoverflow.com/a/30947182/217586)
    @objc private func checkForChangesInPasteboard() {
        // check if there is any new item copied
        // also check if kind of copied item is string
        if let copiedString = pasteboard.string(forType: NSPasteboardTypeString), pasteboard.changeCount != changeCount {
            
            // obtain url from copied link if its path extension is one of the desired extensions
            if let fileUrl = NSURL(string: copiedString), self.fileKinds.contains(fileUrl.pathExtension!){
                
                // invoke appropriate method on delegate
                self.delegate?.newlyCopiedUrlObtained(copiedUrl: fileUrl)
            }
            
            // assign new change count to instance variable for later comparison
            changeCount = pasteboard.changeCount
        }
    }
}
