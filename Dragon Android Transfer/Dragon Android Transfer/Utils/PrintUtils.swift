//
// Created by Kishan P Rao on 14/10/17.
// Copyright (c) 2017 Kishan P Rao. All rights reserved.
//

import Foundation

struct PrintUtils {
    static private func PrintItem(_ TAG: String, _ item: Any, terminator: String) {
        if let items = item as? Array<Any> {
            for index in items.indices.dropLast() {
                PrintItem(TAG, items[index], terminator: " ")
            }
            PrintItem(TAG, items.last ?? "", terminator: "\n")
        } else {
            Swift.print(item, terminator: terminator)
        }
    }
    
	static public func Print(_ TAG: String, _ itemsAny: Any) {
			Swift.print("[" + TAG + "]:", terminator: " ")
            PrintItem(TAG, itemsAny, terminator: "\n")
	}
}
