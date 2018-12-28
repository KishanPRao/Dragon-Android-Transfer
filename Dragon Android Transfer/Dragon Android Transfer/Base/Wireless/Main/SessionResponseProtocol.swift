//
//  SessionResponseProtocol.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

protocol SessionResponseProtocol {
    func receivedPong()
    
    //func cancelTransfer() //If any. Then start pinging.
//    func stopped()
//
//    func connectionStopped()    //Found from ping-pong exchange.
    
    func sendListRequest(_ path: String)
    
    func connectionTermRecv(_ code: Int)
    
    func handlePushResponse()
    
    func handlePullResponse(_ p: SessionPacket)
    
    func handleListResponse(_ p: SessionPacket)
}
