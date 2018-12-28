//
//  Failed.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class Failed: AbstractConnectionState {
    let data: ConnectionData
    init(_ data: ConnectionData) {
        self.data = data
    }
    
    override func performAction(_ action: Action) -> ConnectionState {
        let state: ConnectionState
        switch action {
        case Action.OnFailureHandled():
            if (data.connectionStatus == Constants.ConnectionTermOk) {
                state = Connected(data)
            } else {
                state = Disconnected()
            }
        default:
            state = super.performAction(action)
        }
        return state
    }
}
