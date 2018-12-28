//
//  Action.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

enum Action {
    case OnConnect()
    case OnDisconnect()
    case OnOperation(OperationData)
    case OnOperationCompleted()
    case OnFailure(Int)
    case OnFailureHandled()
}
