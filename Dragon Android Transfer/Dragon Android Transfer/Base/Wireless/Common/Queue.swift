//
//  Queue.swift
//  DragonSocket
//
//  Created by Kishan P Rao on 21/10/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

public struct Queue<T> {
    fileprivate var list = LinkedList<T>()
    
    public var isEmpty: Bool {
        return list.isEmpty
    }
    
    public mutating func enqueue(_ element: T) {
        list.append(element)
    }
    
    public mutating func dequeue() -> T? {
        guard !list.isEmpty, let element = list.first else { return nil }
        
        list.remove(element)
        
        return element.value
    }
    
    public func peek() -> T? {
        return list.first?.value
    }
}

extension Queue: CustomStringConvertible {
    public var description: String {
        return list.description
    }
}
