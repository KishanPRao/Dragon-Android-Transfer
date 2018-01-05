//
//  String_Extension.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 06/01/18.
//  Copyright © 2018 Kishan P Rao. All rights reserved.
//

import Foundation

extension String {
    func escapeString() -> String {
        var newString = self.replacingOccurrences(of: "\"", with: "\"\"")
//        if newString.contains(",") || newString.contains("\n") || newString.contains("'") {
//            newString = String(format: "\"%@\"", newString)
//            Swift.print("Escaped: \(newString)")
//        }
        
//        newString = newString.replacingOccurrences(of: "'", with: "\'")
//        Swift.print("Escaped: \(newString)")
        return newString
    }
}
