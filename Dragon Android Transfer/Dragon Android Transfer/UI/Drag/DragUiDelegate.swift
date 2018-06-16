//
//  DragUiDelegate.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 22/10/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

protocol DragUiDelegate {
    
    func onDropDestination(_ row: Int)
    
    func onDragCompleted()
}
