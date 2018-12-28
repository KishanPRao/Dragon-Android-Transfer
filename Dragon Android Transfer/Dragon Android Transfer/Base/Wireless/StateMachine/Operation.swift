//
//  Operation.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class Operation: AbstractConnectionState {
    let data: ConnectionData
    init(_ data: ConnectionData) {
        self.data = data
    }
    
    override func performAction(_ action: Action) -> ConnectionState {
        let state: ConnectionState
        switch action {
        case Action.OnOperationCompleted():
            state = Connected(data)
        case Action.OnFailure(_):
            if case let Action.OnFailure(code) = action {
                data.connectionStatus = code
            }
            state = Failed(data)
        case Action.OnDisconnect()://confirm scenario not possible.
            state = Failed(data)
        default:
            state = super.performAction(action)
        }
        return state
    }
}
