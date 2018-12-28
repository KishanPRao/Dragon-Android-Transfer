//
//  Constants.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 21/10/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class Constants {
    static let ConnectionRequest = "DragonAT_ConnectionRequest"
    static let ConnectionResponseSuccess = "DragonAT_ConnectionResponseSuccess"
    static let ConnectionResponseErr = "DragonAT_ConnectionResponseError"
    
    static let RequestMessage = "request"
    static let ResponseMessage = "response"
    
    static let MessageArgLen = "length"
    static let MessageArgStatus = "status"
    static let MessageArgStatusOk = "OK"
    static let MessageArgStatusErr = "Error"
    static let MessageArgStatusReason = "reason"
    static let MessageArgFile = "file"
    static let MessageArgIsDirectory = "isDirectory"
    static let MessageArgFiles = "files"
    static let MessageArgNumFiles = "numFiles"
    static let MessageArgDir = "directory"
    static let MessageArgPath = "path"
    static let MessageArgSize = "totalSize"
    
    static let ControlPacketLengthSize = 13 //4 before
    static let BlockSize = 1024 * 512
    
    static let PacketStatusSize = 1
    static let PacketStatusOk = 0
    static let PacketStatusCancel = 1
    static let PacketStatusUnknown = 2
    static let PacketStatusFailure = 3
    
    static let BcastPort: Int32 = 8888
    static let BcastListenPort: Int32 = 8889
    static let DiscoverBufSize: Int = 1500
    
    static let ConnectionTermOk = 0
    static let ConnectionTermErr = -1
    static let ConnectionTermCancel = -2
}
