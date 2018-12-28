//
//  Connected.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class Connected: AbstractConnectionState {
    let data: ConnectionData
    init(_ data: ConnectionData) {
        self.data = data
    }
    
    override func performAction(_ action: Action) -> ConnectionState {
        let state: ConnectionState
        switch (action) {
        case Action.OnDisconnect():
            state = Disconnected()
            break
        case Action.OnFailure(_):
            if case let Action.OnFailure(code) = action {
                data.connectionStatus = code
            }
            state = Failed(data)
            break
        case Action.OnOperation(_):
            if case let Action.OnOperation(op) = action {
                data.operation = op
            }
            state = Operation(data)
            break
        default:
            state = super.performAction(action)
            break
        }
        return state
    }
}
