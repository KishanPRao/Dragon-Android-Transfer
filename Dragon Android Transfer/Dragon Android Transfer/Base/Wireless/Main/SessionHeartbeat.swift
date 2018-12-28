//
//  SessionHeartbeat.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 09/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class SessionHeartbeat: AbstractThread {
    private let client: TCPClient
    private let callback: SessionProtocol
    private let sender: SessionSender
    private let PING_SLEEP = 2.0
    
    private var ponglessCount = 0
    private var hasReceivedPong = false
    
    init(_ client: TCPClient, _ sender: SessionSender, _ cback: SessionProtocol) {
        self.client = client
        self.sender = sender
        self.callback = cback
    }
    
    override func begin() {
    }
    
    override func end() {
    }
    
    override func quit() {
        super.quit()
    }
    
    func onPong() {
        lock {
            hasReceivedPong = true
            ponglessCount = ponglessCount - 1
        }
    }
    
    private func sendPing() {
//        NSLog("echo, sending ping")
//        print(Thread.callStackSymbols.forEach{print($0)})
        sender.queueMessage(SessionPacket(CommCommand.Ping))
        ponglessCount = ponglessCount + 1
//        print("echo, pongless count: \(ponglessCount)")
        if (ponglessCount >= 3 && !hasReceivedPong) {
            print("echo, closing")
            callback.connectionTerminated(Constants.ConnectionTermErr)
        }
        hasReceivedPong = false
    }
    
    override func loop() {
        lock {
            sendPing()
        }
        Thread.sleep(forTimeInterval: PING_SLEEP)
    }
}
