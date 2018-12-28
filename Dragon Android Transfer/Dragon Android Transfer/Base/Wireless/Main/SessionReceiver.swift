//
//  SessionReceiver.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class SessionReceiver: SessionTransceiver {
    var currentLen = 0
    var previousLen = 0
    
    @objc func timerSpeedCalc() {
        let diff = currentLen - previousLen
        previousLen = currentLen
        print("Diff: \(diff), \(Double(diff) / Double(1024 * 1024))MBps")
    }
    
    func readSingleFile(_ filePath: String) {
        print("readSingleFile: \(filePath)")
        //        var blocks = 1024 * 1024
        var blocks = Constants.BlockSize
        let parentPath = (filePath as NSString).deletingLastPathComponent
        do {
            try FileManager.default.createDirectory(atPath: parentPath,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            print(error)
        }
        FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)
        let file = FileHandle(forWritingAtPath: filePath)
        if let file = file {
            if let fileLengthData = receiveForced(Constants.ControlPacketLengthSize) {
                if let message = String(bytes: fileLengthData, encoding: String.Encoding.utf8),
                    let length = Int(message), length != -1 {
                    print("readSingleFile: length:\(length)")
                    if (length == 0) {
                        print("0 byte file!")
                        file.closeFile()
                        return
                    }
                    blocks = (blocks > length) ? length : blocks
                    //                    var last = false
                    previousLen = currentLen
                    let timer = DispatchQueue.main.sync {
                        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerSpeedCalc), userInfo: nil, repeats: true)
//                        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){_ in
//                            let diff = currentLen - previousLen
//                            previousLen = currentLen
//                            print("Diff: \(diff), \(Double(diff) / Double(1024 * 1024))MBps")
//                        }
                    }
                    repeat {
                        let statusData = String(format: "%0\(Constants.PacketStatusSize)d", status)
                            .data(using: .utf8)!
//                        print("Sending status: \(String(format: "%0\(Constants.PacketStatusSize)d", status))")
                        let res = sendData(statusData)
                        if let res = res, res.isFailure {
                            print("Couldn't send status.")
                            break
                        }
                        if (status != Constants.PacketStatusOk) {
//                            print("Sending bad status: \(status)")
                            break
                        }
                        if let statusData = receiveForced(Constants.PacketStatusSize),
                            let data = receiveForced(blocks) {
                            if let statusStr = String(bytes: statusData, encoding: String.Encoding.utf8),
                                let status = Int(statusStr) {
//                                print("Received Status: \(status)") //TODO:
                                if (status != Constants.PacketStatusOk) {
                                    print("Received bad status: \(status)")
                                    break
                                }
                            }
                            currentLen += data.count
                            print("Read: \(currentLen), \(length), \(data.count)")
                            //                        print("Data: \(intArray.prefix(30))")
                            file.write(data)
                            if ((length - currentLen) < blocks) {
                                blocks = length - currentLen
                                //                            last = true
                            }
                            sCallback?.transferProgress(filePath, UInt64(currentLen))
                        } else {
                            print("Couldn't receive data.")
                            status = Constants.PacketStatusFailure
                            break
                        }
                    } while currentLen < length
                    timer.invalidate()
                    print("Exiting, length: \(currentLen)")
                } else {
                    print("Bad msg/len")
                    status = Constants.PacketStatusFailure
//                    cancelTransfer()
                }
            } else {
                print("Bad file len")
                status = Constants.PacketStatusFailure
            }
            file.closeFile()
        } else {
            print("Bad rec/file")
            status = Constants.PacketStatusFailure
        }
        print("readSingleFile completed!")
    }
    
    func handleResponse(_ packet: SessionPacket) {
        //        print("handleResponse: \(message)")
        if ((packet.args[Constants.MessageArgStatus].string ?? "") != Constants.MessageArgStatusOk) {
            print("handleResponse: bad status: \(packet.args[Constants.MessageArgStatus])")
            return
        }
        if (packet.name == CommCommand.ListResponse) {
            //            print("List Response")
            callback?.handleListResponse(packet)
        } else if (packet.name == CommCommand.PullResponse) {
            callback?.handlePullResponse(packet)
        } else if (packet.name == CommCommand.PushResponse) {
            callback?.handlePushResponse()
        }
    }
    
    override func loop() {
        if let data = client.read(Constants.ControlPacketLengthSize),
            let lenData = String(bytes: data, encoding: String.Encoding.utf8),
            let length = Int(lenData) {  //Get length data
            //            print("Got len data: \(length)")
            //            if let strData = client?.readForced(length),
            if let strData = client.readForced(length, timeoutInSeconds: TIMEOUT),
                let message = String(bytes: strData, encoding: String.Encoding.utf8) {
                //                print("Rec msg: \(message)")
                let p = SessionPacket.init(withJsonString: message)
//                NSLog("Session Message: \(p)")
                if (!p.isValid()) {
                    NSLog("⚠️ Bad message")
                    return
                }
                if (p.name == CommCommand.Pong) {
                    callback?.receivedPong()
                } else if (p.name == CommCommand.Quit) {
                    //                    callback?.connectionStopped()
                    callback?.connectionTermRecv(Constants.ConnectionTermOk)
                } else {
                    if (p.isRequest()) {
                    } else {
                        handleResponse(p)
                    }
                }
            } else {
                print("Bad data")
                //                    callback?.cancelTransfer()
            }
        }
    }
}
