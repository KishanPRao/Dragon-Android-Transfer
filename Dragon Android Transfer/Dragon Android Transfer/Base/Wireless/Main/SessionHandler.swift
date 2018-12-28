//
//  SessionHandler.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation
import SwiftyJSON

class SessionHandler: SessionResponseProtocol {
    let RemoteHandlerPort: Int32 = 7777
    var receiver: SessionReceiver? = nil
    var sender: SessionSender? = nil
    var client: TCPClient? = nil
    var server: TCPServer? = nil
    var hbeat: SessionHeartbeat? = nil
    
    var pushFiles: [String]? = nil
    var pushIsDirectory = false
    var pushDirectory = ""
    var pullLocation: String = ""
    
    let callback: SessionProtocol
    
    var isOperationRecv = false
    
    init(_ cback: SessionProtocol) {
        self.callback = cback
    }
    
    private func initServer() {
        server = TCPServer(address: "0.0.0.0", port: RemoteHandlerPort)
        if let server = server {
            switch server.listen() {
            case .success:
                NSLog("Listening..")
                if let client = server.accept(timeout: 10) { //10 seconds timeout
                    self.client = client
                    initTransceiver()
                    //                    break
                } else {
                    NSLog("Handler, accept error")
                    stop()
//                    callback?.connectionTerminated()
                }
            case .failure(let error):
                print("Handler, server err:", error)
            }
        }
    }
    
    private func initTransceiver() {
        guard let client = self.client else { return }
        client.enableBlocking(false)
        //        isOpen = true
        
        receiver = SessionReceiver(client)
        receiver!.callback = self
        receiver!.sCallback = callback
        
        sender = SessionSender(client)
        sender!.callback = self
        sender!.sCallback = callback
        
        receiver!.start()
        sender!.start()
        
        hbeat = SessionHeartbeat(client, sender!, callback)
        hbeat!.start()
        
        callback.connectionEstablished()
        //        pull("/sdcard/Test/demo", "~/dump/Test")
        //        pull("/sdcard/Test/Dragon Android Transfer other.app", "~/dump/Test")
        //        push("~/dump/Test/otherFiles/Dragon Android Transfer other.app", "/sdcard/Test")
        //        push("~/dump/Test/DemoNew", "/sdcard/Test")
        //        push("~/dump/Test/bb_scene.mp4", "/sdcard/Test")
        //        push("~/dump/Test/bb_scene.mp4", "/sdcard/Test/Test/bb_scene.mp4")
//        pull("/sdcard/Test/bb_scene.mp4", "~/dump/Test")
        //        pull("/sdcard/Movies/Pacific Rim (2013)", "~/dump/Test")
    }
    
    func start() {
        callback.connectionEstablishing()
        let queue = DispatchQueue.global(qos: .default)
        queue.async(execute: { () -> Void in
            self.initServer()
        })
    }
    
    //    Src file on Mac
    //    Dest file on Android
    //    Assure '/' is not used at end of path. Remove if needed (add Extension).
    func push(_ srcFile: String, _ destPath: String) {
        isOperationRecv = false
        let srcPath = (srcFile as NSString).expandingTildeInPath
        //        self.srcFile = srcPath
        let fm = FileManager.default
        var isDir : ObjCBool = false
        //        var json = JSON([Constants.MessageArgFile:destFile])
        var json = JSON()
        if fm.fileExists(atPath: srcPath, isDirectory:&isDir) {
            json[Constants.MessageArgIsDirectory] = JSON(isDir.boolValue)
            pushIsDirectory = isDir.boolValue
            var totalSize: UInt64 = 0
            if isDir.boolValue {
                pushIsDirectory = true
                (pushFiles, totalSize) = Utils.getFilesFor(directory: srcPath)
                pushDirectory = srcPath
                //                print("Got files: \(files)")
                //                json[Constants.MessageArgDirFiles].arrayObject =
                var filesJson = [String:String]()
                for (i, file) in pushFiles!.enumerated() {
                    filesJson["\(i)"] = file
                }
                json[Constants.MessageArgFiles] = JSON(filesJson)
                json[Constants.MessageArgNumFiles] = JSON(pushFiles!.count)
                let directoryName = (srcPath as NSString).lastPathComponent
                json[Constants.MessageArgDir] = JSON("\(destPath)/\(directoryName)")
            } else {
                var filePath = srcPath
                totalSize = Utils.getFileSize(filePath)
                
                let parentPath = (filePath as NSString).deletingLastPathComponent
                filePath = filePath.replacingOccurrences(of: "\(parentPath)/", with: "")
                pushFiles = [String]()
                pushFiles?.append(filePath)
                pushDirectory = parentPath
                json[Constants.MessageArgFile] = JSON(filePath)
                json[Constants.MessageArgDir] = JSON(destPath)
            }
            print("Json: \(json)")
            let pushPacket = SessionPacket(CommCommand.PushRequest, json)
            sender?.queueMessage(pushPacket)
            
            callback.transferTotalSize(totalSize)
        } else {
            print("Error, no such file")
        }
    }
    
    func cancelOperation() {
        if (isOperationRecv) {
            receiver?.cancelOperation()
        } else {
            sender?.cancelOperation()
        }
    }
    
    func pull(_ srcFile: String, _ destFile: String) {
        isOperationRecv = true
        pullLocation = (destFile as NSString).expandingTildeInPath
        let json = JSON([Constants.MessageArgFile:srcFile])
        sender?.queueMessage(SessionPacket(CommCommand.PullRequest, json))
    }
    
    func stop() {
        print("Handler, stop")
//        if sender != nil {
//            print("Ping count: \(pingCount)")
//        }
        //        TODO: Clean quit.
        sender?.quit()
        sender = nil
        receiver?.quit()
        receiver = nil
//        timer?.invalidate()
//        timer = nil
        server?.close()
        server = nil
        client?.close()
        client = nil
        hbeat?.quit()
        hbeat = nil
        print("Handler, stopped")
    }
    
    func receivedPong() {
        hbeat?.onPong()
    }
    
    func connectionTermRecv(_ code: Int) {
        callback.connectionTerminated(code)
    }
    
    func sendListRequest(_ path: String) {
        isOperationRecv = true
        let json = JSON([Constants.MessageArgPath:path])
        sender?.queueMessage(SessionPacket(CommCommand.ListRequest, json))
    }
    
    func handleListResponse(_ packet: SessionPacket) {
        if let length = packet.args[Constants.MessageArgLen].int {
            //                print("List Response len: \(length)")
            if let client = client, let strData = client.readForced(length) {
                //                        print("Data: \(strData)")
                if let message = String(bytes: strData, encoding: String.Encoding.utf8) {
                    print("Msg: \(message)")
                }
            } else {
                print("Data not read!")
            }
        } else {
            print("bad")
        }
        callback.performAction(Action.OnOperationCompleted())
    }
    
    private func handlePushResponseInternal() {
        sender?.reset()
        if let files = pushFiles {
            for file in files {
                sender?.sendSingleFile("\(pushDirectory)/\(file)")
                if (sender?.status != Constants.PacketStatusOk) {
                    break
                }
                //                if (inProgress && cancelTransferOp) {
                //                    print("Canceling Transfer Op")
                //                    break
                //                }
            }
        }
    }
    
    func handlePushResponse() {
        sender?.lock {
            hbeat?.lock {
                handlePushResponseInternal()
                if let sender = sender, sender.status != Constants.PacketStatusOk {
                    callback.performAction(Action.OnFailure(sender.status))
                } else {
                    callback.performAction(Action.OnOperationCompleted())
                }
            }
        }
    }
    
    private func handlePullResponseInternal(_ p: SessionPacket) {
        receiver?.reset()
        let args = p.args
        let isDirectory = args[Constants.MessageArgIsDirectory].boolValue
        let directoryName = args[Constants.MessageArgDir].stringValue
        let totalSize = args[Constants.MessageArgSize].intValue
        var files = [String]()
        if (isDirectory) {
            let jsonFiles = args[Constants.MessageArgFiles].dictionaryValue
            let numFiles = args[Constants.MessageArgNumFiles].intValue
            for i in (0..<numFiles) {
                let file = jsonFiles["\(i)"]!.stringValue
                files.append(file)
            }
            let directoryName = args[Constants.MessageArgDir].stringValue
            pullLocation = "\(pullLocation)/\(directoryName)"
        } else {
            let file = args[Constants.MessageArgFile].stringValue
            files.append(file)
        }
        print("Total Size: \(totalSize)")
        callback.transferTotalSize(UInt64(totalSize))
        print("Files: \(files)")
        for file in files {
            receiver?.readSingleFile("\(pullLocation)/\(file)")
            if (receiver?.status != Constants.PacketStatusOk) {
                break
            }
            //            receiver?.readSingleFile("\(pullLocation)/\(file)")
            //            if (inProgress && cancelTransferOp) {
            //                print("Canceling Transfer Op")
            //                //                    TODO: Handle cleanup, atleast delete corrupted file
            //                break
            //            }
        }
    }
    
    func handlePullResponse(_ p: SessionPacket) {
        hbeat?.lock {
            sender?.lock {
                handlePullResponseInternal(p)
                if let receiver = receiver, receiver.status != Constants.PacketStatusOk {
                    callback.performAction(Action.OnFailure(receiver.status))
                } else {
                    callback.performAction(Action.OnOperationCompleted())
                }
            }
        }
    }
}
