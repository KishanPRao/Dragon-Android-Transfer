//
//  SessionSender.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class SessionSender: SessionTransceiver {
    private var queue = Queue<Any>()
    
    func queueMessage(_ request: SessionPacket) {
        var prevEmpty = false
        synchronized(self) {
            if queue.peek() == nil {
                prevEmpty = true
            }
            queue.enqueue(request)
        }
        if (prevEmpty) {
            semaphore.signal()
        }
    }
    
    private func sendMessage(_ p: SessionPacket) -> Result? {
//        cancelTimerForPing()
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(p)
            let jsonString = String(data: jsonData, encoding: .utf8)
            if let data = jsonString {
                let length = String(format: "%0\(Constants.ControlPacketLengthSize)d", data.lengthOfBytes(using: .utf8))
                let sendData = "\(length)\(data)"
//                print("Send Data: \(sendData)")
                let res = client.send(string: sendData)
                return res
            }
        } catch {
            print("Error: \(error)")
        }
        return nil
    }
    
    private func receiveStatus() -> Int {
        if let statusData = receiveForced(Constants.PacketStatusSize),
            let statusStr = String(bytes: statusData, encoding: String.Encoding.utf8),
            let status = Int(statusStr) {
            return status
        }
        return Constants.PacketStatusUnknown
    }
    
    //    TODO: Every blocks size, check & send status.
    func sendSingleFile(_ filePath: String) {
        print("sendSingleFile: \(filePath)")
        //        return
        let fileSize = Utils.getFileSize(filePath)
        let length = String(format: "%0\(Constants.ControlPacketLengthSize)d", fileSize).data(using: .utf8)!
        let res = sendData(length)
        sCallback?.transferProgress(filePath, 0)
        print("Sent length data: \(res)")
        if let res = res, res.isSuccess {
            let blocks = Constants.BlockSize
            var currentLength = 0
            if (fileSize == 0) {
                print("0 length file!")
                return
            }
            if let file = FileHandle(forReadingAtPath: filePath) {
                var data = file.readData(ofLength: blocks)
                var length = data.count
                while length > 0 {
                    currentLength += length
                    let recStatus = receiveStatus()
//                    print("Received Status: \(recStatus)")
                    if (recStatus != Constants.PacketStatusOk) {
                        print("Received bad status: \(recStatus)")
                        self.status = recStatus
                        break
                    }
                    let statusData = String(format: "%0\(Constants.PacketStatusSize)d", status)
                        .data(using: .utf8)!
//                    print("Sending status: \(String(format: "%0\(Constants.PacketStatusSize)d", status))")
                    var res = sendData(statusData)
                    if let res = res, res.isFailure {
                        print("Couldn't send status.")
                        self.status = Constants.PacketStatusFailure
//                        cancelTransfer()
                        break
                    }
                    if (status != Constants.PacketStatusOk) {
                        print("Sent non-OK status, quitting.")
                        break
                    }
                    res = sendData(data)
                    if let res = res, res.isFailure {
                        print("Couldn't send.")
                        self.status = Constants.PacketStatusFailure
//                        cancelTransfer()
                        break
                    }
                    sCallback?.transferProgress(filePath, UInt64(currentLength))
                    data = file.readData(ofLength: blocks)
                    //                    print("Sending \(data.count) bytes of data")
                    length = data.count
                }
//                sCallback?.transferProgress(filePath, UInt64(currentLength))
                file.closeFile()
            }
            print("Sent file, total length: \(currentLength)")
        }
    }
    
    func queueData(_ data: Data) {
        //        TODO: if needed.
    }
    
    override func begin() {}
    
    override func end() {}
    
    override func quit() {
        print("Sender quit")
//        Stop timer
        self.cancel()
        semaphore.signal()
        print("Sender quit done")
    }
    
    override func loop() {
        var empty = false
        //        print("Sender, loop start")
        synchronized(self) {
            //            print("Sender, loop enter")
            if let data = queue.dequeue() {
                if let p = (data as? SessionPacket) {
                    let result = sendMessage(p)
                }
            } else {
                empty = true
            }
            //            print("Sender, loop exit")
        }
        if (empty) {
            //            begin timer or start ping?
//            startPingTimeout()  //start only after all msgs sent? Any issues? Connectivity?
//            print("Sender, wait")
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
//            print("Sender, wait done")
        }
//        cancelTimerForPing()
        //        print("Sender, loop end")
    }
}
