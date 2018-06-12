//
// Created by Kishan P Rao on 14/10/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

//public let kPasteboardTypePasteLocation = "com.apple.pastelocation"
//private let sFakeLocation = "fakeLocation"
//public let sFakeUrl = NSURL(string: sFakeLocation)!
//kUTTypeFileURL for Swift 4 issue?
public let kPasteBoardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
public let kWritableType = kPasteboardTypeFileURLPromise
//let kFakeDraggableItem = DraggableItem()
let sFakeLocation = "fakeLocation"
let sFakeUrl = NSURL(string: sFakeLocation)!

public let DRAG_DROP_NONE = -1
public let DRAG_DROP_WHOLE = -2
