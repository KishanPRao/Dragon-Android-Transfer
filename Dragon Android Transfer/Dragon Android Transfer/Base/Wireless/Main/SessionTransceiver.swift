//
//  SessionTransceiver.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class SessionTransceiver: AbstractThread {
    let TIMEOUT = 5
    var status = Constants.PacketStatusOk
    var callback: SessionResponseProtocol? = nil
    var sCallback: SessionProtocol? = nil
    var client: TCPClient
    let lock = NSObject()
    let semaphore = DispatchSemaphore(value: 0)
    
    init(_ client: TCPClient) {
        self.client = client
    }
    
    func cleanup() {
        callback = nil
    }
    
    func cancelOperation() {
        status = Constants.PacketStatusCancel
    }
    
    func isCanceled() -> Bool {
        return status == Constants.PacketStatusCancel
    }
    
    func reset() {
        status = Constants.PacketStatusOk
    }
    
    internal func receiveForced(_ length: Int) -> Data? {
        if let byteData = client.readForced(length, timeoutInSeconds: TIMEOUT) {
            //            return Data(bytes: byteData)
            let data = byteData.withUnsafeBufferPointer {Data(buffer: $0)}
            return data
        }
        return nil
    }
    
    internal func sendData(_ data: Data) -> Result? {
        let res = client.sendForced(data: data, timeoutInSeconds: TIMEOUT)
        //        print("sendData: \(res)")
        return res
    }
    
    override func main() {
        begin()
        while !isCancelled {
            loop()
        }
        end()
//        callback?.stopped()
    }
}
