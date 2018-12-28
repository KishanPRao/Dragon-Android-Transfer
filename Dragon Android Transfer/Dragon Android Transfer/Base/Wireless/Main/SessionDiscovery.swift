//
//  SessionDiscovery.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class SessionDiscovery: AbstractThread {
    let session: SessionProtocol
    private let port: Int32
    private let clientPort: Int32
    private let bufSize: Int
    private var continueRunning = true
    
    private var busy = false
    private var udpEndPoint : UDPServer? = nil
    private var queue: DispatchQueue
    
    init(_ session: SessionProtocol) {
        self.session = session
        port = Constants.BcastPort
        clientPort = Constants.BcastListenPort
        bufSize = Constants.DiscoverBufSize
        queue = DispatchQueue.global(qos: .background)
    }
    
    private func initConnection(_ ip: String) {
        let respClient = UDPClient(address: ip, port: clientPort)
        let response = busy ? Constants.ConnectionResponseErr : Constants.ConnectionResponseSuccess
        /*while (respClient.send(string: response).isFailure) {
         print("Resending, failure conn")
         }*/
        if (respClient.send(string: response).isSuccess) {
            print("initConnection: Response sent:", response)
            if (response == Constants.ConnectionResponseSuccess) {
                busy = true
                self.session.performAction(Action.OnConnect())
            }
        } else {
            print("initConnection: Failed")
        }
        respClient.close()
    }
    
    override func begin() {
        self.udpEndPoint = UDPServer(address: "0.0.0.0", port: self.port)
    }
    
    override func loop() {
        if let udpEndPoint = self.udpEndPoint, self.continueRunning {
            print("Waiting...")
            let (data, remoteIp, remotePort) = udpEndPoint.recv(self.bufSize)
            print("Connected:", remoteIp, remotePort)
            if let d = data, let msg = String(bytes: d, encoding: String.Encoding.utf8) {
                print("Got message:", msg)
                if (msg == Constants.ConnectionRequest) {
                    self.initConnection(remoteIp)
                }
            }
        }
    }
    
    func resetDiscovery() {
        print("resetDiscovery")
        busy = false
    }
    
    override func end() {
        print("Stopping Connection")
        self.continueRunning = false
        self.udpEndPoint?.close()   //TODO: Close outside thread?
        self.udpEndPoint = nil
    }
    
    override func quit() {
//        self.udpEndPoint?.close() //better?
        self.cancel()
    }
    
//    func end() {
//        print("Stopping Connection")
//        queue.async(execute: {
//            self.continueRunning = false
//            self.udpEndPoint?.close()
//            self.udpEndPoint = nil
//        })
//    }
}
