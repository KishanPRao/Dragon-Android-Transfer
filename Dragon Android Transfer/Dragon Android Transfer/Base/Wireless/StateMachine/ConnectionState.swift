//
//  ConnectionState.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 08/11/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

protocol ConnectionState: AnyObject {
    func performAction(_ action: Action) -> ConnectionState
}
