//
//  SessionProtocol.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

protocol SessionProtocol {
    func getCurrentState() -> ConnectionState
    
    func performAction(_ action: Action)
    
    func connectionEstablishing()
    
    func connectionEstablished()
    
    func connectionTerminated(_ code: Int) //Either through ping pong or other.
    
    func listDirectory(_ path: String)
    
    func download(_ src: String, _ dest: String)
    
    func transferTotalSize(_ size: UInt64)
    
    func transferProgress(_ file: String, _ size: UInt64)
    
    //    TODO: operation related callback, cancel etc.
}
