//
//  Disconnected.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class Disconnected: AbstractConnectionState {
    override func performAction(_ action: Action) -> ConnectionState {
        let state: ConnectionState
        switch action {
        case Action.OnConnect():
            state = Connected(ConnectionData())
        default:
            state = super.performAction(action)
        }
        return state
    }
}
