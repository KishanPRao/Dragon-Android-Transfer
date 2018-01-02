//
//  NSRect_Extension.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 02/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

extension NSRect {
    mutating func update(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
        origin.x = x
        origin.y = y
        size.width = width
        size.height = height
    }
}
