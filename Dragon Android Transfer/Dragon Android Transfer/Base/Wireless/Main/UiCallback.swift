//
//  UiCallback.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

protocol UiCallback {
    func onConnecting()
    func onConnected()
    func onDisconnected()
    func onFailure(_ code: Int)
    func onTransferBegin()
    func onTransferSize(_ totalSize: UInt64)
    func onTransferProgress(_ currentFile: String, _ currentLength: UInt64)
    func onTransferEnd()
}
