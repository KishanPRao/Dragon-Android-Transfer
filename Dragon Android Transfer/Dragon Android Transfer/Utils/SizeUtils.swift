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
    static let ZERO_BYTES = "0 B"
    
    // TODO: Cache calculated data somewhere! (100 items?)
    static func getBytesInFormat(_ bytesInInt: Number) -> String {
        if (bytesInInt == Number.max || bytesInInt == 0) {
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
                    bytesInString = String(format: "%.2f ", bytesInFloat)+"GB"
                } else {
                    bytesInString = String(format: "%.2f ", bytesInFloat)+"MB"
                }
            } else {
                bytesInString = String(format: "%.0f ", bytesInFloat)+"KB"
            }
        } else {
            bytesInString = String(format: "%.0f ", bytesInFloat)+"B"
        }
        return bytesInString
    }
    
    public static func getSpaceInNumber(_ space: String) -> Float {
        var powerBlockSize = Float(0)
        if space.contains("GB") {
            powerBlockSize = 3
        } else if space.contains("MB") {
            powerBlockSize = 2
        } else if space.contains("KB") {
            powerBlockSize = 1
        } else if space.contains("B") {
            powerBlockSize = 0
        }
        let result = space.trimmingCharacters(in: CharacterSet(charactersIn: "01234567890.").inverted)
        if let spaceInNumber = Float(result) {
            let baseSize = pow(BLOCK_SIZE_IN_FLOAT, powerBlockSize)
            let spaceInBytes = baseSize * spaceInNumber
//            print("Space: \(spaceInNumber), size: \(spaceInBytes), count: \(powerBlockSize)")
            return spaceInBytes
        }
        return 0.0
    }
}
