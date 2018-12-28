//
//  AbstractConnectionState.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

class AbstractConnectionState: ConnectionState {
    func performAction(_ action: Action) -> ConnectionState {
        print("WARNING: performAction, bad state, \(self) => \(action)")
        return self
    }
}
