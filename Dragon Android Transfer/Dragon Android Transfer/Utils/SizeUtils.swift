//
//  SizeUtils.swift
//  Dragon Android Transfer
//
//  Created by Kishan P Rao on 01/02/17.
//  Copyright © 2017 Kishan P Rao. All rights reserved.
//

import Foundation

class SizeUtils {
    static let BLOCK_SIZE_IN_FLOAT = Float(1024)
    
    static func getBytesInFormat(_ bytesInInt: UInt64) -> String {
        if (bytesInInt == UInt64.max || bytesInInt == 0) {
            return "Folder"
        }
        var bytesInFloat = Float(bytesInInt)
        var bytesInString = "";
        if (bytesInFloat > BLOCK_SIZE_IN_FLOAT) {
            bytesInFloat = bytesInFloat / BLOCK_SIZE_IN_FLOAT
            if (bytesInFloat > BLOCK_SIZE_IN_FLOAT) {
                bytesInFloat = bytesInFloat / BLOCK_SIZE_IN_FLOAT
                if (bytesInFloat > BLOCK_SIZE_IN_FLOAT) {
                    bytesInFloat = bytesInFloat / BLOCK_SIZE_IN_FLOAT
                    bytesInString = String(format: "%.2f", bytesInFloat)+"GB"
                } else {
                    bytesInString = String(format: "%.2f", bytesInFloat)+"MB"
                }
            } else {
                bytesInString = String(format: "%.0f", bytesInFloat)+"KB"
            }
        } else {
            bytesInString = String(format: "%.0f", bytesInFloat)+"B"
        }
        return bytesInString
    }
    
    public static func getSpaceInNumber(_ space: String) -> Float {
        let result = space.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted)
        if let spaceInNumber = Float(result) {
            return spaceInNumber
        }
        return 0.0
    }
}
