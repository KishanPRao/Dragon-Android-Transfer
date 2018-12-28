//
//  ConnectionData.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

//Placeholder for now

class OperationData {
    var name = CommCommand.NOP
    var src = ""
    var dest = ""
}

class ConnectionData {
    var connectionStatus = Constants.ConnectionTermOk
    //Includes cancel, term status..
    var operation = OperationData()
}
